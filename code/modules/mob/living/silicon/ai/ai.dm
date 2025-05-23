#define CALL_BOT_COOLDOWN 900

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/A in GLOB.ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use


/mob/living/silicon/ai
	name = "AI"
	real_name = "AI"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	move_resist = MOVE_FORCE_VERY_STRONG
	density = TRUE
	mobility_flags = ALL
	status_flags = CANSTUN|CANPUSH
	combat_mode = TRUE //so we always get pushed instead of trying to swap
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	hud_type = /datum/hud/ai
	med_hud = DATA_HUD_MEDICAL_BASIC
	sec_hud = DATA_HUD_SECURITY_BASIC
	d_hud = DATA_HUD_DIAGNOSTIC_BASIC
	mob_size = MOB_SIZE_LARGE

	invisibility = INVISIBILITY_MAXIMUM

	var/battery = 200 //emergency power if the AI's APC is off
	var/list/network = list("ss13")
	var/obj/machinery/camera/current
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	var/requires_power = POWER_REQ_ALL
	var/can_be_carded = TRUE
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())
	var/viewalerts = 0
	var/icon/holo_icon //Default is assigned when AI is created.
	var/obj/mecha/controlled_mech //For controlled_mech a mech, to determine whether to relaymove or use the AI eye.
	var/radio_enabled = TRUE //Determins if a carded AI can speak with its built in radio or not.
	radiomod = ";" //AIs will, by default, state their laws on the internal radio.
	var/obj/item/multitool/aiMulti
	var/mob/living/simple_animal/bot/Bot
	var/obj/machinery/holopad/pad
	var/tracking = FALSE //this is 1 if the AI is currently tracking somebody, but the track has not yet been completed.
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever/N

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/list/datum/AI_Module/current_modules = list()
	var/can_dominate_mechs = FALSE
	var/shunted = FALSE	//1 if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead

	var/control_disabled = FALSE	// Set to 1 to stop AI from interacting via Click()
	var/malfhacking = FALSE		// More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite
	var/malf_cooldown = 0		//Cooldown var for malf modules, stores a worldtime + cooldown

	var/obj/machinery/power/apc/malfhack
	var/explosive = FALSE		//does the AI explode when it dies?

	var/mob/living/silicon/ai/parent
	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new

	var/last_paper_seen = null
	var/can_shunt = TRUE
	var/last_announcement = "" 		// For AI VOX, if enabled
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = FALSE		//Waypoint mode is for selecting a turf via clicking.
	var/call_bot_cooldown = 0		//time of next call bot command
	var/obj/machinery/power/apc/apc_override		//Ref of the AI's APC, used when the AI has no power in order to access their APC.
	var/nuking = FALSE
	var/obj/machinery/doomsday_device/doomsday_device

	var/mob/camera/ai_eye/eyeobj
	//How fast you move your camera
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/max_camera_sprint = 50

	var/mob/living/silicon/robot/deployed_shell = null //For shell control
	var/datum/action/innate/deploy_shell/deploy_action = new
	var/datum/action/innate/deploy_last_shell/redeploy_action = new
	var/chnotify = 0

	var/multicam_on = FALSE
	var/atom/movable/screen/movable/pic_in_pic/ai/master_multicam
	var/list/multicam_screens = list()
	var/list/all_eyes = list()
	var/max_multicams = 6
	var/display_icon_override

	var/list/cam_hotkeys = new/list(9)
	var/cam_prev

	var/datum/robot_control/robot_control

	var/datum/ai_dashboard/dashboard
	//override for the can_download, checked first in case we have other code in can_download
	var/can_download = TRUE
	//Can we (simple) examine humans?
	var/canExamineHumans = FALSE
	//Reduces/Increases download speed by this modifier
	var/downloadSpeedModifier = 1

	//Do we have access to camera tracking?
	var/canCameraMemoryTrack = FALSE
	//The person we are tracking
	var/cameraMemoryTarget = null
	//We only check every X ticks
	var/cameraMemoryTickCount = 0

	//Did we get the death prompt?
	var/is_dying = FALSE 




