/datum/saymode
	var/key
	var/mode
	var/bypass_mute = FALSE

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE


/datum/saymode/changeling
	key = MODE_KEY_CHANGELING
	mode = MODE_CHANGELING

/datum/saymode/changeling/handle_message(mob/living/user, message, datum/language/language)
	if(ismob(user.pulledby) && IS_CHANGELING(user.pulledby) && user.pulledby.grab_state >= GRAB_NECK)
		to_chat(user, span_warning("Our abilities are being dampened! We cannot speak through the hivemind!"))
		return FALSE
	switch(user.lingcheck())
		if(LINGHIVE_LINK)
			var/msg = span_changeling("<b>[user.mind]:</b> [message]")
			for(var/_M in GLOB.player_list)
				var/mob/M = _M
				if(M in GLOB.dead_mob_list)
					var/link = FOLLOW_LINK(M, user)
					to_chat(M, "[link] [msg]")
				else
					switch(M.lingcheck())
						if (LINGHIVE_LING)
							var/mob/living/L = M
							if (!HAS_TRAIT(L, CHANGELING_HIVEMIND_MUTE))
								to_chat(M, msg)
						if(LINGHIVE_LINK)
							to_chat(M, msg)
						if(LINGHIVE_OUTSIDER)
							if(prob(40))
								to_chat(M, span_changeling("We can faintly sense an outsider trying to communicate through the hivemind..."))
		if(LINGHIVE_LING)
			if (HAS_TRAIT(user, CHANGELING_HIVEMIND_MUTE))
				to_chat(user, span_warning("The poison in the air hinders our ability to interact with the hivemind."))
				return FALSE
			var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
			var/msg = span_changeling("<b>[changeling.changelingID]:</b> [message]")
			user.log_talk(message, LOG_SAY, tag="changeling [changeling.changelingID]")
			for(var/_M in GLOB.player_list)
				var/mob/M = _M
				if(M in GLOB.dead_mob_list)
					var/link = FOLLOW_LINK(M, user)
					to_chat(M, "[link] [msg]")
				else
					switch(M.lingcheck())
						if(LINGHIVE_LINK)
							to_chat(M, msg)
						if(LINGHIVE_LING)
							var/mob/living/L = M
							if (!HAS_TRAIT(L, CHANGELING_HIVEMIND_MUTE))
								to_chat(M, msg)
						if(LINGHIVE_OUTSIDER)
							if(prob(40))
								to_chat(M, span_changeling("We can faintly sense another of our kind trying to communicate through the hivemind..."))
		if(LINGHIVE_OUTSIDER)
			to_chat(user, span_changeling("Our senses have not evolved enough to be able to communicate this way..."))
	return FALSE


/datum/saymode/xeno
	key = "a"
	mode = MODE_ALIEN

/datum/saymode/xeno/handle_message(mob/living/user, message, datum/language/language)
	if(user.hivecheck())
		user.alien_talk(message)
	return FALSE


/datum/saymode/vocalcords
	key = MODE_KEY_VOCALCORDS
	mode = MODE_VOCALCORDS

/datum/saymode/vocalcords/handle_message(mob/living/user, message, datum/language/language)
	return TRUE //Yogs -- This is handled in a refactored, special-snowflake way someplace else,
	// because most of vocalcord code is to resolve commands, which must evade accent code


/datum/saymode/binary //everything that uses .b (silicons, drones, blobbernauts/spores, swarmers)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY

/datum/saymode/binary/handle_message(mob/living/user, message, datum/language/language)
	if(isswarmer(user))
		var/mob/living/simple_animal/hostile/swarmer/S = user
		S.swarmer_chat(message)
		return FALSE
	if(isblobmonster(user))
		var/mob/living/simple_animal/hostile/blob/B = user
		B.blob_chat(message)
		return FALSE
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		D.drone_chat(message)
		return FALSE
	if(user.binarycheck())
		user.robot_talk(message)
		return FALSE
	return FALSE


/datum/saymode/holopad
	key = MODE_KEY_HOLOPAD
	mode = MODE_HOLOPAD

/datum/saymode/holopad/handle_message(mob/living/user, message, datum/language/language)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		AI.holopad_talk(message, language)
		return FALSE
	return TRUE

/datum/saymode/darkspawn //yogs: darkspawn
	key = MODE_KEY_DARKSPAWN
	mode = MODE_DARKSPAWN
	bypass_mute = TRUE //it's mentally talking, not physically

/datum/saymode/darkspawn/handle_message(mob/living/user, message, datum/language/language)
	var/datum/mind = user.mind
	if(!mind)
		return TRUE
	if(is_team_darkspawn(user))
		user.log_talk(message, LOG_SAY, tag="darkspawn")
		var/msg = span_velvet("<b>\[Mindlink\] [user.real_name]:</b> \"[message]\"")
		for(var/mob/M in GLOB.player_list)
			if(M in GLOB.dead_mob_list)
				var/link = FOLLOW_LINK(M, user)
				to_chat(M, "[link] [msg]")
			else if(is_team_darkspawn(M))
				to_chat(M, msg)
	return FALSE //yogs end
