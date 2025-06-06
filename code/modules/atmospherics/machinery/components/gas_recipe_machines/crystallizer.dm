#define MIN_PROGRESS_AMOUNT 3
#define MIN_DEVIATION_RATE 0.90
#define MAX_DEVIATION_RATE 1.1
#define HIGH_CONDUCTIVITY_RATIO 0.95

/obj/machinery/atmospherics/components/binary/crystallizer
	icon = 'icons/obj/atmospherics/components/machines.dmi'
	icon_state = "crystallizer-off"
	name = "crystallizer"
	desc = "Used to crystallize or solidify gases."
	layer = ABOVE_MOB_LAYER
	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30, ELECTRIC = 100)
	circuit = /obj/item/circuitboard/machine/crystallizer
	pipe_flags = PIPING_ONE_PER_TURF| PIPING_DEFAULT_LAYER_ONLY
	vent_movement = NONE

	///Base icon state for the machine to be used in update_appearance(UPDATE_ICON)
	var/base_icon = "crystallizer"
	///Internal Gas mix used for processing the gases that have been put in
	var/datum/gas_mixture/internal
	///Var that controls how much gas gets injected in moles/S
	var/gas_input = 0
	///Maximum allowed gas input
	var/max_gas_input = 250
	///Saves the progress during the processing of the items
	var/progress_bar = 0
	///Stores the amount of lost quality
	var/quality_loss = 0
	///Stores the recipe selected by the user in the GUI
	var/datum/gas_recipe/selected_recipe = null
	///Stores the total amount of moles needed for the current recipe
	var/total_recipe_moles = 0

/obj/machinery/atmospherics/components/binary/crystallizer/Initialize(mapload)
	. = ..()
	internal = new