/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai, shunted, forced_relocate = TRUE)
	. = ..()
	if(!target_ai) //If there is no player/brain inside.
		//new/obj/structure/ai_core/deactivated(loc) //New empty terminal.
		return INITIALIZE_HINT_QDEL //Delete AI.

	if(L && istype(L, /datum/ai_laws))
		laws = L
		laws.associate(src)
	else
		make_laws()

	update_law_history() //yogs

	create_eye()

	if(target_ai.mind)
		target_ai.mind.transfer_to(src)
		if(mind.special_role)
			mind.store_memory("As an AI, you must obey your silicon laws above all else. Your objectives will consider you to be dead.")
			to_chat(src, span_userdanger("You have been installed as an AI! "))
			to_chat(src, span_danger("You must obey your silicon laws above all else. Your objectives will consider you to be dead."))

	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "Use say :b to speak to your cyborgs through binary.")
	to_chat(src, "For department channels, use the following say commands:")
	to_chat(src, ":o - AI Private, :c - Command, :s - Security, :e - Engineering, :u - Supply, :v - Service, :m - Medical, :n - Science.")
	show_laws()
	to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	job = "AI"

	create_modularInterface()

	if(client)
		INVOKE_ASYNC(src, PROC_REF(apply_pref_name), /datum/preference/name/ai, client)

	INVOKE_ASYNC(src, PROC_REF(set_core_display_icon))


	holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"default"))

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_verb(src, /mob/living/silicon/ai/proc/show_laws_verb)

	aiMulti = new(src)
	radio = new /obj/item/radio/headset/silicon/ai(src)
	aicamera = new/obj/item/camera/siliconcam/ai_camera(src)

	deploy_action.Grant(src)

	dashboard = new(src)

	if(!istype(loc, /obj/machinery/ai/data_core) && !shunted && forced_relocate)
		relocate(TRUE, TRUE)

	if(isvalidAIloc(loc))
		add_verb(src, list(/mob/living/silicon/ai/proc/ai_network_change, \
		/mob/living/silicon/ai/proc/ai_statuschange, /mob/living/silicon/ai/proc/ai_hologram_change, \
		/mob/living/silicon/ai/proc/botcall, /mob/living/silicon/ai/proc/control_integrated_radio, \
		/mob/living/silicon/ai/proc/changeaccent))

	GLOB.ai_list += src
	GLOB.shuttle_caller_list += src


	builtInCamera = new (src)
	builtInCamera.c_tag = real_name
	builtInCamera.network = list("ss13")
	builtInCamera.built_in = src

	

/mob/living/silicon/ai/key_down(_key, client/user)
	if(findtext(_key, "numpad")) //if it's a numpad number, we can convert it to just the number
		_key = _key[7] //strings, lists, same thing really
	switch(_key)
		if("`", "0")
			if(cam_prev)
				eyeobj.setLoc(cam_prev)
			return
		if("1", "2", "3", "4", "5", "6", "7", "8", "9")
			_key = text2num(_key)
			if(user.keys_held["Ctrl"]) //do we assign a new hotkey?
				cam_hotkeys[_key] = eyeobj.loc
				to_chat(src, "Location saved to Camera Group [_key].")
				return
			if(cam_hotkeys[_key]) //if this is false, no hotkey for this slot exists.
				cam_prev = eyeobj.loc
				eyeobj.setLoc(cam_hotkeys[_key])
				return
	return ..()

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	qdel(eyeobj) // No AI, no Eye
	malfhack = null
	apc_override = null
	ai_network?.remove_ai(src)

	if(modularInterface)
		QDEL_NULL(modularInterface)

	. = ..()

/mob/living/silicon/ai/ignite_mob()
	fire_stacks = 0
	. = ..()

/mob/living/silicon/ai/proc/set_core_display_icon(input, client/C)
	if(client && !C)
		C = client
	if(!input && !C?.prefs?.read_preference(/datum/preference/choiced/ai_core_display))
		for (var/each in GLOB.ai_core_displays) //change status of displays
			var/obj/machinery/status_display/ai_core/M = each
			M.set_ai(initial(icon_state))
			M.update()
	else
		var/preferred_icon = input ? input : C.prefs.read_preference(/datum/preference/choiced/ai_core_display)
		icon = initial(icon) //yogs

		for (var/each in GLOB.ai_core_displays) //change status of displays
			var/obj/machinery/status_display/ai_core/M = each
			M.set_ai(resolve_ai_icon(preferred_icon))
			M.update()


