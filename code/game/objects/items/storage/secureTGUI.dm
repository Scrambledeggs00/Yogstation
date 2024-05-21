/obj/item/storage/secureTGUI
	name = "secstorage"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "This shouldn't exist. If it does, create an issue report."

	//What the user inputed
	var/keypad_input = "INPUT NEW 5 DIGIT CODE"
	//Keypad's code
	var/access_code = ""
	//If the item is locked or not
	var/lock_status = FALSE
	//What shows in lock_status_display
	var/lock_display = "UNLOCKED"
	//If there is an error message
	var/error_message = FALSE

/obj/item/storage/secureTGUI/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/storage/secureTGUI/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, name + "'s keypad")
	if(!ui)
		ui = new(user, src, "SecureTGUI")
		ui.open()

/obj/item/storage/secureTGUI/ui_data(mob/user)
	var/list/data = list()
	data["lock_status_display"] = "Lock Status: " + lock_display
	data["keypad_code_display"] = keypad_input
	return data

/obj/item/storage/secureTGUI/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "enter_code")
		//Make input the access code if there is none and it meets criteria
		if(access_code == "" && length(keypad_input) == 5)
			access_code = keypad_input
			keypad_input = "*****"
		//Code too short
		else if(length(keypad_input) != 5)
			keypad_input = "ERROR: NOT A 5 DIGIT CODE"
			error_message = TRUE
			return FALSE
		//Wrong code
		else if(keypad_input != access_code)
			keypad_input = "ERROR: WRONG CODE"
			error_message = TRUE
			return FALSE
		//Correct code
		else if(keypad_input == access_code)
			keypad_input = "*****"
			//Unlock if locked
			if(lock_status)
				lock_status = FALSE
				lock_display = "UNLOCKED"
		. = TRUE
	if(action == "reset_code")
		keypad_input = ""
		error_message = FALSE
		lock_status = TRUE
		lock_display = "LOCKED"
		. = TRUE
	update_icon()

			
			

