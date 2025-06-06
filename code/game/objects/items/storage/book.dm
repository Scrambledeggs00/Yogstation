/obj/item/storage/book
	name = "hollowed book"
	desc = "I guess someone didn't like it."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	var/title = "book"

/obj/item/storage/book/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1

/obj/item/storage/book/attack_self(mob/user)
	to_chat(user, span_notice("The pages of [title] have been cut out!"))

GLOBAL_LIST_INIT(biblenames, list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light",  "The God Delusion", "Tome",        "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon","Insulationism", "Avesta", "The Holy Flame"))
//If you get these two lists not matching in size, there will be runtimes and I will hurt you in ways you couldn't even begin to imagine
// if your bible has no custom itemstate, use one of the existing ones
GLOBAL_LIST_INIT(biblestates, list("bible", "koran", "scrapbook", "burning", "honk1", "honk2", "creeper", "white", "holylight", "atheist", "tome", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon","insuls", "avesta", "holyflame"))
GLOBAL_LIST_INIT(bibleitemstates, list("bible", "koran", "scrapbook", "burning", "honk1", "honk2", "creeper", "white", "holylight", "atheist", "tome", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon", "kingyellow", "avesta", "holyflame"))

/mob/proc/bible_check() //The bible, if held, might protect against certain things
	var/obj/item/storage/book/bible/B = locate() in src
	if(is_holding(B))
		return B
	return 0

/obj/item/storage/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage.dmi'
	icon_state = "bible"
	item_state = "bible"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	var/mob/affecting = null
	var/deity_name = "Christ"
	force_string = "holy"
	slot_flags = ITEM_SLOT_BELT
	var/success_heal_chance = 60

/obj/item/storage/book/bible/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE_HOLY)

/obj/item/storage/book/bible/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is offering [user.p_them()]self to [deity_name]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/storage/book/bible/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!H.can_read(src))
		return FALSE
	// If H is the Chaplain, we can set the icon_state of the bible (but only once!)
	if(!GLOB.bible_icon_state && H.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		var/dat = "<html><head><meta charset='UTF-8'><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"

		for(var/i in 1 to GLOB.biblestates.len)
			var/icon/bibleicon = icon('icons/obj/storage.dmi', GLOB.biblestates[i])
			var/nicename = GLOB.biblenames[i]
			H << browse_rsc(bibleicon, nicename)
			dat += {"<tr><td><img src="[nicename]"></td><td><a href="byond://?src=[REF(src)];seticon=[i]">[nicename]</a></td></tr>"}
		dat += "</table></body></html>"
		H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")

/obj/item/storage/book/bible/Topic(href, href_list)
	if(!usr.canUseTopic(src, BE_CLOSE))
		return
	if(href_list["seticon"] && !GLOB.bible_icon_state)
		var/iconi = text2num(href_list["seticon"])
		var/biblename = GLOB.biblenames[iconi]
		icon_state = GLOB.biblestates[iconi]
		item_state = GLOB.bibleitemstates[iconi]

		if(icon_state == "honk1" || icon_state == "honk2")
			var/mob/living/carbon/human/H = usr
			H.dna.add_mutation(CLOWNMUT)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), ITEM_SLOT_MASK)
		if(icon_state == "insuls")
			var/mob/living/carbon/human/H =usr
			var/obj/item/clothing/gloves/color/fyellow/insuls = new
			insuls.name = "insuls"
			insuls.desc = "A mere copy of the true insuls."
			insuls.armor.setRating(electric=0.001)
			H.equip_to_slot(insuls, ITEM_SLOT_GLOVES)
		GLOB.bible_icon_state = icon_state
		GLOB.bible_item_state = item_state

		SSblackbox.record_feedback("text", "religion_book", 1, "[biblename]")
		usr << browse(null, "window=editicon")

/obj/item/storage/book/bible/proc/bless(mob/living/L, mob/living/user)
	if(!istype(src, /obj/item/storage/book/bible/syndicate) && GLOB.religious_sect)
		return GLOB.religious_sect.sect_bless(L,user)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, span_warning("[src.deity_name] refuses to heal this metallic taint!"))
			return 0

	var/heal_amt = 20

	if(H.getBruteLoss() > 0 || H.getFireLoss() > 0)
		H.heal_overall_damage(heal_amt, heal_amt, 0, BODYPART_ORGANIC)
		H.update_damage_overlays()
		H.visible_message(span_notice("[user] heals [H] with the power of [deity_name]!"))
		to_chat(H, span_boldnotice("May the power of [deity_name] compel you to be healed!"))
		playsound(src.loc, "punch", 25, 1, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return 1

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)

	if (!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	if (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(success_heal_chance))
		to_chat(user, span_danger("[src] slips out of your hand and hits your head."))
		user.take_bodypart_damage(10)
		user.Unconscious(400)
		return

	var/chaplain = 0
	if(user.mind && (user.mind.holy_role))
		chaplain = 1

	if(!chaplain)
		to_chat(user, span_danger("The book sizzles in your hands."))
		user.take_bodypart_damage(0,10)
		return

	if (!heal_mode)
		return ..()

	var/smack = 1

	if (M.stat != DEAD)
		if(chaplain && user == M)
			to_chat(user, span_warning("You can't heal yourself!"))
			return

		if(prob(success_heal_chance) && bless(M, user))
			smack = 0
		else if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!istype(C.head, /obj/item/clothing/head/helmet))
				C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 60)
				to_chat(C, span_danger("You feel dumber."))

		if(smack)
			M.visible_message(span_danger("[user] beats [M] over the head with [src]!"), \
					span_userdanger("[user] beats [M] over the head with [src]!"))
			playsound(src.loc, "punch", 25, 1, -1)
			log_combat(user, M, "attacked", src)

	else
		M.visible_message(span_danger("[user] smacks [M]'s lifeless corpse with [src]."))
		playsound(src.loc, "punch", 25, 1, -1)

/obj/item/storage/book/bible/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isfloorturf(A))
		to_chat(user, span_notice("You hit the floor with the bible."))
		if(user.mind && (user.mind.holy_role))
			for(var/obj/effect/rune/R in orange(2,user))
				R.invisibility = 0
	if(user?.mind?.holy_role)
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/water)) // blesses all the water in the holder
			to_chat(user, span_notice("You bless [A]."))
			var/water2holy = A.reagents.get_reagent_amount(/datum/reagent/water)
			A.reagents.del_reagent(/datum/reagent/water)
			A.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/fuel/unholywater)) // yeah yeah, copy pasted code - sue me
			to_chat(user, span_notice("You purify [A]."))
			var/unholy2clean = A.reagents.get_reagent_amount(/datum/reagent/fuel/unholywater)
			A.reagents.del_reagent(/datum/reagent/fuel/unholywater)
			A.reagents.add_reagent(/datum/reagent/water/holywater,unholy2clean)
		if(istype(A, /obj/item/storage/book/bible) && !istype(A, /obj/item/storage/book/bible/syndicate))
			to_chat(user, span_notice("You purify [A], conforming it to your belief."))
			var/obj/item/storage/book/bible/B = A
			B.name = name
			B.icon_state = icon_state
			B.item_state = item_state
	if(istype(A, /obj/item/melee/cult_bastard) && !iscultist(user))
		var/obj/item/melee/cult_bastard/sword = A
		to_chat(user, span_notice("You begin to exorcise [sword]."))
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,1)
		if(do_after(user, 4 SECONDS, sword))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,1)
			for(var/obj/item/soulstone/SS in sword.contents)
				SS.usability = TRUE
				for(var/mob/living/simple_animal/shade/EX in SS)
					EX.remove_cultist(1, 0)

					EX.icon_state = "shade_holy"
					EX.name = "Purified [EX.name]"
				SS.release_shades(user)
				qdel(SS)
			new /obj/item/nullrod/claymore(get_turf(sword))
			user.visible_message(span_notice("[user] has purified [sword]!"))
			qdel(sword)

	else if(istype(A, /obj/item/soulstone) && !iscultist(user))
		var/obj/item/soulstone/SS = A
		if(SS.purified)
			return
		to_chat(user, span_notice("You begin to exorcise [SS]."))
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,1)
		if(do_after(user, 4 SECONDS, SS))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,1)
			SS.usability = TRUE
			SS.purified = TRUE
			SS.icon_state = "purified_soulstone"
			for(var/mob/M in SS.contents)
				if(M.mind)
					SS.icon_state = "purified_soulstone2"
			for(var/mob/living/simple_animal/shade/EX in SS)
				EX.remove_cultist( 1, 0)
				EX.icon_state = "ghost1"
				EX.name = "Purified [initial(EX.name)]"
			user.visible_message(span_notice("[user] has purified [SS]!"))
	else if(istype(A, /obj/item/nullrod/talking))
		var/obj/item/nullrod/talking/sword = A
		to_chat(user, span_notice("You begin to exorcise [sword]..."))
		if(sword.owner)
			to_chat(sword.owner, "you feel the soul in your blade cry out as it starts getting exorcised!")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
		if(do_after(user, 4 SECONDS, sword))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,TRUE)
			for(var/mob/living/simple_animal/shade/S in sword.contents)
				to_chat(S, span_userdanger("You were destroyed by the exorcism!"))
				qdel(S)
			if(sword.owner)
				sword.summon.Remove(sword.owner)
				sword.owner = null
			sword.possessed = FALSE //allows the chaplain (or someone else) to reroll a new spirit for their sword
			sword.name = initial(sword.name)
			REMOVE_TRAIT(sword, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT) //in case the "sword" is a possessed dummy
			user.visible_message(span_notice("[user] has exorcised [sword]!"), \
								span_notice("You successfully exorcise [sword]!"))