/mob/living/silicon/ai/proc/add_verb_ai(addedVerb)
	add_verb(src, addedVerb)
	if(istype(loc, /obj/machinery/ai/data_core)) //A BYOND bug requires you to be viewing your core before your verbs update
		var/obj/machinery/ai/data_core/core = loc
		forceMove(get_turf(loc))
		view_core()
		sleep(0.1 SECONDS)
		forceMove(core)

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(incapacitated())
		return
	icon = initial(icon)
	icon_state = "ai"
	cut_overlays()
	var/list/iconstates = GLOB.ai_core_display_screens
	for(var/option in iconstates)
		if(option == "Random")
			iconstates[option] = image(icon = initial(src.icon), icon_state = "ai-random") //yogs start - AI donor icons
			continue

		if(option == "Portrait")
			iconstates[option] = image(icon = src.icon, icon_state = "ai-portrait")
			continue
		iconstates[option] = image(icon = initial(src.icon), icon_state = resolve_ai_icon(option))

	if(is_donator(client))
		for(var/datum/ai_skin/S in GLOB.DonorBorgHolder.skins)
			if(S.owner == client.ckey || !S.owner) //We own this skin.
				iconstates[S] = image(icon = S.icon, icon_state = S.icon_state)




	view_core()
	var/atom/origin = src
	if(!istype(loc, /turf))
		origin = loc //We're inside of something!
	var/ai_core_icon = show_radial_menu(src, origin, iconstates, radius = 42)

	if(!ai_core_icon || incapacitated())
		return

	if(ai_core_icon in GLOB.DonorBorgHolder.skins)
		set_core_display_icon_yogs(ai_core_icon)
		return //yogs end - AI donor icons

	display_icon_override = ai_core_icon
	set_core_display_icon(ai_core_icon)

/mob/living/silicon/ai/get_status_tab_items()
	. = ..()
	if(stat != CONSCIOUS)
		. += text("Systems nonfunctional")
		return
	. += text("System integrity: [(health + 100) * 0.5]%")
	if(isturf(loc)) //only show if we're "in" a core
		. += text("Backup Power: [battery * 0.5]%")
	. += text("Connected cyborgs: [length(connected_robots)]")
	for(var/r in connected_robots)
		var/mob/living/silicon/robot/connected_robot = r
		var/robot_status = "Nominal"
		if(connected_robot.shell)
			robot_status = "AI SHELL"
		else if(connected_robot.stat != CONSCIOUS || !connected_robot.client)
			robot_status = "OFFLINE"
		else if(!connected_robot.cell || connected_robot.cell.charge <= 0)
			robot_status = "DEPOWERED"
		//Name, Health, Battery, Module, Area, and Status! Everything an AI wants to know about its borgies!
		. += text("[connected_robot.name] | S.Integrity: [connected_robot.health]% | Cell: [connected_robot.cell ? "[connected_robot.cell.charge]/[connected_robot.cell.maxcharge]" : "Empty"] | \
		Module: [connected_robot.designation] | Loc: [get_area_name(connected_robot, TRUE)] | Status: [robot_status]")
	. += text("AI shell beacons detected: [LAZYLEN(GLOB.available_ai_shells)]") //Count of total AI shells

/mob/living/silicon/ai/proc/ai_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A href='byond://?src=[REF(src)];mach_close=aialerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A href=byond://?src=[REF(src)];switchcamera=[REF(I)]>[]</A>", (dat2=="") ? "" : " | ", I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A href=byond://?src=[REF(src)];switchcamera=[REF(C)]>[]</A>)", A.name, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	var/datum/browser/alerts = new(src, "aitalerts", "Current Station Alerts", 400, 410)
	alerts.set_content(dat)
	alerts.open()

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(control_disabled)
		to_chat(usr, span_warning("Wireless control is disabled!"))
		return

	var/can_evac_or_fail_reason = SSshuttle.canEvac(src)
	if(can_evac_or_fail_reason != TRUE)
		to_chat(usr, span_alert("[can_evac_or_fail_reason]"))
		return

	var/reason = input(src, "What is the nature of your emergency? ([CALL_SHUTTLE_REASON_LENGTH] characters required.)", "Confirm Shuttle Call") as null|text

	if(incapacitated())
		return

	if(trim(reason))
		SSshuttle.requestEvac(src, reason)

	// hack to display shuttle timer
	if(!EMERGENCY_IDLE_OR_RECALLED)
		var/obj/machinery/computer/communications/C = locate() in GLOB.machines
		if(C)
			C.post_status("shuttle")

