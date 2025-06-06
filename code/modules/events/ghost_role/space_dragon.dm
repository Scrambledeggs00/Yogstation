/datum/round_event_control/space_dragon
	name = "Spawn Space Dragon"
	typepath = /datum/round_event/ghost_role/space_dragon
	weight = 7
	max_occurrences = 1
	min_players = 20
	earliest_start = 60 MINUTES
	description = "Spawns a space dragon, which will try to take over the station."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event/ghost_role/space_dragon
	minimum_required = 1
	role_name = "Space Dragon"
	announce_when = 10

/datum/round_event/ghost_role/space_dragon/announce(fake)
	priority_announce("A large organic energy flux has been recorded near [station_name()], please stand by.", "Lifesign Alert")

/datum/round_event/ghost_role/space_dragon/spawn_role()
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/carp_spawn in GLOB.landmarks_list)
		if(!isturf(carp_spawn.loc))
			stack_trace("Carp spawn found not on a turf: [carp_spawn.type] on [isnull(carp_spawn.loc) ? "null" : carp_spawn.loc.type]")
			continue
		spawn_locs += carp_spawn.loc
	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_SPACE_DRAGON, null, ROLE_SPACE_DRAGON)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)
	var/key = selected.key

	var/mob/living/simple_animal/hostile/space_dragon/dragon = new (pick(spawn_locs))
	dragon.key = key
	dragon.mind.assigned_role = ROLE_SPACE_DRAGON
	dragon.mind.special_role = ROLE_SPACE_DRAGON
	dragon.mind.add_antag_datum(/datum/antagonist/space_dragon)
	playsound(dragon, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(dragon)] has been made into a Space Dragon by an event.")
	dragon.log_message("was spawned as a Space Dragon by an event.", LOG_GAME)
	spawned_mobs += dragon
	return SUCCESSFUL_SPAWN