/obj/machinery/atmospherics/components/binary/crystallizer/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon]-open", "[base_icon]-off", I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/binary/crystallizer/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(!.)
		return FALSE
	set_init_directions()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null
	if(node2)
		if(src in node2.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node2.disconnect(src)
		nodes[2] = null

	if(parents[1])
		nullify_pipenet(parents[1])
	if(parents[2])
		nullify_pipenet(parents[2])

	atmos_init()
	node1 = nodes[1]
	if(node1)
		node1.atmos_init()
		node1.add_member(src)
	node2 = nodes[2]
	if(node2)
		node2.atmos_init()
		node2.add_member(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/binary/crystallizer/update_overlays()
	. = ..()
	cut_overlays()
	. += get_pipe_image(icon, "pipe", dir, COLOR_LIME, piping_layer)
	. += get_pipe_image(icon, "pipe", turn(dir, 180), COLOR_RED, piping_layer)

/obj/machinery/atmospherics/components/binary/crystallizer/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[base_icon]-open"
	else if(on)
		icon_state = "[base_icon]-on"
	else
		icon_state = "[base_icon]-off"

/obj/machinery/atmospherics/components/binary/crystallizer/AltClick(mob/user)
	if(!can_interact(user))
		return
	on = !on
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)

///Checks if the gases in the input are the ones needed by the recipe
/obj/machinery/atmospherics/components/binary/crystallizer/proc/check_gas_requirements()
	var/datum/gas_mixture/contents = airs[2]
	for(var/gas_type in selected_recipe.requirements)
		if(!contents.get_moles(gas_type) && !internal.get_moles(gas_type))
			return FALSE
	return TRUE

///Checks if the reaction temperature is inside the range of temperature + a little deviation
/obj/machinery/atmospherics/components/binary/crystallizer/proc/check_temp_requirements()
	if(internal.return_temperature() >= selected_recipe.min_temp * MIN_DEVIATION_RATE && internal.return_temperature() <= selected_recipe.max_temp * MAX_DEVIATION_RATE)
		return TRUE
	return FALSE

///Injects the gases from the input inside the internal gasmix, the amount is dependant on the gas_input var
/obj/machinery/atmospherics/components/binary/crystallizer/proc/inject_gases()
	var/datum/gas_mixture/contents = airs[2]
	for(var/gas_type in selected_recipe.requirements)
		var/datum/gas_mixture/filtered = new
		filtered.set_temperature(contents.return_temperature())
		var/filtered_amount = min(gas_input, contents.get_moles(gas_type))
		filtered.set_moles(gas_type, filtered_amount)
		contents.adjust_moles(gas_type, -filtered_amount)
		internal.merge(filtered)

///Checks if the gases required are all inside
/obj/machinery/atmospherics/components/binary/crystallizer/proc/internal_check()
	var/gas_check = 0
	for(var/gas_type in selected_recipe.requirements)
		if(!internal.get_moles(gas_type))
			return FALSE
		if(internal.get_moles(gas_type) >= selected_recipe.requirements[gas_type])
			gas_check++
	if(gas_check == selected_recipe.requirements.len)
		return TRUE
	return FALSE

///Calculation for the heat of the various gas mixes and controls the quality of the item
/obj/machinery/atmospherics/components/binary/crystallizer/proc/heat_calculations()
	var/progress_amount_to_quality = MIN_PROGRESS_AMOUNT * 4.5 / (round(log(10, total_recipe_moles * 0.1), 0.01))

	if((internal.return_temperature() >= (selected_recipe.min_temp * MIN_DEVIATION_RATE) && internal.return_temperature() <= selected_recipe.min_temp) || \
		(internal.return_temperature() >= selected_recipe.max_temp && internal.return_temperature() <= (selected_recipe.max_temp * MAX_DEVIATION_RATE)))
		quality_loss = min(quality_loss + progress_amount_to_quality, 100)

	var/median_temperature = (selected_recipe.max_temp + selected_recipe.min_temp) / 2
	if(internal.return_temperature() >= (median_temperature * MIN_DEVIATION_RATE) && internal.return_temperature() <= (median_temperature * MAX_DEVIATION_RATE))
		quality_loss = max(quality_loss - progress_amount_to_quality, -85)
	
	internal.set_temperature(max(internal.return_temperature() + (selected_recipe.energy_release / internal.heat_capacity()), TCMB))
	update_parents()

///Conduction between the internal gasmix and the moderating (cooling/heating) gasmix.
/obj/machinery/atmospherics/components/binary/crystallizer/proc/heat_conduction()
	var/datum/gas_mixture/cooling_port = airs[1]
	if(cooling_port.total_moles() > MINIMUM_MOLE_COUNT)
		if(internal.total_moles() > 0)
			var/coolant_temperature_delta = cooling_port.return_temperature() - internal.return_temperature()
			var/cooling_heat_capacity = cooling_port.heat_capacity()
			var/internal_heat_capacity = internal.heat_capacity()
			var/cooling_heat_amount = HIGH_CONDUCTIVITY_RATIO * coolant_temperature_delta * (cooling_heat_capacity * internal_heat_capacity / (cooling_heat_capacity + internal_heat_capacity))
			cooling_port.set_temperature(max(cooling_port.return_temperature() - cooling_heat_amount / cooling_heat_capacity, TCMB))
			internal.set_temperature(max(internal.return_temperature() + cooling_heat_amount / internal_heat_capacity, TCMB))
		update_parents()

///Calculate the total moles needed for the recipe
/obj/machinery/atmospherics/components/binary/crystallizer/proc/moles_calculations()
	var/amounts = 0
	for(var/gas_type in selected_recipe.requirements)
		amounts += selected_recipe.requirements[gas_type]
	total_recipe_moles = amounts

///Removes the gases from the internal gasmix when the recipe is changed
/obj/machinery/atmospherics/components/binary/crystallizer/proc/dump_gases()
	var/datum/gas_mixture/remove = internal.remove(internal.total_moles())
	airs[2].merge(remove)

/obj/machinery/atmospherics/components/binary/crystallizer/process_atmos()
	if(!on || !is_operational() || selected_recipe == null)
		return

	inject_gases()

	if(!internal.total_moles())
		update_parents()
		return

	heat_conduction()

	if(internal_check())
		if(check_temp_requirements())
			heat_calculations()
			progress_bar = min(progress_bar + (MIN_PROGRESS_AMOUNT * 5 / (round(log(10, total_recipe_moles * 0.1), 0.01))), 100)
		else
			quality_loss = min(quality_loss + 0.5, 100)
			progress_bar = max(progress_bar - 1, 0)
	if(progress_bar != 100)
		update_parents()
		return
	progress_bar = 0

	for(var/gas_type in selected_recipe.requirements)
		var/required_gas_moles = selected_recipe.requirements[gas_type]
		var/amount_consumed = required_gas_moles + (required_gas_moles * (quality_loss * 0.01))
		if(internal.get_moles(gas_type) < amount_consumed)
			quality_loss = min(quality_loss + 10, 100)
		internal.adjust_moles(gas_type, -amount_consumed)

	var/total_quality = clamp(50 - quality_loss, 0, 100)
	var/quality_control
	switch(total_quality)
		if(100)
			quality_control = "masterwork"
		if(95 to 99)
			quality_control = "supreme"
		if(75 to 94)
			quality_control = "good"
		if(65 to 74)
			quality_control = "decent"
		if(55 to 64)
			quality_control = "average"
		if(35 to 54)
			quality_control = "okay"
		if(15 to 34)
			quality_control = "poor"
		if(5 to 14)
			quality_control = "ugly"
		if(1 to 4)
			quality_control = "cracked"
		if(0)
			quality_control = "terrible"

	for(var/path in selected_recipe.products)
		var/amount_produced = selected_recipe.products[path]
		for(var/i in 1 to amount_produced)
			var/obj/creation = new path(get_step(src, SOUTH))
			creation.name = "[quality_control] [creation.name]"
			if(selected_recipe.dangerous)
				investigate_log("[selected_recipe.name] has been created in the crystallizer.", INVESTIGATE_SUPERMATTER)
				message_admins("[selected_recipe.name] has been created in the crystallizer [ADMIN_JMP(src)].")


	quality_loss = 0
	update_parents()

/obj/machinery/atmospherics/components/binary/crystallizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Crystallizer", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/crystallizer/ui_static_data()
	var/data = list()
	data["selected_recipes"] = list(list("name" = "Nothing", "id" = ""))
	for(var/path in GLOB.gas_recipe_meta)
		var/datum/gas_recipe/recipe = GLOB.gas_recipe_meta[path]
		if(recipe.machine_type != "Crystallizer")
			continue
		data["selected_recipes"] += list(list("name" = recipe.name, "id" = recipe.id))
	return data

/obj/machinery/atmospherics/components/binary/crystallizer/ui_data()
	var/data = list()
	data["on"] = on

	if(selected_recipe)
		data["selected"] = selected_recipe.id
	else
		data["selected"] = ""

	var/list/internal_gas_data = list()
	if(internal.total_moles())
		for(var/gasid in internal.get_gases())
			internal_gas_data.Add(list(list(
			"name"= GLOB.gas_data.names[gasid],
			"amount" = round(internal.get_moles(gasid), 0.01),
			"color" = GLOB.gas_data.ui_colors[gasid],
			)))
	else
		for(var/gasid in internal.get_gases())
			internal_gas_data.Add(list(list(
				"name"= GLOB.gas_data.names[gasid],
				"amount" = 0,
				"color" = GLOB.gas_data.ui_colors[gasid],
				)))
	data["internal_gas_data"] = internal_gas_data

	var/list/requirements
	if(!selected_recipe)
		requirements = list("Select a recipe to see the requirements")
	else
		requirements = list("To create [selected_recipe.name] you will need:")
		for(var/gas_type in selected_recipe.requirements)
			var/amount_consumed = selected_recipe.requirements[gas_type]
			requirements += "-[amount_consumed] moles of [GLOB.gas_data.names[gas_type]]"
		requirements += "In a temperature range between [selected_recipe.min_temp] K and [selected_recipe.max_temp] K"
		requirements += "The crystallization reaction will be [selected_recipe.energy_release ? (selected_recipe.energy_release > 0 ? "exothermic" : "endothermic") : "thermally neutral"]"
	data["requirements"] = requirements.Join("\n")

	var/temperature
	if(internal.total_moles())
		temperature = internal.return_temperature()
	else
		temperature = 0
	data["internal_temperature"] = temperature
	data["progress_bar"] = progress_bar
	data["gas_input"] = gas_input
	data["max_gas_input"] = max_gas_input
	return data

/obj/machinery/atmospherics/components/binary/crystallizer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("recipe")
			selected_recipe = null
			var/recipe_name = "nothing"
			var/datum/gas_recipe/recipe = GLOB.gas_recipe_meta[params["mode"]]
			if(internal.total_moles())
				dump_gases()
			quality_loss = 0
			progress_bar = 0
			if(recipe && recipe.id != "")
				selected_recipe = recipe
				recipe_name = recipe.name
				update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
				moles_calculations()
			investigate_log("was set to recipe [recipe_name ? recipe_name : "null"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("gas_input")
			var/_gas_input = params["gas_input"]
			gas_input = clamp(_gas_input, 0, max_gas_input)
			investigate_log("was set to [gas_input] by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/binary/crystallizer/update_layer()
	return

#undef MIN_PROGRESS_AMOUNT
#undef MIN_DEVIATION_RATE
#undef MAX_DEVIATION_RATE
#undef HIGH_CONDUCTIVITY_RATIO