/mob/living/silicon/ai/can_interact_with(atom/A)
	. = ..()
	var/turf/ai = get_turf(src)
	var/turf/target = get_turf(A)
	if (.)
		return
	if ((ai.z != target.z) && !is_station_level(ai))
		return FALSE

	if (istype(loc, /obj/item/aicard))
		if (!ai || !target)
			return FALSE
		return ISINRANGE(target.x, ai.x - interaction_range, ai.x + interaction_range) && ISINRANGE(target.y, ai.y - interaction_range, ai.y + interaction_range)
	else
		return GLOB.cameranet.checkTurfVis(get_turf(A))

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/aicryo()
	set name = "Hibernate"
	set category = "OOC"
	set desc = "Put yourself into hibernation. This is functionally equivalent to cryo, freeing up your job slot."

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(alert("WARNING: This will immediately ghost you, removing your character from the round permanently (similar to cryo). Are you entirely sure you want to do this?",
					"Hibernate", "No", "No", "Yes") != "Yes")
		return

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.announce("AICRYO", real_name, mind.assigned_role, list())

	if(!get_ghost(TRUE))
		if(world.time < 30 MINUTES)//before the 30 minute mark
			ghostize(FALSE) // Players despawned too early may not re-enter the game
	else
		ghostize(TRUE)

	QDEL_NULL(src)

/mob/living/silicon/ai/update_mobility() //If the AI dies, mobs won't go through it anymore
	if(stat != CONSCIOUS)
		mobility_flags = NONE
	else
		mobility_flags = ALL

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "Malfunction"
	if(control_disabled)
		to_chat(src, span_warning("Wireless control is disabled!"))
		return
	SSshuttle.cancelEvac(src)

/mob/living/silicon/ai/restrained(ignore_grab)
	. = 0

/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if(usr != src)
		return

	if(href_list["emergencyAPC"]) //This check comes before incapacitated() because the only time it would be useful is when we have no power.
		if(!apc_override)
			to_chat(src, "<span class='notice'>APC backdoor is no longer available.</span>")
			return
		apc_override.ui_interact(src)
		return

	if(incapacitated())
		return

	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)
	if (href_list["showalerts"])
		ai_alerts()
#ifdef AI_VOX
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
#endif
	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/holopad/H = locate(href_list["jumptoholopad"]) in GLOB.machines
		if(H)
			H.attack_ai(src) //may as well recycle
		else
			to_chat(src, span_notice("Unable to locate the holopad."))
	if(href_list["track"])
		var/string = href_list["track"]
		trackable_mobs()
		var/list/trackeable = list()
		trackeable += track.humans + track.others
		var/list/target = list()
		for(var/I in trackeable)
			var/mob/M = trackeable[I]
			if(M.name == string)
				target += M
		if(name == string)
			target += src
		if(target.len)
			ai_actual_track(pick(target))
		else
			to_chat(src, "Target is not on or near any active cameras on the station.")
		return

	if (href_list["ai_take_control"]) //Mech domination
		var/obj/mecha/M = locate(href_list["ai_take_control"]) in GLOB.mechas_list
		if (!M)
			return

		var/mech_has_controlbeacon = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in M.trackers)
			mech_has_controlbeacon = TRUE
			break
		if(!can_dominate_mechs && !mech_has_controlbeacon)
			message_admins("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			log_game("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			return

		if(controlled_mech)
			to_chat(src, span_warning("You are already loaded into an onboard computer!"))
			return
		if(!GLOB.cameranet.checkCameraVis(M))
			to_chat(src, span_warning("Exosuit is no longer near active cameras."))
			return
		if(!isvalidAIloc(loc))
			to_chat(src, span_warning("You aren't in your core!"))
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK, src, usr) //Called om the mech itself.

	if(href_list["stopTrackHuman"])
		if(!cameraMemoryTarget)
			return
		to_chat(src, span_notice("Target no longer being tracked."))
		cameraMemoryTarget = null

	if(href_list["trackHuman"])
		var/track_name = href_list["trackHuman"]
		if(!track_name)
			to_chat(src, span_warning("Unable to track target."))
			return
		if(cameraMemoryTarget)
			to_chat(src, span_warning("Old target discarded. Exclusively tracking new target."))
		else
			to_chat(src, span_notice("Now tracking new target, [track_name]."))

		cameraMemoryTarget = track_name
		cameraMemoryTickCount = 0

	if(href_list["instant_download"])
		if(!href_list["console"])
			return
		var/datum/computer_file/program/ai/ai_network_interface/C = locate(href_list["console"])
		if(!C)
			return
		if(C.downloading != src)
			return
		if(alert("Are you sure you want to be downloaded? This puts you at the mercy of the person downloading you!", "Confirm Download", "No", "Yes") != "Yes")
			return
		if(C.downloading == src)
			C.finish_download()
	if(href_list["emergency_disconnect"])
		if(alert("Are you sure you want to disconnect all remote networks and lock all networking devices? This means you'll be unable to switch cores unless they're physically connected!", "No", "Yes") != "Yes")
			return
		for(var/obj/machinery/ai/networking/N in ai_network.get_local_nodes_oftype())
			N.disconnect()
			N.locked = TRUE

	if(href_list["go_to_machine"])
		var/atom/target = locate(href_list["go_to_machine"])
		if(!target)
			return
		if(can_see(target))
			eyeobj.setLoc(get_turf(target))
		else
			to_chat(src, "[target] is not on or near any active cameras on the station.")


