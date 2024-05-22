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
	//If a display message can be replaced by code
	var/replace_message = TRUE
	//Sound to play
	var/keypad_sound = 'sound/machines/terminal_select.ogg'

/obj/item/storage/secureTGUI/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/storage/secureTGUI/ui_interact(mob/user, datum/tgui/ui) //Thanks for the help with TGUI chubby
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecureTGUI", name + "'s keypad")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/storage/secureTGUI/ui_data(mob/user)
	var/list/data = list()
	data["lock_status_display"] = "Lock Status: " + lock_display
	data["keypad_code_display"] = keypad_input
	return data

/obj/item/storage/secureTGUI/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "keypad")
		var/digit = params["digit"]
		switch(digit)
			if("0","1","2","3","4","5","6","7","8","9")
				//No input when an error exists
				if(!error_message)
					if(replace_message == TRUE)
						keypad_input = digit
						replace_message = FALSE
					else
						keypad_input += digit
					//Throw an error if too many digits
					if(length(keypad_input) > 5)
						keypad_input = "ERROR: TOO MANY DIGITS"
						error_message = TRUE
					. = TRUE
			if("E")
				//Only allow if there is no error message
				if(!error_message)
					//Make input the access code if there is none and it meets criteria
					if(access_code == "" && length(keypad_input) == 5)
						access_code = keypad_input
						keypad_input = "*****"
						. = TRUE
					//Code too short
					else if(length(keypad_input) < 5)
						keypad_input = "ERROR: TOO FEW DIGITS"
						error_message = TRUE
					//Wrong code
					else if(keypad_input != access_code)
						keypad_input = "ERROR: WRONG CODE"
						error_message = TRUE
					//Correct code
					else if(keypad_input == access_code)
						keypad_input = "*****"
						//Unlock if locked
						if(lock_status)
							lock_status = FALSE
							lock_display = "UNLOCKED"
						. = TRUE
			//Reset current code
			if("R")
				keypad_input = "INPUT 5 DIGIT CODE"
				error_message = FALSE
				replace_message = TRUE
				lock_status = TRUE
				lock_display = "LOCKED"
				. = TRUE
		//Play appropriate sound
		if(error_message)
			keypad_sound = 'sound/machines/terminal_prompt_deny.ogg'
		else if(keypad_input == "*****")
			keypad_sound = 'sound/machines/terminal_prompt_confirm.ogg'
		else
			keypad_sound = 'sound/machines/terminal_select.ogg'
		playsound(src, keypad_sound, 10, FALSE)