/obj/item/storage/book/bible/booze
	desc = "To be applied to the head repeatedly."

/obj/item/storage/book/bible/booze/PopulateContents()
	new /obj/item/reagent_containers/food/drinks/bottle/whiskey(src)

/obj/item/storage/book/bible/syndicate
	icon_state ="ebook"
	deity_name = "The Syndicate"
	throw_speed = 2
	throwforce = 18
	throw_range = 7
	force = 18
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	name = "Syndicate Tome"
	attack_verb = list("attacked", "burned", "blessed", "damned", "scorched")
	var/used = FALSE

/obj/item/storage/book/bible/syndicate/attack_self(mob/living/carbon/human/H)
	if (!used)
		H.mind.holy_role = HOLY_ROLE_PRIEST
		used = TRUE
		to_chat(H, span_userdanger("You try to open the book AND IT BITES YOU!"))
		playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
		H.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		to_chat(H, span_notice("Your name appears on the inside cover, in blood."))
		var/ownername = H.real_name
		desc += span_warning("The name [ownername] is written in blood inside the cover.")

/obj/item/storage/book/bible/syndicate/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)
	if (!user.combat_mode)
		return ..()
	else
		return ..(M,user,heal_mode = FALSE)

/obj/item/storage/book/bible/syndicate/add_blood_DNA(list/blood_dna)
	return FALSE