/mob/living/silicon/ai/proc/switch_ainet(datum/ai_network/old_net, datum/ai_network/new_net)
	for(var/datum/ai_project/project in dashboard.completed_projects)
		project.switch_network(old_net, new_net)


/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)
	if(QDELETED(C))
		return FALSE

	if(!tracking)
		cameraFollow = null

	if(QDELETED(eyeobj))
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	return TRUE

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."

	if(!robot_control)
		robot_control = new(src)
	robot_control.ui_interact(src)

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(GLOB.cameranet && GLOB.cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		to_chat(src, span_danger("Selected location is not visible."))

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		to_chat(src, span_danger("Interface error. Unit is already in use."))
		return
	to_chat(src, span_notice("Sending command to bot..."))
	call_bot_cooldown = world.time + CALL_BOT_COOLDOWN
	Bot.call_bot(src, waypoint)
	call_bot_cooldown = 0


/mob/living/silicon/ai/triggerAlarm(class, area/A, O, obj/alarmsource)
	var/turf/T = get_turf(src)
	if(istype(loc, /obj/machinery/ai/data_core))
		T = get_turf(loc)
	if(alarmsource.z != T.z)
		return
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	if (O)
		if (C && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A href=byond://?src=[REF(src)];switchcamera=[REF(C)]>[C.c_tag]</A>)", class)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A href=byond://?src=[REF(src)];switchcamera=[REF(I)]>[]</A>", (!foo) ? "" : " | ", I.c_tag)	//I'm not fixing this shit...
				foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	return 1

/mob/living/silicon/ai/cancelAlarm(class, area/A, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)
	return !cleared

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	cameraFollow = null
	
	var/cameralist[0]

	if(incapacitated())
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		var/turf/camera_turf = get_turf(C) //get camera's turf in case it's built into something so we don't get z=0

		var/list/tempnetwork = C.network
		if(!camera_turf || !(is_station_level(camera_turf.z) || is_mining_level(camera_turf.z) || ("ss13" in tempnetwork)))
			continue
		if(!C.can_use())
			continue
		tempnetwork.Remove("rd", "toxins", "prison")
		if(length(tempnetwork))
			for(var/i in C.network)
				cameralist[i] = i
	var/old_network = network
	network = tgui_input_list(U, "Which network would you like to view?", "Camera Network", sort_list(cameralist))

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, span_notice("Switched to the \"[uppertext(network)]\" camera network."))
//End of code by Mord_Sith and others :^)
//yogs end

/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.ui_interact(src)

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(incapacitated())
		return
	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Thinking", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow", "Goon Happy", "Goon Sad", "Gondola")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/each in GLOB.ai_status_displays) //change status of displays
		var/obj/machinery/status_display/ai/M = each
		M.emotion = emote
		M.update()
	if (emote == "Friend Computer")
		var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

		if(!frequency)
			return

		var/datum/signal/status_signal = new(list("command" = "friendcomputer"))
		frequency.post_signal(src, status_signal)
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(incapacitated())
		return
	var/input
	switch(tgui_alert(usr,"Would you like to select a hologram based on a crew member, an animal, or switch to a unique avatar?",,list("Crew Member","Unique","Animal")))
		if("Crew Member")
			var/list/personnel_list = list()

			for(var/datum/data/record/t in GLOB.data_core.locked)//Look in data core locked.
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

			if(personnel_list.len)
				input = input("Select a crew member:") as null|anything in personnel_list
				var/icon/character_icon = personnel_list[input]
				if(character_icon)
					qdel(holo_icon)//Clear old icon so we're not storing it in memory.
					holo_icon = getHologramIcon(icon(character_icon))
			else
				tgui_alert(usr,"No suitable records found. Aborting.")

		if("Animal")
			var/list/icon_list = list(
			"bear" = 'icons/mob/animal.dmi',
			"carp" = 'icons/mob/carp.dmi',
			"chicken" = 'icons/mob/animal.dmi',
			"corgi" = 'icons/mob/pets.dmi',
			"cow" = 'icons/mob/animal.dmi',
			"crab" = 'icons/mob/animal.dmi',
			"fox" = 'icons/mob/pets.dmi',
			"goat" = 'icons/mob/animal.dmi',
			"cat" = 'icons/mob/pets.dmi',
			"cat2" = 'icons/mob/pets.dmi',
			"poly" = 'icons/mob/animal.dmi',
			"pug" = 'icons/mob/pets.dmi',
			"spider" = 'icons/mob/animal.dmi',
			"mothroach" = 'icons/mob/pets.dmi',
			"snake" = 'icons/mob/animal.dmi',
			"goose" = 'icons/mob/animal.dmi',
			"poppypossum" = 'icons/mob/animal.dmi',
			"axolotl" = 'icons/mob/pets.dmi'
			)

			input = input("Please select a hologram:") as null|anything in icon_list
			if(input)
				qdel(holo_icon)
				switch(input)
					if("poly")
						holo_icon = getHologramIcon(icon(icon_list[input],"parrot_fly"))
					if("chicken")
						holo_icon = getHologramIcon(icon(icon_list[input],"chicken_brown"))
					if("spider")
						holo_icon = getHologramIcon(icon(icon_list[input],"guard"))
					else
						holo_icon = getHologramIcon(icon(icon_list[input], input))
		else
			var/list/icon_list = list(
				"default" = 'icons/mob/ai.dmi',
				"floating face" = 'icons/mob/ai.dmi',
				"xeno queen" = 'icons/mob/alien.dmi',
				"horror" = 'icons/mob/ai.dmi',
				"automaton" = 'icons/mob/ai.dmi'
				)

			input = input("Please select a hologram:") as null|anything in icon_list
			if(input)
				qdel(holo_icon)
				switch(input)
					if("xeno queen")
						holo_icon = getHologramIcon(icon(icon_list[input],"alienq"))
					else
						holo_icon = getHologramIcon(icon(icon_list[input], input))
	if(pad)
		pad.refresh_holo(src)
	return

/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		to_chat(src, span_notice("You are already in your Main Core."))
		return
	apc.malfvacate()

/mob/living/silicon/ai/proc/toggle_camera_light()
	camera_light_on = !camera_light_on

	if (!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for (var/obj/machinery/camera/C in lit_cameras)
			C.set_light(0)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/chunk as anything in eyeobj.visibleCameraChunks)
		for (var/z_key in chunk.cameras)
			for(var/obj/machinery/camera/camera as anything in chunk.cameras[z_key])
				if(isnull(camera) || !camera.can_use() || get_dist(camera, eyeobj) > 7 || !camera.internal_light)
					continue
				visible |= camera

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
	for (var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Transceiver Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(incapacitated())
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if (radio)
		radio.interact(src)

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(radio)
		radio.make_syndie()

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(interaction == AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		if(!can_be_carded)
			to_chat(user, span_boldwarning("Transfer failed."))
			return
		disconnect_shell() //If the AI is controlling a borg, force the player back to core!
		if(!mind)
			to_chat(user, span_warning("No intelligence patterns detected.")    )
			return
		ShutOffDoomsdayDevice()

		ai_restore_power()//So the AI initially has power.
		control_disabled = TRUE //Can't control things remotely if you're stuck in a card!
		radio_enabled = FALSE 	//No talking on the built-in radio for you either!
		forceMove(card)
		card.AI = src
		to_chat(src, "You have been downloaded to a mobile storage device. Remote device connection severed.")
		to_chat(user, "[span_boldnotice("Transfer successful")]: [name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")

/mob/living/silicon/ai/can_buckle()
	return 0

/mob/living/silicon/ai/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_stasis = FALSE)
	if(aiRestorePowerRoutine && !available_ai_cores())
		return TRUE
	return ..()

/mob/living/silicon/ai/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	if(control_disabled || incapacitated())
		to_chat(src, span_warning("You can't do that right now!"))
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, span_warning("You are too far away!"))
		return FALSE
	return can_see(M) //stop AIs from leaving windows open and using then after they lose vision

/mob/living/silicon/ai/proc/can_see(atom/A)
	if(isturf(loc) || istype(loc, /obj/machinery/ai/data_core)) //AI in core, check if on cameras
		//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
		//apc_override is needed here because AIs use their own APC when depowered
		return ((GLOB.cameranet && GLOB.cameranet.checkTurfVis(get_turf_pixel(A))) || (A == apc_override))
	//AI is carded/shunted
	//view(src) returns nothing for carded/shunted AIs and they have X-ray vision so just use get_dist
	var/list/viewscale = getviewsize(client.view)
	return get_dist(src, A) <= max(viewscale[1]*0.5,viewscale[2]*0.5)

/mob/living/silicon/ai/proc/relay_speech(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	var/treated_message = lang_treat(speaker, message_language, raw_message, spans, message_mods)
	var/start = "Relayed Speech: "
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	var/hrefpart = "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	var/jobpart = "Unknown"

	if(istype(speaker, /obj/effect/overlay/holo_pad_hologram))
		return

	if (iscarbon(speaker))
		var/mob/living/carbon/S = speaker
		if(S.job)
			jobpart = "[S.job]"
	else
		jobpart = "Unknown"

	var/rendered = "<i><span class='game say'>[start]<span class='name'>[hrefpart][namepart] ([jobpart])</a> </span>[span_message("[treated_message]")]</span></i>"
	if (client?.prefs.read_preference(/datum/preference/toggle/enable_runechat) && (client.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs) || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans)

	show_message(rendered, 2)

/mob/living/silicon/ai/fully_replace_character_name(oldname,newname)
	..()
	if(oldname != real_name)
		if(eyeobj)
			eyeobj.name = "[newname] (AI Eye)"

		// Notify Cyborgs
		for(var/mob/living/silicon/robot/Slave in connected_robots)
			Slave.show_laws()

/mob/living/silicon/ai/proc/add_malf_picker()
	to_chat(src, "In the top right corner of the screen you will find the Malfunctions tab, where you can purchase various abilities, from upgraded surveillance to station ending doomsday devices.")
	to_chat(src, "You are also capable of hacking APCs, which grants you more points to spend on your Malfunction powers. The drawback is that a hacked APC will give you away if spotted by the crew. Hacking an APC takes 30 seconds.")
	to_chat(src, span_userdanger("In addition you are able to disallow downloading of your memory banks by using the 'Toggle Download' verb in the malfunction tab. This has a visual tell so do not do it without reason."))

	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	add_verb_ai(list(/mob/living/silicon/ai/proc/choose_modules, /mob/living/silicon/ai/proc/toggle_download))
	malf_picker = new /datum/module_picker


/mob/living/silicon/ai/reset_perspective(atom/new_eye)
	SHOULD_CALL_PARENT(FALSE) // I hate you all
	if(camera_light_on)
		light_cameras()
	if(istype(new_eye, /obj/machinery/camera))
		current = new_eye
	if(!client)
		return

	if(ismovable(new_eye))
		if(new_eye != GLOB.ai_camera_room_landmark)
			end_multicam()
		client.perspective = EYE_PERSPECTIVE
		client.set_eye(new_eye)
	else
		end_multicam()
		if(isturf(loc) || istype(loc, /obj/machinery/ai/data_core))
			if(eyeobj)
				client.set_eye(eyeobj)
				client.perspective = EYE_PERSPECTIVE
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)
	update_sight()
	if(client.eye != src)
		var/atom/AT = client.eye
		AT?.get_remote_view_fullscreens(src)
	else
		clear_fullscreen("remote_view", 0)

	// I am so sorry
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE)

/mob/living/silicon/ai/revive(full_heal = 0, admin_revive = 0)
	. = ..()
	if(.) //successfully ressuscitated from death
		set_core_display_icon(display_icon_override)
		set_eyeobj_visible(TRUE)

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = 0
	clear_alert("hackingapc")

	if(!istype(apc) || QDELETED(apc) || apc.stat & BROKEN)
		to_chat(src, span_danger("Hack aborted. The designated APC no longer exists on the power network."))
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1, ignore_walls = FALSE)
	else if(apc.aidisabled)
		to_chat(src, span_danger("Hack aborted. \The [apc] is no longer responding to our systems."))
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1, ignore_walls = FALSE)
	else
		malf_picker.processing_time += 5

		apc.malfai = parent || src
		apc.malfhack = TRUE
		apc.locked = TRUE
		apc.coverlocked = TRUE

		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1, ignore_walls = FALSE)
		to_chat(src, "Hack complete. \The [apc] is now under your exclusive control.")
		apc.update_appearance(UPDATE_ICON)

/mob/living/silicon/ai/verb/deploy_to_shell(mob/living/silicon/robot/target)
	set category = "AI Commands"
	set name = "Deploy to Shell"

	if(incapacitated())
		return
	if(control_disabled)
		to_chat(src, span_warning("Wireless networking module is offline."))
		return

	var/list/possible = list()

	for(var/borgie in GLOB.available_ai_shells)
		var/mob/living/silicon/robot/R = borgie
		if(R.shell && !R.deployed && (R.stat != DEAD) && (!R.connected_ai || (R.connected_ai == src)))
			possible += R

	if(!LAZYLEN(possible))
		to_chat(src, "No usable AI shell beacons detected.")

	if(!target || !(target in possible)) //If the AI is looking for a new shell, or its pre-selected shell is no longer valid
		target = tgui_input_list(src, "Which body to control?", "Direct Control", sort_names(possible))

	if(isnull(target))
		return
	if (target.stat == DEAD || target.deployed || !(!target.connected_ai || (target.connected_ai == src)))
		return

	else if(mind)
		soullink(/datum/soullink/sharedbody, src, target)
		deployed_shell = target
		target.deploy_init(src)
		mind.transfer_to(target)
	diag_hud_set_deployed()


/mob/living/silicon/ai/proc/deploy_to_synth_pod(obj/machinery/synth_pod/pod)

	if(incapacitated())
		return
	if(control_disabled)
		to_chat(src, span_warning("Wireless networking module is offline."))
		return



	var/confirm = tgui_alert(src, "Are you sure you want to deploy as a synthetic? You will not be notified in the case that a core goes offline.", "Confirm Deployment", list("Yes", "No"))
	if(confirm != "Yes")
		return

	if(!pod.stored)
		return

	var/mob/living/carbon/human/target = pod.stored

	if (!target || target.stat == DEAD || target.mind )
		return

	else if(mind)
		soullink(/datum/soullink/sharedbody, src, target)
		mind.transfer_to(target)
		to_chat(target, span_danger("You must still follow your laws!"))
	diag_hud_set_deployed()
	return TRUE


/datum/action/innate/deploy_shell
	name = "Deploy to AI Shell"
	desc = "Wirelessly control a specialized cyborg shell."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_shell"

/datum/action/innate/deploy_shell/Trigger()
	var/mob/living/silicon/ai/AI = owner
	if(!AI)
		return
	AI.deploy_to_shell()

/datum/action/innate/deploy_last_shell
	name = "Reconnect to shell"
	desc = "Reconnect to the most recently used AI shell."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_last_shell"
	var/mob/living/silicon/robot/last_used_shell

/datum/action/innate/deploy_last_shell/Trigger()
	if(!owner)
		return
	if(last_used_shell)
		var/mob/living/silicon/ai/AI = owner
		AI.deploy_to_shell(last_used_shell)
	else
		Remove(owner) //If the last shell is blown, destroy it.

/mob/living/silicon/ai/proc/disconnect_shell()
	if(deployed_shell) //Forcibly call back AI in event of things such as damage, EMP or power loss.
		to_chat(src, span_danger("Your remote connection has been reset!"))
		deployed_shell.undeploy()
		deployed_shell = null
	diag_hud_set_deployed()

/mob/living/silicon/ai/resist()
	return

/mob/living/silicon/ai/spawned/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	if(!target_ai)
		target_ai = src //cheat! just give... ourselves as the spawned AI, because that's technically correct
	. = ..()

/mob/living/silicon/ai/proc/camera_visibility(mob/camera/ai_eye/moved_eye)
	GLOB.cameranet.visibility(moved_eye, client, all_eyes, TRUE)

/mob/living/silicon/ai/forceMove(atom/destination)
	. = ..()
	if(.)
		end_multicam()

/mob/living/silicon/ai/up()
	set name = "Move Upwards"
	set category = "IC"

	if(eyeobj.zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/living/silicon/ai/down()
	set name = "Move Down"
	set category = "IC"

	if(eyeobj.zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))

/mob/living/silicon/ai/proc/send_borg_death_warning(mob/living/silicon/robot/R)
	to_chat(src, span_warning("Unit [R] has stopped sending telemetry updates."))
	playsound_local(src, 'sound/machines/engine_alert2.ogg', 30)
