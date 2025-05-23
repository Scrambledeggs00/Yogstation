/datum/supply_pack
	var/name = "Crate"
	var/group = ""
	var/hidden = FALSE
	var/contraband = FALSE
	var/cost = 700 // Minimum cost, or infinite points are possible.
	var/access = FALSE
	var/access_view = FALSE
	var/access_any = FALSE
	var/list/contains = null
	var/crate_name = "crate"
	var/desc = ""//no desc by default
	var/crate_type = /obj/structure/closet/crate
	var/dangerous = FALSE // Should we message admins?
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE
	var/DropPodOnly = FALSE//only usable by the Bluespace Drop Pod via the express cargo console
	var/admin_spawned = FALSE
	var/small_item = FALSE //Small items can be grouped into a single crate.
	var/budget_radioactive = FALSE //Overwrite budget crate into radiation protective crate

/datum/supply_pack/proc/generate(atom/A, datum/bank_account/paying_account)
	var/obj/structure/closet/crate/C
	if(paying_account)
		if(budget_radioactive)
			C = new /obj/structure/closet/crate/secure/owned/radiation(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_MED))
			C = new /obj/structure/closet/crate/secure/owned/medical(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_ENG))
			C = new /obj/structure/closet/crate/secure/owned/engineering(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_SCI))
			C = new /obj/structure/closet/crate/secure/owned/science(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_SRV))
			C = new /obj/structure/closet/crate/secure/owned/hydroponics(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_SEC))
			C = new /obj/structure/closet/crate/secure/owned/gear(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_CIV))
			C = new /obj/structure/closet/crate/secure/owned/civ(A, paying_account)
		else
			C = new /obj/structure/closet/crate/secure/owned(A, paying_account)
		C.name = "[crate_name] - Purchased by [paying_account.account_holder]"
	else
		C = new crate_type(A)
		C.name = crate_name
	if(access)
		C.req_access = list(access)
	if(access_any)
		C.req_one_access = access_any

	fill(C)
	return C

/datum/supply_pack/proc/get_cost()
	. = cost
	. *= SSeconomy.pack_price_modifier

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	if (admin_spawned)
		for(var/item in contains)
			var/atom/A = new item(C)
			A.flags_1 |= ADMIN_SPAWNED_1
	else
		for(var/item in contains)
			new item(C)

// If you add something to this list, please group it by type and sort it alphabetically instead of just jamming it in like an animal

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/emergency
	group = "Emergency"

/datum/supply_pack/emergency/vehicle
	name = "Biker Gang Kit" //TUNNEL SNAKES OWN THIS TOWN
	desc = "TUNNEL SNAKES OWN THIS TOWN. Contains an unbranded All Terrain Vehicle, and a complete gang outfit -- consists of black gloves, a menacing skull bandanna, and a SWEET leather overcoat!"
	cost = 2000
	contraband = TRUE
	contains = list(/obj/vehicle/ridden/atv,
					/obj/item/key,
					/obj/item/clothing/suit/jacket/leather/overcoat,
					/obj/item/clothing/gloves/color/black,
					/obj/item/clothing/head/soft,
					/obj/item/clothing/mask/bandana/skull)//so you can properly #cargoniabikergang
	crate_name = "Biker Kit"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/emergency/bio
	name = "Biological Emergency Crate"
	desc = "This crate holds 2 full bio suits which will protect you from viruses."
	cost = 2000
	contains = list(/obj/item/clothing/head/bio_hood/general,
					/obj/item/clothing/head/bio_hood/general,
					/obj/item/clothing/suit/bio_suit/general,
					/obj/item/clothing/suit/bio_suit/general,
					/obj/item/storage/bag/bio,
					/obj/item/reagent_containers/syringe/antiviral,
					/obj/item/reagent_containers/syringe/antiviral,
					/obj/item/clothing/gloves/color/latex/nitrile,
					/obj/item/clothing/gloves/color/latex/nitrile)
	crate_name = "bio suit crate"

/datum/supply_pack/emergency/equipment
	name = "Emergency Bot/Internals Crate"
	desc = "Explosions got you down? These supplies are guaranteed to patch up holes, in stations and people alike! Comes with two floorbots, two medbots, five oxygen masks and five small oxygen tanks."
	cost = 3500
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/bomb
	name = "Explosive Emergency Crate"
	desc = "Science gone bonkers? Beeping behind the airlock? Buy now and be the hero the station des... I mean needs! (time not included)"
	cost = 1500
	contains = list(/obj/item/clothing/head/bomb_hood,
					/obj/item/clothing/suit/bomb_suit,
					/obj/item/clothing/mask/gas,
					/obj/item/screwdriver,
					/obj/item/wirecutters,
					/obj/item/multitool)
	crate_name = "bomb suit crate"

/datum/supply_pack/emergency/firefighting
	name = "Firefighting Crate"
	desc = "Only you can prevent station fires. Partner up with two firefighter suits, gas masks, flashlights, large oxygen tanks, extinguishers, and hardhats!"
	cost = 1000
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	crate_name = "firefighting crate"

/datum/supply_pack/emergency/atmostank
	name = "Firefighting Tank Backpack"
	desc = "Mow down fires with this high-capacity fire fighting tank backpack. Requires Atmospherics access to open."
	cost = 1000
	access = ACCESS_ATMOSPHERICS
	contains = list(/obj/item/watertank/atmos)
	crate_name = "firefighting backpack crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/internals
	name = "Internals Crate"
	desc = "Master your life energy and control your breathing with three breath masks, three emergency oxygen tanks and three large air tanks."//IS THAT A
	cost = 1000
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air)
	crate_name = "internals crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/metalfoam
	name = "Metal Foam Grenade Crate"
	desc = "Seal up those pesky hull breaches with 7 Metal Foam Grenades."
	cost = 1000
	contains = list(/obj/item/storage/box/metalfoam)
	crate_name = "metal foam grenade crate"

/datum/supply_pack/emergency/plasma_spacesuit
	name = "Plasmaman Space Envirosuits"
	desc = "Contains two space-worthy envirosuits for Plasmamen. Order now and we'll throw in two free helmets! Requires EVA access to open."
	cost = 4000
	access = ACCESS_EVA
	contains = list(/obj/item/clothing/suit/space/eva/plasmaman,
					/obj/item/clothing/suit/space/eva/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	crate_name = "plasmaman EVA crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/plasmaman
	name = "Plasmaman Supply Kit"
	desc = "Keep those Plasmamen alive with two sets of Plasmaman outfits. Each set contains a plasmaman jumpsuit, internals tank, and helmet."
	cost = 2000
	contains = list(/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	crate_name = "plasmaman supply kit"

/datum/supply_pack/emergency/radiation
	name = "Radiation Protection Crate"
	desc = "Survive the Nuclear Apocalypse and Supermatter Engine alike with two sets of Radiation suits. Each set contains a helmet, suit, and Geiger counter. We'll even throw in a bottle of vodka and some glasses too, considering the life-expectancy of people who order this."
	cost = 1000
	contains = list(/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/geiger_counter,
					/obj/item/geiger_counter,
					/obj/item/reagent_containers/food/drinks/bottle/vodka,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass)
	crate_name = "radiation protection crate"
	crate_type = /obj/structure/closet/crate/radiation

/datum/supply_pack/emergency/spacesuit
	name = "Space Suit Crate"
	desc = "Contains one aging suit from Space-Goodwill and a jetpack. Requires EVA access to open."
	cost = 2500
	access = ACCESS_EVA
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/tank/jetpack/carbondioxide)
	crate_name = "space suit crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/specialops
	name = "Special Ops Supplies"
	desc = "(*!&@#TOO CHEAP FOR THAT NULL_ENTRY, HUH OPERATIVE? WELL, THIS LITTLE ORDER CAN STILL HELP YOU OUT IN A PINCH. CONTAINS A BOX OF FIVE EMP GRENADES, THREE SMOKEBOMBS, AN INCENDIARY GRENADE, AND A \"SLEEPY PEN\" FULL OF NICE TOXINS!#@*$"
	hidden = TRUE
	cost = 2000
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/blue/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/weedcontrol
	name = "Weed Control Crate"
	desc = "Keep those invasive species OUT. Contains a scythe, gasmask, and two anti-weed chemical grenades. Warranty void if used on ambrosia. Requires Hydroponics access to open."
	cost = 1500
	access = ACCESS_HYDROPONICS
	contains = list(/obj/item/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	crate_name = "weed control crate"
	crate_type = /obj/structure/closet/crate/secure/hydroponics

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security
	group = "Security"
	access = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three sets of well-rounded, decently-protective armor and helmet. Requires Security access to open."
	cost = 2000
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec)
	crate_name = "armor crate"

/datum/supply_pack/security/disabler
	name = "Disabler Crate"
	desc = "Three stamina-draining disabler weapons. Requires Security access to open."
	cost = 1500
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler)
	crate_name = "disabler crate"

/datum/supply_pack/security/energypistol
	name = "Energy Pistol Single-Pack"
	desc = "Contains one energy pistol for personal defense, capable of firing both lethal and nonlethal blasts of light. Requires Security access to open."
	cost = 700
	access_view = ACCESS_SECURITY
	small_item = TRUE
	contains = list(/obj/item/gun/energy/e_gun/mini)

/datum/supply_pack/security/forensics
	name = "Forensics Crate"
	desc = "Stay hot on the criminal's heels with Nanotrasen's Detective Essentials(tm). Contains a forensics scanner, six evidence bags, camera, tape recorder, white crayon, and of course, a fedora. Requires Security access to open."
	cost = 2000
	access_view = ACCESS_MORGUE
	contains = list(/obj/item/detective_scanner,
					/obj/item/storage/box/evidence,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/fedora/det_hat)
	crate_name = "forensics crate"

/datum/supply_pack/security/laser
	name = "Lasers Crate"
	desc = "Contains three lethal, high-energy laser guns. Requires Security access to open."
	cost = 2000
	contains = list(/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser)
	crate_name = "laser crate"

/datum/supply_pack/security/secfiringpins
	name = "Mindshield Firing Pins Crate"
	desc = "Upgrade your arsenal with 10 mindshield firing pins. Requires Security access to open."
	cost = 3000
	contains = list(/obj/item/storage/box/secfiringpins,
					/obj/item/storage/box/secfiringpins)
	crate_name = "firing pins crate"

/datum/supply_pack/security/dragnet
	name = "DRAGnet Crate"
	desc = "Contains three \"Dynamic Rapid-Apprehension of the Guilty\" netting devices, a recent breakthrough in law enforcement prisoner management technology. Requires Security access to open."
	cost = 1500
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/gun/energy/e_gun/dragnet,
					/obj/item/gun/energy/e_gun/dragnet,
					/obj/item/gun/energy/e_gun/dragnet)
	crate_name = "\improper DRAGnet crate"

/datum/supply_pack/security/ntusp
	name = "NT-USP Crate"
	desc = "Three stamina-draining ballistic weapons, along with three extra magazines. Requires Security access to open."
	cost = 2000
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/gun/ballistic/automatic/pistol/ntusp,
					/obj/item/gun/ballistic/automatic/pistol/ntusp,
					/obj/item/gun/ballistic/automatic/pistol/ntusp,
					/obj/item/ammo_box/magazine/recharge/ntusp,
					/obj/item/ammo_box/magazine/recharge/ntusp,
					/obj/item/ammo_box/magazine/recharge/ntusp)
	crate_name = "nt-usp crate"

/datum/supply_pack/security/v38pistol
	name = "Vatra M38 Pistol Crate"
	desc = "A pack containing three Vatra M38s, an unusual handgun which loads .38 special designed for unarmored targets, loaded with non-lethal rounds. Three spare magazines are included. Requires Security access to open."
	cost = 4000
	access = ACCESS_SECURITY
	contains = list(/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal,
					/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal,
					/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal,
					/obj/item/ammo_box/magazine/v38/rubber,
					/obj/item/ammo_box/magazine/v38/rubber,
					/obj/item/ammo_box/magazine/v38/rubber)
	crate_name = "pistol crate"
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/tracrevolver
	name = "TRAC Revolver Crate"
	desc = "Contains one Caldwell Tracking Revolver and two speed loaders for it. Requires Security access to open."
	cost = 4000
	access = ACCESS_SECURITY
	contains = list(/obj/item/gun/ballistic/revolver/tracking,
					/obj/item/ammo_box/tra32,
					/obj/item/ammo_box/tra32)
	crate_name = "TRAC revolver crate"

/datum/supply_pack/security/vending/security
	name = "SecTech Supply Crate"
	desc = "Officer Paul bought all the donuts? Then refill the security vendor with ths crate."
	cost = 1500
	contains = list(/obj/item/vending_refill/security)
	crate_name = "SecTech supply crate"

/datum/supply_pack/security/securitybarriers
	name = "Security Barrier Grenades"
	desc = "Stem the tide with four Security Barrier grenades. Requires Security access to open."
	cost = 2000
	access_view = ACCESS_BRIG
	contains = list(/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier)
	crate_name = "security barriers crate"

/datum/supply_pack/security/securityclothes
	name = "Security Clothing Crate"
	desc = "Contains appropriate outfits for the station's private security force. Contains outfits for the Warden, Head of Security, and two Security Officers. Each outfit comes with a rank-appropriate jumpsuit, suit, and beret. Requires Security access to open."
	cost = 3000
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/under/rank/security/navyblue,
					/obj/item/clothing/under/rank/security/navyblue,
					/obj/item/clothing/suit/armor/officerjacket,
					/obj/item/clothing/suit/armor/officerjacket,
					/obj/item/clothing/head/beret/sec/navyofficer,
					/obj/item/clothing/head/beret/sec/navyofficer,
					/obj/item/clothing/under/rank/security/warden/navyblue,
					/obj/item/clothing/suit/armor/wardenjacket,
					/obj/item/clothing/head/beret/sec/navywarden,
					/obj/item/clothing/under/rank/security/head_of_security/navyblue,
					/obj/item/clothing/suit/armor/hosjacket,
					/obj/item/clothing/head/beret/sec/navyhos)
	crate_name = "security clothing crate"

/datum/supply_pack/security/supplies
	name = "Security Supplies Crate"
	desc = "Contains seven flashbangs, seven teargas grenades, six flashes, and seven handcuffs. Requires Security access to open."
	cost = 1000
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs)
	crate_name = "security supply crate"

/datum/supply_pack/security/secway
    name = "Secway Crate"
    desc = "A stylish way to travel for all law enforcement. Requires Security access to open."
    cost = 5000
    contains = list(/obj/vehicle/ridden/secway,
                    /obj/item/key/security)
    crate_name = "secway crate"

/datum/supply_pack/security/firingpins
	name = "Standard Firing Pins Crate"
	desc = "Upgrade your arsenal with 10 standard firing pins. Requires Security access to open."
	cost = 2000
	contains = list(/obj/item/storage/box/firingpins,
					/obj/item/storage/box/firingpins)
	crate_name = "firing pins crate"

/datum/supply_pack/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	desc = "This is it. The Bee's Knees. The Creme of the Crop. The Pick of the Litter. The best of the best of the best. The Crown Jewel of Nanotrasen. The Alpha and the Omega of security headwear. Guaranteed to strike fear into the hearts of each and every criminal aboard the station. Also comes with a security gasmask. Requires Security access to open."
	cost = 6000 //justice comes at a price. An expensive, noisy price.
	contraband = TRUE
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/mask/gas/sechailer)
	crate_name = "security clothing crate"

/datum/supply_pack/security/baton
	name = "Stun Batons Crate"
	desc = "Arm the Civil Protection Forces with three stun batons. Batteries included. Requires Security access to open."
	cost = 1000
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/loaded,
					/obj/item/melee/baton/loaded,
					/obj/item/melee/baton/loaded)
	crate_name = "stun baton crate"

/datum/supply_pack/security/wall_flash
	name = "Wall-Mounted Flash Crate"
	desc = "Contains four wall-mounted flashes. Requires Security access to open."
	cost = 1000
	contains = list(/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash)
	crate_name = "wall-mounted flash crate"

/datum/supply_pack/security/secconclothes
	name = "Constable Supply Crate"
	desc = "Contains two different sets of constable uniforms and two billy clubs and whistles to go with them. Requires Security access to open."
	cost = 5000
	contains = list(/obj/item/melee/classic_baton/secconbaton,
					/obj/item/melee/classic_baton/secconbaton,
					/obj/item/clothing/neck/falcon/secconwhistle,
					/obj/item/clothing/neck/falcon/secconwhistle,
					/obj/item/clothing/under/rank/security/secconuniform,
					/obj/item/clothing/under/rank/security/secconuniform,
					/obj/item/clothing/head/helmet/secconhelm,
					/obj/item/clothing/suit/armor/secconcoat,
					/obj/item/clothing/head/beret/sec/secconhat,
					/obj/item/clothing/suit/armor/secconvest)
	crate_name = "constable supply crate"

/datum/supply_pack/security/stormtrooper
	name = "Stormtrooper Crate"
	desc = "Three sets of standard issue stormtrooper armor. Should help you defeat light-wielding wizards. Requires Security access to open."
	cost = 10000
	contains = list(/obj/item/clothing/suit/armor/stormtrooper,
					/obj/item/clothing/suit/armor/stormtrooper,
					/obj/item/clothing/suit/armor/stormtrooper,
					/obj/item/clothing/head/helmet/stormtrooper,
					/obj/item/clothing/head/helmet/stormtrooper,
					/obj/item/clothing/head/helmet/stormtrooper)
	crate_name = "stormtrooper crate"
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/plasma_secsuit
	name = "Plasmaman Security Envirosuit Crate"
	desc = "Contains two sets of lightly-armored security envirosuits for Plasmamen. Order now and we'll throw in two free helmets! Requires Security access to open."
	cost = 4000
	contains = list(/obj/item/clothing/under/plasmaman/security,
					/obj/item/clothing/under/plasmaman/security,
					/obj/item/clothing/head/helmet/space/plasmaman/security,
					/obj/item/clothing/head/helmet/space/plasmaman/security)
	crate_name = "security envirosuit crate"
	crate_type = /obj/structure/closet/crate/secure/gear

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Armory //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security/armory
	group = "Armory"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	desc = "Contains three sets of bulletproof armor and helmet. Guaranteed to reduce a bullet's stopping power by over half. Requires Armory access to open."
	cost = 3000
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt)
	crate_name = "bulletproof armor crate"

/datum/supply_pack/security/armory/chemimp
	name = "Chemical Implants Crate"
	desc = "Contains five Remote Chemical implants. Requires Armory access to open."
	cost = 2000
	contains = list(/obj/item/storage/box/chemimp)
	crate_name = "chemical implant crate"

/datum/supply_pack/security/armory/energy_single
	name = "Energy Gun Single-Pack"
	desc = "Contains one energy gun, capable of firing both non-lethal and lethal blasts of light. Requires Armory access to open."
	cost = 1500
	small_item = TRUE
	contains = list(/obj/item/gun/energy/e_gun)

/datum/supply_pack/security/armory/energy
	name = "Energy Guns Crate"
	desc = "Contains two energy guns, capable of firing both non-lethal and lethal blasts of light. Requires Armory access to open."
	cost = 2500
	contains = list(/obj/item/gun/energy/e_gun,
					/obj/item/gun/energy/e_gun)
	crate_name = "energy gun crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/mindshield
	name = "Mindshield Implants Crate"
	desc = "Prevent against radical thoughts with three Mindshield implants. Requires Armory access to open."
	cost = 4000
	contains = list(/obj/item/storage/lockbox/loyalty)
	crate_name = "mindshield implant crate"

/datum/supply_pack/security/armory/laserarmor
	name = "Reflective Jacket Crate"
	desc = "Contains two vests of highly reflective material. Each armor piece diffuses a laser's energy by over half, as well as offering a good chance to reflect the laser entirely. Requires Armory access to open."
	cost = 2000
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)
	crate_name = "reflective jacket crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/riotarmor
	name = "Riot Armor Crate"
	desc = "Contains three sets of heavy body armor and helmet. Advanced padding protects against close-ranged weaponry, making melee attacks feel only half as potent to the user. Requires Armory access to open."
	cost = 3000
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	crate_name = "riot armor crate"

/datum/supply_pack/security/armory/riotshields
	name = "Riot Shields Crate"
	desc = "For when the greytide gets really uppity. Contains three riot shields. Requires Armory access to open."
	cost = 2000
	contains = list(/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/shield/riot)
	crate_name = "riot shields crate"

/datum/supply_pack/security/armory/riotshotgun
	name = "Riot Shotguns Crate"
	desc = "Tip: techically, it counts as non-lethally subduing a target as long as they don't die before Medbay can get to them. Contains three security-grade riot shotguns. Requires Armory access to open."
	cost = 8000
	contains = list(/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/gun/ballistic/shotgun/riot)
	crate_name = "riot shotguns crate"

/datum/supply_pack/security/armory/riotshotgun_single
	name = "Riot Shotgun Single-Pack"
	desc = "Stop that Clown in his tracks with this magic stick of non-lethal subduction! Contains one security-grade riot shotgun. Requires Armory access to open."
	cost = 3200
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/shotgun/riot)

/datum/supply_pack/security/armory/smartmine
	name = "Smart Mine Crate"
	desc = "Contains three non-lethal pressure activated stun mines capable of ignoring mindshieled personnel. Requires Armory access to open."
	cost = 4000
	contains = list(/obj/item/deployablemine/smartstun,
					/obj/item/deployablemine/smartstun,
					/obj/item/deployablemine/smartstun)
	crate_name = "stun mine crate"

/datum/supply_pack/security/armory/stunmine
	name = "Stun Mine Crate"
	desc = "Contains five non-lethal pressure activated stun mines. Requires Armory access to open."
	cost = 2500
	contains = list(/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun)
	crate_name = "stun mine crate"

/datum/supply_pack/security/armory/swat
	name = "SWAT Crate"
	desc = "Contains two fullbody sets of tough, fireproof, pressurized suits designed in a joint effort by IS-ERI and Nanotrasen. Each set contains a suit, helmet, mask, combat belt, and combat gloves. Requires Armory access to open."
	cost = 6000
	contains = list(/obj/item/clothing/head/helmet/swat/nanotrasen,
					/obj/item/clothing/head/helmet/swat/nanotrasen,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/storage/belt/military/assault,
					/obj/item/storage/belt/military/assault,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/gloves/combat)
	crate_name = "swat crate"

/datum/supply_pack/security/armory/trackingimp
	name = "Tracking Implants Crate"
	desc = "Contains a box with four tracking implants. Requires Armory access to open."
	cost = 2000
	contains = list(/obj/item/storage/box/trackimp)
	crate_name = "tracking implant crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Imported Weaponry ///////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/weaponry
	group = "Outside Weaponry"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/weaponry/winton_ammo
	name = ".308 Ammo Box"
	desc = "A .308 Ammo Box meant for refilling the Winton Mk. VI Repeating Rifle. Rounds must be loaded individually."
	cost = 3000
	small_item = TRUE
	contains = list(/obj/item/ammo_box/no_direct/m308)

/datum/supply_pack/weaponry/ammo
	name = "Ammo Crate"
	desc = "Contains two 20-round magazines for the WT-550 Auto Carbine, two 8-round magazines for the Vatra M38 Pistol, three boxes of buckshot ammo, and three boxes of rubber ammo. Requires Security access to open."
	cost = 2500
	access = ACCESS_SECURITY
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/rubbershot,
					/obj/item/storage/box/rubbershot,
					/obj/item/storage/box/rubbershot)
	crate_name = "ammo crate"
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/weaponry/combatknives_single
	name = "Combat Knife Single-Pack"
	desc = "Contains one sharpened combat knife. Guaranteed to fit snugly inside any Nanotrasen-standard boot. Requires Armory access to open."
	cost = 500
	small_item = TRUE
	contains = list(/obj/item/kitchen/knife/combat)

/datum/supply_pack/weaponry/ballistic
	name = "Combat Shotguns Crate"
	desc = "For when the enemy absolutely needs to be replaced with lead. Contains three Aussec-designed Combat Shotguns, and three Shotgun Bandoliers. Requires Armory access to open."
	cost = 18000
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier)
	crate_name = "combat shotguns crate"

/datum/supply_pack/weaponry/ballistic_single
	name = "Combat Shotgun Single-Pack"
	desc = "For when the enemy absolutely needs to be replaced with lead. Contains one Aussec-designed Combat Shotgun, and one Shotgun Bandolier. Requires Armory access to open."
	cost = 7200
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/storage/belt/bandolier)

/datum/supply_pack/weaponry/hell_single
	name = "Hellgun Single-Pack"
	desc = "Contains one hellgun, an old pattern of laser gun infamous for its ability to horribly disfigure targets with burns. Violates several humanitarian agreements when used on sapients. Requires Armory access to open."
	cost = 1500
	small_item = TRUE
	contains = list(/obj/item/gun/energy/laser/hellgun)

/datum/supply_pack/weaponry/fire
	name = "Incendiary Weapons Crate"
	desc = "Burn, baby burn. Contains three incendiary grenades, three plasma canisters, and a flamethrower. Requires Armory access to open."
	cost = 1500
	access = ACCESS_COMMAND
	contains = list(/obj/item/gun/flamethrower/full,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary)
	crate_name = "incendiary weapons crate"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/weaponry/militia
	name = "Militia Crate"
	desc = "All you need to quickly and cheaply arm your own militia. Comes with three surplus carbines and three additional magazines, three survival knives, three armor vests, then three stylish berets. Requires Armory access to open."
	cost = 3500
	contains = list(/obj/item/gun/ballistic/automatic/surplus,
					/obj/item/gun/ballistic/automatic/surplus,
					/obj/item/gun/ballistic/automatic/surplus,
					/obj/item/ammo_box/magazine/m10mm/rifle,
					/obj/item/ammo_box/magazine/m10mm/rifle,
					/obj/item/ammo_box/magazine/m10mm/rifle,
					/obj/item/kitchen/knife/combat/survival,
					/obj/item/kitchen/knife/combat/survival,
					/obj/item/kitchen/knife/combat/survival,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/head/beret/vintage,
					/obj/item/clothing/head/beret/vintage,
					/obj/item/clothing/head/beret/vintage)
	crate_name = "militia crate"

/datum/supply_pack/weaponry/russian
	name = "Russian Surplus Crate"
	desc = "Hello Comrade, we have the most modern russian military equipment the black market can offer, for the right price of course. Sadly we couldnt remove the lock so it requires Armory access to open."
	cost = 7000
	contraband = TRUE
	contains = list(/obj/item/reagent_containers/food/snacks/rationpack,
					/obj/item/ammo_box/a762,
					/obj/item/ammo_box/no_direct/n762,
					/obj/item/storage/toolbox/ammo,
					/obj/item/clothing/suit/armor/vest/russian,
					/obj/item/clothing/head/helmet/rus_helmet,
					/obj/item/clothing/shoes/russian,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/under/syndicate/rus_army,
					/obj/item/clothing/under/costume/soviet,
					/obj/item/clothing/mask/russian_balaclava,
					/obj/item/clothing/head/helmet/rus_ushanka,
					/obj/item/clothing/suit/armor/vest/russian_coat,
					/obj/item/gun/ballistic/revolver/nagant,
					/obj/item/gun/ballistic/rifle/boltaction,
					/obj/item/gun/ballistic/rifle/boltaction)
	crate_name = "surplus military crate"

/datum/supply_pack/weaponry/russian/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 12)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/weaponry/wt550ammo
	name = "Surplus Security Autocarbine Ammo Crate"
	desc = "Contains four 20-round magazines for the surplus security autocarbine. Each magazine is designed to facilitate rapid tactical reloads. Requires Armory access to open."
	cost = 3000
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9)

/datum/supply_pack/weaponry/wt550ammo_single
	name = "Surplus Security Autocarbine Ammo Crate Single-Pack"
	desc = "Contains a 20-round magazine for the surplus security autocarbine. Each magazine is designed to facilitate rapid tactical reloads. Requires Armory access to open."
	cost = 750 //one of the few single-pack items that who's price per unit is the exact same as the bulk
	contains = list(/obj/item/ammo_box/magazine/wt550m9)
	small_item = TRUE

/datum/supply_pack/weaponry/wt550ammo_rubber
	name = "Surplus Security Autocarbine Less-Lethal Ammo Crate"
	desc = "Contains four 20-round less-than-lethal magazines for the surplus security autocarbine. Each magazine is designed to facilitate rapid tactical reloads. Requires Armory access to open."
	cost = 2500
	contains = list(/obj/item/ammo_box/magazine/wt550m9/wtr,
					/obj/item/ammo_box/magazine/wt550m9/wtr,
					/obj/item/ammo_box/magazine/wt550m9/wtr,
					/obj/item/ammo_box/magazine/wt550m9/wtr)

/datum/supply_pack/weaponry/wt550
	name = "Surplus Security Autocarbine Crate"
	desc = "Contains two high-powered, semiautomatic carbines chambered in 4.6x30mm rounds. Requires Armory access to open."
	cost = 3500
	contains = list(/obj/item/gun/ballistic/automatic/wt550,
					/obj/item/gun/ballistic/automatic/wt550)
	crate_name = "autocarbine crate"

/datum/supply_pack/weaponry/wt550_single
	name = "Surplus Security Autocarbine Single-Pack"
	desc = "Contains one high-powered, semiautomatic carbine chambered in 4.6x30mm rounds. Requires Armory access to open."
	cost = 2000
	contains = list(/obj/item/gun/ballistic/automatic/wt550)
	small_item = TRUE

/datum/supply_pack/weaponry/wintonrifle
	name = "Winton Mk. VI Repeating Rifles Crate"
	desc = "Line them up and put them down. Containts three Frontier-made Winton lever-action rifles and three bandoliers, each filled with twenty-four spare rounds."
	cost = 16000
	contains = list(/obj/item/gun/ballistic/shotgun/lever,
					/obj/item/gun/ballistic/shotgun/lever,
					/obj/item/gun/ballistic/shotgun/lever,
					/obj/item/storage/belt/bandolier/sharpshooter,
					/obj/item/storage/belt/bandolier/sharpshooter,
					/obj/item/storage/belt/bandolier/sharpshooter)
	crate_name = "lever-action rifles crate"

/datum/supply_pack/weaponry/wintonrifle_single
	name = "Winton Mk. VI Repeating Rifle Single-Pack"
	desc = "For the enterprising marksman. Contains a single Frontier-made Winton level-action rifle and a bandolier filled with twenty-four spare rounds."
	cost = 6400
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/shotgun/lever,
					/obj/item/storage/belt/bandolier/sharpshooter)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engineering
	group = "Engineering"
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engineering/bluespace_tap
	name = "Bluespace Harvester Parts"
	cost = 10000
	special = TRUE
	contains = list(
					/obj/item/circuitboard/machine/bluespace_tap,
					/obj/item/paper/bluespace_tap
					)
	crate_name = "bluespace harvester parts crate"

/datum/supply_pack/engineering/shieldgen
	name = "Anti-breach Shield Projector Crate"
	desc = "Hull breaches again? Say no more with the Nanotrasen Anti-Breach Shield Projector! Uses forcefield technology to keep the air in, and the space out. Contains two shield projectors."
	cost = 2500
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/machinery/shieldgen,
					/obj/machinery/shieldgen)
	crate_name = "anti-breach shield projector crate"

/datum/supply_pack/engineering/ripley
	name = "APLU MK-I Crate"
	desc = "A do-it-yourself kit for building an ALPU MK-I \"Ripley\", designed for lifting and carrying heavy equipment, and other station tasks. Batteries not included."
	cost = 2000
	access_view = ACCESS_ROBO_CONTROL
	contains = list(/obj/item/mecha_parts/chassis/ripley,
					/obj/item/mecha_parts/part/ripley_torso,
					/obj/item/mecha_parts/part/ripley_right_arm,
					/obj/item/mecha_parts/part/ripley_left_arm,
					/obj/item/mecha_parts/part/ripley_right_leg,
					/obj/item/mecha_parts/part/ripley_left_leg,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/scanning_module,
					/obj/item/circuitboard/mecha/ripley/main,
					/obj/item/circuitboard/mecha/ripley/peripherals,
					/obj/item/mecha_parts/mecha_equipment/drill,
					/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp)
	crate_name= "APLU MK-I kit"

/datum/supply_pack/engineering/conveyor
	name = "Conveyor Assembly Crate"
	desc = "Keep production moving along with thirty conveyor belts. Conveyor switch included. If you have any questions, check out the enclosed instruction book."
	cost = 1500
	contains = list(/obj/item/stack/conveyor/thirty,
					/obj/item/conveyor_switch_construct,
					/obj/item/paper/guides/conveyor)
	crate_name = "conveyor assembly crate"

/datum/supply_pack/engineering/atmos/fire
	name = "Advanced Firefighting Crate"
	desc = "Station is burning? Don't worry we got you. Introducing 4 atmos firesuits, gloves and advanced extinguishers!"
	cost = 3000
	contains = list(/obj/item/clothing/suit/fire/atmos,
					/obj/item/clothing/suit/fire/atmos,
					/obj/item/clothing/suit/fire/atmos,
					/obj/item/clothing/suit/fire/atmos,
					/obj/item/clothing/head/hardhat/atmos,
					/obj/item/clothing/head/hardhat/atmos,
					/obj/item/clothing/head/hardhat/atmos,
					/obj/item/clothing/head/hardhat/atmos,
					/obj/item/clothing/gloves/atmos,
					/obj/item/clothing/gloves/atmos,
					/obj/item/clothing/gloves/atmos,
					/obj/item/clothing/gloves/atmos,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced)
	crate_name = "advanced firefighting crate"

/datum/supply_pack/engineering/engiequipment
	name = "Engineering Gear Crate"
	desc = "Gear up with three toolbelts, high-visibility vests, welding goggles, hardhats, and two pairs of meson goggles!"
	cost = 1300
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/glasses/welding,
					/obj/item/clothing/glasses/welding,
					/obj/item/clothing/glasses/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/glasses/meson/engine,
					/obj/item/clothing/glasses/meson/engine)
	crate_name = "engineering gear crate"

/datum/supply_pack/engineering/sologamermitts
	name = "Insulated Gloves Single-Pack"
	desc = "The backbone of modern society. Barely ever ordered for actual engineering. Single Order."
	cost = 800
	access_view = ACCESS_ENGINE_EQUIP
	small_item = TRUE
	contains = list(/obj/item/clothing/gloves/color/yellow)

/datum/supply_pack/engineering/powergamermitts
	name = "Insulated Gloves Crate"
	desc = "The backbone of modern society. Barely ever ordered for actual engineering. Contains three insulated gloves."
	cost = 2000	//Made of pure-grade bullshittinium
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	crate_name = "insulated gloves crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/obj/item/stock_parts/cell/inducer_supply
	maxcharge = 5000
	charge = 5000

/datum/supply_pack/engineering/inducers
	name = "NT-75 Electromagnetic Power Inducers Crate"
	desc = "No rechargers? No problem, with the NT-75 EPI, you can recharge any standard cell-based equipment anytime, anywhere. Contains two Inducers."
	cost = 2000
	contains = list(/obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/inducer_supply; opened = 0}, /obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/inducer_supply; opened = 0}) //FALSE doesn't work in modified type paths apparently.
	crate_name = "inducer crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/pacman
	name = "P.A.C.M.A.N Generator Crate"
	desc = "Engineers can't set up the engine? Not an issue for you, once you get your hands on this P.A.C.M.A.N. Generator! Takes in plasma and spits out sweet sweet energy."
	cost = 2500
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/machinery/power/port_gen/pacman)
	crate_name = "PACMAN generator crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/power
	name = "Power Cell Crate"
	desc = "Looking for power overwhelming? Look no further. Contains three high-voltage power cells."
	cost = 1000
	contains = list(/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	crate_name = "power cell crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/portable_scrubbers
	name = "Portable Scrubbers"
	desc = "A set of spare portable scrubbers. Perfect for when plasma 'accidentally' gets into the air supply."
	cost = 1500
	contains = list(
		/obj/machinery/portable_atmospherics/scrubber,
		/obj/machinery/portable_atmospherics/scrubber
	)
	crate_name = "portable scrubber crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/shuttle_engine
	name = "Shuttle Engine Crate"
	desc = "Through advanced bluespace-shenanigans, our engineers have managed to fit an entire shuttle engine into one tiny little crate. Requires CE access to open."
	cost = 5000
	access = ACCESS_CE
	access_view = ACCESS_CE
	contains = list(/obj/structure/shuttle/engine/propulsion/burst/cargo)
	crate_name = "shuttle engine crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	special = TRUE

/datum/supply_pack/engineering/tools
	name = "Toolbox Crate"
	desc = "Any robust spaceman is never far from their trusty toolbox. Contains three electrical toolboxes and three mechanical toolboxes."
	cost = 1000
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical)
	crate_name = "toolbox crate"

/datum/supply_pack/service/vending/engivend
	name = "EngiVend Supply Crate"
	desc = "The engineers are out of metal foam grenades? This should help."
	cost = 1500
	contains = list(/obj/item/vending_refill/engivend)
	crate_name = "engineering supply crate"

/datum/supply_pack/engineering/bsa
	name = "Bluespace Artillery Parts"
	desc = "The pride of Nanotrasen Naval Command. The legendary Bluespace Artillery Cannon is a devastating feat of human engineering and testament to wartime determination. Highly advanced research is required for proper construction. "
	cost = 15000
	special = TRUE
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/circuitboard/machine/bsa/front,
					/obj/item/circuitboard/machine/bsa/middle,
					/obj/item/circuitboard/machine/bsa/back,
					/obj/item/circuitboard/computer/bsa_control
					)
	crate_name= "bluespace artillery parts crate"

/datum/supply_pack/engineering/dna_vault
	name = "DNA Vault Parts"
	desc = "Secure the longevity of the current state of humanity within this massive library of scientific knowledge, capable of granting superhuman powers and abilities. Highly advanced research is required for proper construction. Also contains five DNA probes."
	cost = 12000
	special = TRUE
	access_view = ACCESS_COMMAND
	contains = list(
					/obj/item/circuitboard/machine/dna_vault,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe
					)
	crate_name= "dna vault parts crate"

/datum/supply_pack/engineering/dna_probes
	name = "DNA Vault Samplers"
	desc = "Contains five DNA probes for use in the DNA vault."
	cost = 3000
	special = TRUE
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe
					)
	crate_name= "dna samplers crate"


/datum/supply_pack/engineering/shield_sat
	name = "Shield Generator Satellite"
	desc = "Protect the very existence of this station with these Anti-Meteor defenses. Contains three Shield Generator Satellites."
	cost = 3000
	special = TRUE
	access_view = ACCESS_COMMAND
	contains = list(
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield
					)
	crate_name= "shield sat crate"


/datum/supply_pack/engineering/shield_sat_control
	name = "Shield System Control Board"
	desc = "A control system for the Shield Generator Satellite system."
	cost = 5000
	special = TRUE
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/circuitboard/computer/sat_control)
	crate_name= "shield control board crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////// Engine Construction /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engine
	group = "Engine Construction"
	access_view = ACCESS_ENGINEERING
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engine/emitter
	name = "Emitter Crate"
	desc = "Useful for powering forcefield generators while destroying locked crates and intruders alike. Contains two high-powered energy emitters. Requires CE access to open."
	cost = 1500
	access = ACCESS_CE
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	crate_name = "emitter crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/field_gen
	name = "Field Generator Crate"
	desc = "Typically the only thing standing between the station and a messy death. Powered by emitters. Contains two field generators."
	cost = 1500
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	crate_name = "field generator crate"

/datum/supply_pack/engine/grounding_rods
	name = "Grounding Rod Crate"
	desc = "Four grounding rods guaranteed to keep any uppity tesla's lightning under control."
	cost = 1700
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	crate_name = "grounding rod crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/PA
	name = "Particle Accelerator Crate"
	desc = "A supermassive black hole or hyper-powered teslaball are the perfect way to spice up any party! This \"My First Apocalypse\" kit contains everything you need to build your own Particle Accelerator! Ages 10 and up."
	cost = 3000
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	crate_name = "particle accelerator crate"

/datum/supply_pack/engine/collector
	name = "Radiation Collector Crate"
	desc = "Contains three radiation collectors. Useful for collecting energy off nearby Supermatter Crystals, Singularities or Teslas!"
	cost = 2500
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	crate_name = "collector crate"

/datum/supply_pack/engine/sing_gen
	name = "Singularity Generator Crate"
	desc = "The key to unlocking the power of Lord Singuloth. Particle Accelerator not included."
	cost = 5000
	contains = list(/obj/machinery/the_singularitygen)
	crate_name = "singularity generator crate"

/datum/supply_pack/engine/solar
	name = "Solar Panel Crate"
	desc = "Go green with this DIY advanced solar array. Contains twenty one solar assemblies, a solar-control circuit board, and tracker. If you have any questions, please check out the enclosed instruction book."
	cost = 2000
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/circuitboard/computer/solar_control,
					/obj/item/electronics/tracker,
					/obj/item/paper/guides/jobs/engi/solars)
	crate_name = "solar panel crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	desc = "The power of the heavens condensed into a single crystal. Requires CE access to open."
	cost = 10000
	access = ACCESS_CE
	contains = list(/obj/item/choice_beacon/supermatter)
	crate_name = "supermatter shard crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/hypertorus_fusion_reactor
	name = "HFR Crate"
	desc = "The new and improved fusion reactor. Requires CE access to open."
	cost = 10000
	access = ACCESS_CE
	contains = list(/obj/item/hfr_box/corner,
					/obj/item/hfr_box/corner,
					/obj/item/hfr_box/corner,
					/obj/item/hfr_box/corner,
					/obj/item/hfr_box/body/fuel_input,
					/obj/item/hfr_box/body/moderator_input,
					/obj/item/hfr_box/body/waste_output,
					/obj/item/hfr_box/body/interface,
					/obj/item/hfr_box/core)
	crate_name = "HFR crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/fuel_rod_basic
	name = "Uranium-235 Fuel Rods Crate"
	desc = "Contains 5 Enriched Uranium Control Rods. Requires engineering access to open."
	cost = 5000
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/item/fuel_rod,
					/obj/item/fuel_rod,
					/obj/item/fuel_rod,
					/obj/item/fuel_rod,
					/obj/item/fuel_rod)
	crate_name = "Uranium-235 Fuel Rods"
	crate_type = /obj/structure/closet/crate/secure/radiation
	budget_radioactive = TRUE

/datum/supply_pack/engine/fuel_rod_plutonium
	name = "Plutonium-239 Fuel Rods Crate"
	desc = "Contains 5 Plutonium-239 Control Rods. Requires engineering access to open."
	cost = 15000
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/item/fuel_rod/plutonium,
					/obj/item/fuel_rod/plutonium,
					/obj/item/fuel_rod/plutonium,
					/obj/item/fuel_rod/plutonium,
					/obj/item/fuel_rod/plutonium)
	crate_name = "Plutonium-239 Fuel Rods"
	crate_type = /obj/structure/closet/crate/secure/radiation
	budget_radioactive = TRUE

/datum/supply_pack/engine/fuel_rod_bananium
	name = "Bananium Fuel Rods Crate"
	desc = "Contains 5 Bananium Control Rods."
	cost = 15000
	contraband = TRUE
	contains = list(/obj/item/fuel_rod/material/bananium,
					/obj/item/fuel_rod/material/bananium,
					/obj/item/fuel_rod/material/bananium,
					/obj/item/fuel_rod/material/bananium,
					/obj/item/fuel_rod/material/bananium)
	crate_name = "Bananium Fuel Rods"
	crate_type = /obj/structure/closet/crate/secure/radiation
	budget_radioactive = TRUE

//////////////////////////////////////////////////////////////////////////////
/////////////////////// Canisters & Materials ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/materials
	group = "Canisters & Materials"

/datum/supply_pack/materials/cardboard50
	name = "50 Cardboard Sheets"
	desc = "Create a bunch of boxes."
	cost = 1000
	contains = list(/obj/item/stack/sheet/cardboard/fifty)
	crate_name = "cardboard sheets crate"

/datum/supply_pack/materials/license50
	name = "50 Empty License Plates"
	desc = "'Put those prisoners to work' - Jedi Yoda probably"
	cost = 1000  // 50 * 25 - 1000 = 250 credits profit
	access_view = ACCESS_SEC_BASIC
	contains = list(/obj/item/stack/license_plates/empty/fifty)
	crate_name = "empty license plate crate"

/datum/supply_pack/materials/glass50
	name = "50 Glass Sheets"
	desc = "Let some nice light in with fifty glass sheets!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/glass/fifty)
	crate_name = "glass sheets crate"

/datum/supply_pack/materials/metal50
	name = "50 Metal Sheets"
	desc = "Any construction project begins with a good stack of fifty metal sheets!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/metal/fifty)
	crate_name = "metal sheets crate"

/datum/supply_pack/materials/plasteel20
	name = "20 Plasteel Sheets"
	desc = "Reinforce the station's integrity with twenty plasteel sheets!"
	cost = 7500
	contains = list(/obj/item/stack/sheet/plasteel/twenty)
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/plasteel50
	name = "50 Plasteel Sheets"
	desc = "For when you REALLY have to reinforce something."
	cost = 16500
	contains = list(/obj/item/stack/sheet/plasteel/fifty)
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/plastic50
	name = "50 Plastic Sheets"
	desc = "Build a limitless amount of toys with fifty plastic sheets!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/plastic/fifty)
	crate_name = "plastic sheets crate"

/datum/supply_pack/materials/sandstone30
	name = "30 Sandstone Blocks"
	desc = "Neither sandy nor stoney, these thirty blocks will still get the job done."
	cost = 1000
	contains = list(/obj/item/stack/sheet/mineral/sandstone/thirty)
	crate_name = "sandstone blocks crate"

/datum/supply_pack/materials/wood50
	name = "50 Wood Planks"
	desc = "Turn cargo's boring metal groundwork into beautiful panelled flooring and much more with fifty wooden planks!"
	cost = 2000
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "wood planks crate"

/datum/supply_pack/materials/bz
	name = "BZ Canister Crate"
	desc = "Contains a canister of BZ. Requires Toxins access to open."
	cost = 8000
	access = ACCESS_TOXINS_STORAGE
	access_view = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/bz)
	crate_name = "BZ canister crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/materials/carbon_dio
	name = "Carbon Dioxide Canister"
	desc = "Contains a canister of Carbon Dioxide."
	cost = 3000
	access_view = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	crate_name = "carbon dioxide canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/foamtank
	name = "Firefighting Foam Tank Crate"
	desc = "Contains a tank of firefighting foam. Also known as \"plasmaman's bane\"."
	cost = 1500
	contains = list(/obj/structure/reagent_dispensers/foamtank)
	crate_name = "foam tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/fueltank
	name = "Fuel Tank Crate"
	desc = "Contains a welding fuel tank. Caution, highly flammable."
	cost = 800
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	crate_name = "fuel tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/hightank
	name = "Large Water Tank Crate"
	desc = "Contains a high-capacity water tank. Useful for botany or other service jobs."
	cost = 1200
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	crate_name = "high-capacity water tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/nitrogen
	name = "Nitrogen Canister"
	desc = "Contains a canister of Nitrogen."
	cost = 2000
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	crate_name = "nitrogen canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/nitrous_oxide_canister
	name = "Nitrous Oxide Canister"
	desc = "Contains a canister of Nitrous Oxide. Requires Atmospherics access to open."
	cost = 3000
	access = ACCESS_ATMOSPHERICS
	access_view = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrous_oxide)
	crate_name = "nitrous oxide canister crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/materials/oxygen
	name = "Oxygen Canister"
	desc = "Contains a canister of Oxygen. Canned in Druidia."
	cost = 1500
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	crate_name = "oxygen canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/watertank
	name = "Water Tank Crate"
	desc = "Contains a tank of dihydrogen monoxide... sounds dangerous."
	cost = 700
	contains = list(/obj/structure/reagent_dispensers/watertank)
	crate_name = "water tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/water_vapor
	name = "Water Vapor Canister"
	desc = "Contains a canister of Water Vapor. I swear to god if you open this in the halls..."
	cost = 2500
	contains = list(/obj/machinery/portable_atmospherics/canister/water_vapor)
	crate_name = "water vapor canister crate"
	crate_type = /obj/structure/closet/crate/large

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/medical
	group = "Medical"
	access_view = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/medical

/datum/supply_pack/medical/bloodpacks
	name = "Blood Pack Variety Crate"
	desc = "Contains many different blood packs for reintroducing blood to patients."
	cost = 3500
	contains = list(/obj/item/reagent_containers/blood,
					/obj/item/reagent_containers/blood,
					/obj/item/reagent_containers/blood/APlus,
					/obj/item/reagent_containers/blood/AMinus,
					/obj/item/reagent_containers/blood/BPlus,
					/obj/item/reagent_containers/blood/BMinus,
					/obj/item/reagent_containers/blood/OPlus,
					/obj/item/reagent_containers/blood/OMinus,
					/obj/item/reagent_containers/blood/lizard,
					/obj/item/reagent_containers/blood/vox,
					/obj/item/reagent_containers/blood/ethereal)
	crate_name = "blood freezer"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/medical/medipen_variety
	name = "Medipen Variety-Pak"
	desc = "Contains eight different medipens in three different varieties, to assist in quickly treating seriously injured patients."
	cost = 2000
	contains = list(/obj/item/reagent_containers/autoinjector/medipen,
					/obj/item/reagent_containers/autoinjector/medipen,
					/obj/item/reagent_containers/autoinjector/medipen/ekit,
					/obj/item/reagent_containers/autoinjector/medipen/ekit,
					/obj/item/reagent_containers/autoinjector/medipen/ekit,
					/obj/item/reagent_containers/autoinjector/medipen/blood_loss,
					/obj/item/reagent_containers/autoinjector/medipen/blood_loss,
					/obj/item/reagent_containers/autoinjector/medipen/blood_loss,
	)
	crate_name = "medipen crate"

/datum/supply_pack/medical/firstaid_single
	name = "First Aid Kit Single-Pack"
	desc = "Contains one first aid kit for healing most types of wounds."
	cost = 150
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/regular)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidbruises_single
	name = "Bruise Treatment Kit Single-Pack"
	desc = "Contains one first aid kit focused on healing bruises and broken bones."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/brute)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidburns_single
	name = "Burn Treatment Kit Single-Pack"
	desc = "Contains one first aid kit focused on healing severe burns."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/fire)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidtoxins_single
	name = "Toxin Treatment Kit Single-Pack"
	desc = "Contains one first aid kit focused on healing damage dealt by heavy toxins."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/toxin)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidoxygen_single
	name = "Oxygen Deprivation Kit Single-Pack"
	desc = "Contains three first aid kits focused on helping oxygen deprivation victims."
	cost = 70 //oxygen damage tends to be far rarer and these kits use perf which is objectively bad without any toxin healing
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/o2)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidadvanced_single
	name = "Advanced Treatment Kit Single-Pack"
	desc = "Contains one advanced first aid kit able to heal many advanced ailments."
	cost = 600
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/advanced)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypospraykitvial_single
	name = "Hypospray Kit Single-Pack"
	desc = "Contains a hypospray kit containing a hypospray and empty vials for applying reagents to patients."
	cost = 200
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/vial)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypovialkitbasic_single
	name = "Basic Hypospray Vial Kit Single-Pack"
	desc = "Contains a hypospray vial kit containing hypospray vials for most common situations."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/basic)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypovialkitbrute_single
	name = "Brute Hypospray Vial Kit Single-Pack"
	desc = "Contains a hypospray vial kit containing hypospray vials to treat most blunt trauma."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/brute)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypovialkitburn_single
	name = "Burn Hypospray Vial Kit Single-Pack"
	desc = "Contains a hypospray vial kit containing hypospray vials to treat most burns."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/burn)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypovialkittox_single
	name = "Toxin Hypospray Vial Kit Single-Pack"
	desc = "Contains a hypospray vial kit containing hypospray vials to cure toxic damage."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/toxin)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypovialkitoxy_single
	name = "Oxygen Hypospray Vial Kit Single-Pack"
	desc = "Contains a hypospray vial kit containing a vials to treat suffication."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/oxygen)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/hypovialkitadv_single
	name = "Advanced Hypospray Vial Kit Single-Pack"
	desc = "Contains an advanced hypospray vial kit containing vials for most situations."
	cost = 200
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/hypospray/advanced)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/medipen_twopak
	name = "Medipen Two-Pak"
	desc = "Contains one standard epinephrine medipen and one standard emergency first-aid kit medipen. For when you want to prepare for the worst."
	cost = 500
	contains = list(/obj/item/reagent_containers/autoinjector/medipen, /obj/item/reagent_containers/autoinjector/medipen/ekit)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/chemical
	name = "Chemical Starter Kit Crate"
	desc = "Contains thirteen different chemicals, for all the fun experiments you can make."
	cost = 1700
	contains = list(/obj/item/reagent_containers/glass/bottle/hydrogen,
					/obj/item/reagent_containers/glass/bottle/carbon,
					/obj/item/reagent_containers/glass/bottle/nitrogen,
					/obj/item/reagent_containers/glass/bottle/oxygen,
					/obj/item/reagent_containers/glass/bottle/fluorine,
					/obj/item/reagent_containers/glass/bottle/phosphorus,
					/obj/item/reagent_containers/glass/bottle/silicon,
					/obj/item/reagent_containers/glass/bottle/chlorine,
					/obj/item/reagent_containers/glass/bottle/radium,
					/obj/item/reagent_containers/glass/bottle/sacid,
					/obj/item/reagent_containers/glass/bottle/ethanol,
					/obj/item/reagent_containers/glass/bottle/potassium,
					/obj/item/reagent_containers/glass/bottle/sugar,
					/obj/item/clothing/glasses/science,
					/obj/item/reagent_containers/dropper,
					/obj/item/storage/box/beakers)
	crate_name = "chemical crate"

/datum/supply_pack/medical/lemoline
	name = "Lemoline Import Crate"
	desc = "Contains a beaker of lemoline, used in the production of several powerful medicines."
	cost = 700
	contains = list(/obj/item/reagent_containers/glass/beaker/large/lemoline)
	crate_name = "imported chemical crate"

/datum/supply_pack/medical/defibs
	name = "Defibrillator Crate"
	desc = "Contains two defibrillators for bringing the recently deceased back to life."
	cost = 2500
	contains = list(/obj/item/defibrillator/loaded,
					/obj/item/defibrillator/loaded)
	crate_name = "defibrillator crate"

/datum/supply_pack/medical/supplies
	name = "Medical Supplies Crate"
	desc = "Contains several medical supplies. German doctor not included."
	cost = 2000
	contains = list(/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/pill/insulin,
					/obj/item/stack/medical/gauze,
					/obj/item/storage/box/beakers,
					/obj/item/storage/box/medsprays,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/bodybags,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/fire,
					/obj/item/defibrillator/loaded,
					/obj/item/reagent_containers/blood/OMinus,
					/obj/item/storage/pill_bottle/mining,
					/obj/item/reagent_containers/pill/neurine,
					/obj/item/stack/medical/bone_gel,
					/obj/item/stack/medical/bone_gel,
					/obj/item/vending_refill/medical)
	crate_name = "medical supplies crate"

/datum/supply_pack/medical/supplies/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 10)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/medical/gummies
	name = "Gummy Bear Bottle Crate"
	desc = "Contains several assorted bottles of gummy bears."
	cost = 4000
	contains = list(/obj/item/storage/pill_bottle/gummies/vitamin,
					/obj/item/storage/pill_bottle/gummies/melatonin,
					/obj/item/storage/pill_bottle/gummies/nitro,
					/obj/item/storage/pill_bottle/gummies/mime)
	crate_name = "gummy bear crate"
	small_item = TRUE

/datum/supply_pack/medical/gummies/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 6)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/medical/gummies/illegal
	name = "Illegal Gummy Bear Bottle Crate"
	desc = "Contains several assorted bottles of less-than-legal gummy bears."
	cost = 5000
	contains = list(/obj/item/storage/pill_bottle/gummies/meth,
					/obj/item/storage/pill_bottle/gummies/drugs,
					/obj/item/storage/pill_bottle/gummies/floorbear,
					/obj/item/storage/pill_bottle/gummies/mindbreaker,
					/obj/item/storage/pill_bottle/gummies/omnizine)
	crate_name = "illegal gummy bear crate"
	contraband = TRUE
	small_item = TRUE

/datum/supply_pack/medical/gummies/illegal/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 6)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/medical/surgery
	name = "Surgical Supplies Crate"
	desc = "Do you want to perform surgery, but don't have one of those fancy shmancy degrees? Just get started with this crate containing a medical duffelbag, Sterilizine spray and collapsible roller bed."
	cost = 3000
	contains = list(/obj/item/storage/backpack/duffelbag/med/surgery,
					/obj/item/reagent_containers/medspray/sterilizine,
					/obj/item/roller)
	crate_name = "surgical supplies crate"

/datum/supply_pack/medical/salglucanister
	name = "Heavy-Duty Saline Canister"
	desc = "Contains a bulk supply of saline-glucose condensed into a single canister that should last several days, with a large pump to fill containers with. Direct injection of saline should be left to medical professionals as the pump is capable of overdosing patients. Requires medbay access to open."
	cost = 3000
	access = ACCESS_MEDICAL
	contains = list(/obj/machinery/iv_drip/saline)

/datum/supply_pack/medical/virus
	name = "Virus Crate"
	desc = "Contains twelve different bottles, containing several viral samples for virology research. Also includes seven beakers and syringes. Balled-up jeans not included. Requires CMO access to open."
	cost = 2500
	access = ACCESS_CMO
	access_view = ACCESS_VIROLOGY
	contains = list(/obj/item/reagent_containers/glass/bottle/flu_virion,
					/obj/item/reagent_containers/glass/bottle/cold,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/reagent_containers/glass/bottle/magnitis,
					/obj/item/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/reagent_containers/glass/bottle/brainrot,
					/obj/item/reagent_containers/glass/bottle/anxiety,
					/obj/item/reagent_containers/glass/bottle/beesease,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/beakers,
					/obj/item/reagent_containers/glass/bottle/mutagen)
	crate_name = "virus crate"
	crate_type = /obj/structure/closet/crate/secure/medical
	dangerous = TRUE

/datum/supply_pack/medical/vending
	name = "Medical Vending Crate"
	desc = "Contains one NanoMed Plus refill, one wall-mounted NanoMed refill, and one wall-mounted HypoMed refill."
	cost = 2500
	contains = list(/obj/item/vending_refill/medical,
					/obj/item/vending_refill/wallmed,
					/obj/item/vending_refill/wallhypo)
	crate_name = "medical vending crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/science
	group = "Science"
	access_view = ACCESS_SCIENCE
	crate_type = /obj/structure/closet/crate/science

/datum/supply_pack/science/plasma
	name = "Plasma Assembly Crate"
	desc = "Everything you need to burn something to the ground, this contains three plasma assembly sets. Each set contains a plasma tank, igniter, proximity sensor, and timer! Warranty void if exposed to high temperatures. Requires Toxins access to open."
	cost = 1000
	access = ACCESS_TOXINS_STORAGE
	access_view = ACCESS_TOXINS_STORAGE
	contains = list(/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer)
	crate_name = "plasma assembly crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/science/robotics
	name = "Robotics Assembly Crate"
	desc = "The tools you need to replace those finicky humans with a loyal robot army! Contains four proximity sensors, two empty first aid kits, two health analyzers, two red hardhats, two mechanical toolboxes, and two cleanbot assemblies! Requires Robotics access to open."
	cost = 1500
	access = ACCESS_ROBO_CONTROL
	access_view = ACCESS_ROBO_CONTROL
	contains = list(/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/storage/firstaid,
					/obj/item/storage/firstaid,
					/obj/item/healthanalyzer,
					/obj/item/healthanalyzer,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/bot_assembly/cleanbot,
					/obj/item/bot_assembly/cleanbot)
	crate_name = "robotics assembly crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/rped
	name = "RPED crate"
	desc = "Need to rebuild the ORM but science got annihialted after a bomb test? Buy this for the most advanced parts NT can give you."
	cost = 1500
	access_view = FALSE
	contains = list(/obj/item/storage/part_replacer/cargo)
	crate_name = "\improper RPED crate"

/datum/supply_pack/science/shieldwalls
	name = "Shield Generator Crate"
	desc = "These high powered Shield Wall Generators are guaranteed to keep any unwanted lifeforms on the outside, where they belong! Contains four shield wall generators. Requires Teleporter access to open."
	cost = 2000
	access = ACCESS_TELEPORTER
	access_view = ACCESS_TELEPORTER
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	crate_name = "shield generators crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/modularpc
	name = "Deluxe Silicate Selections restocking unit"
	desc = "What's a computer? Contains Deluxe Silicate Selections restocking unit."
	cost = 1500
	contains = list(/obj/item/vending_refill/modularpc)
	crate_name = "computer supply crate"

/datum/supply_pack/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	desc = "The key ingredient for making a lot of people very angry very fast. Contains two tank transfer valves. Requires RD access to open."
	cost = 6000
	access = ACCESS_RD
	contains = list(/obj/item/transfer_valve,
					/obj/item/transfer_valve)
	crate_name = "tank transfer valves crate"
	crate_type = /obj/structure/closet/crate/secure/science
	dangerous = TRUE

/datum/supply_pack/science/genetics
	name = "Genetics Resupply Crate"
	desc = "It's got what geneticists crave, its got Monkey Cubes!."
	cost = 750
	contains = list(/obj/item/vending_refill/wallgene)
	crate_name = "Genetics Crate"

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Service //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/service
	group = "Service"

/datum/supply_pack/service/cargo_supples
	name = "Cargo Supplies Crate"
	desc = "Sold everything that wasn't bolted down? You can get right back to work with this crate containing stamps, an export scanner, destination tagger, hand labeler and some package wrapping."
	cost = 1000
	contains = list(/obj/item/stamp,
					/obj/item/stamp/denied,
					/obj/item/export_scanner,
					/obj/item/destTagger,
					/obj/item/hand_labeler,
					/obj/item/stack/packageWrap)
	crate_name = "cargo supplies crate"

/datum/supply_pack/service/noslipfloor
	name = "High-traction Floor Tiles"
	desc = "Make slipping a thing of the past with thirty industrial-grade anti-slip floortiles!"
	cost = 2000
	access_view = ACCESS_JANITOR
	contains = list(/obj/item/stack/tile/noslip/thirty)
	crate_name = "high-traction floor tiles crate"

/datum/supply_pack/service/janitor
	name = "Janitorial Supplies Crate"
	desc = "Fight back against dirt and grime with Nanotrasen's Janitorial Essentials(tm)! Contains three buckets, caution signs, and cleaner grenades. Also has a single mop, spray cleaner, rag, and trash bag."
	cost = 1000
	access_view = ACCESS_JANITOR
	contains = list(/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/mop,
					/obj/item/broom,
					/obj/item/clothing/suit/caution,
					/obj/item/clothing/suit/caution,
					/obj/item/clothing/suit/caution,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner)
	crate_name = "janitorial supplies crate"

/datum/supply_pack/service/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	desc = "The keystone to any successful janitor. As long as you have feet, this pair of galoshes will keep them firmly planted on the ground. Also contains a janitorial cart."
	cost = 2000
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	crate_name = "janitorial cart crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/janitor/janitank
	name = "Janitor Backpack Crate"
	desc = "Call forth divine judgement upon dirt and grime with this high capacity janitor backpack. Contains 500 units of station-cleansing cleaner. Requires janitor access to open."
	cost = 1000
	access = ACCESS_JANITOR
	contains = list(/obj/item/watertank/janitor)
	crate_name = "janitor backpack crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/service/mule
	name = "MULEbot Crate"
	desc = "Pink-haired Quartermaster not doing her job? Replace her with this tireless worker, today!"
	cost = 2000
	contains = list(/mob/living/simple_animal/bot/mulebot)
	crate_name = "\improper MULEbot Crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/party
	name = "Party Equipment"
	desc = "Celebrate both life and death on the station with Nanotrasen's Party Essentials(tm)! Contains seven colored glowsticks, four beers, two ales, and a bottle of patron, goldschlager, and shaker!"
	cost = 2000
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/reagent_containers/food/drinks/bottle/patron,
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/reagent_containers/food/drinks/ale,
					/obj/item/reagent_containers/food/drinks/ale,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/flashlight/glowstick,
					/obj/item/flashlight/glowstick/red,
					/obj/item/flashlight/glowstick/blue,
					/obj/item/flashlight/glowstick/cyan,
					/obj/item/flashlight/glowstick/orange,
					/obj/item/flashlight/glowstick/yellow,
					/obj/item/flashlight/glowstick/pink)
	crate_name = "party equipment crate"

/datum/supply_pack/service/carpet
	name = "Premium Carpet Crate"
	desc = "Plasteel floor tiles getting on your nerves? These stacks of extra soft carpet will tie any room together."
	cost = 1000
	contains = list(/obj/item/stack/tile/carpet/fifty,
					/obj/item/stack/tile/carpet/fifty,
					/obj/item/stack/tile/carpet/black/fifty,
					/obj/item/stack/tile/carpet/black/fifty,
					/obj/item/stack/tile/carpet/plainblue/fifty, //yogs start - adds coloured carpets
					/obj/item/stack/tile/carpet/plainblue/fifty,
					/obj/item/stack/tile/carpet/plaingreen/fifty,
					/obj/item/stack/tile/carpet/plaingreen/fifty,
					/obj/item/stack/tile/carpet/plainpurple/fifty,
					/obj/item/stack/tile/carpet/plainpurple/fifty) //yogs end
	crate_name = "premium carpet crate"

/datum/supply_pack/service/carpet_exotic
	name = "Exotic Carpet Crate"
	desc = "Exotic carpets straight from Space Russia, for all your decorating needs. Contains 100 tiles each of 8 different flooring patterns."
	cost = 4000
	contains = list(/obj/item/stack/tile/carpet/blue/fifty,
					/obj/item/stack/tile/carpet/blue/fifty,
					/obj/item/stack/tile/carpet/cyan/fifty,
					/obj/item/stack/tile/carpet/cyan/fifty,
					/obj/item/stack/tile/carpet/green/fifty,
					/obj/item/stack/tile/carpet/green/fifty,
					/obj/item/stack/tile/carpet/orange/fifty,
					/obj/item/stack/tile/carpet/orange/fifty,
					/obj/item/stack/tile/carpet/purple/fifty,
					/obj/item/stack/tile/carpet/purple/fifty,
					/obj/item/stack/tile/carpet/red/fifty,
					/obj/item/stack/tile/carpet/red/fifty,
					/obj/item/stack/tile/carpet/royalblue/fifty,
					/obj/item/stack/tile/carpet/royalblue/fifty,
					/obj/item/stack/tile/carpet/royalblack/fifty,
					/obj/item/stack/tile/carpet/royalblack/fifty)
	crate_name = "exotic carpet crate"

/datum/supply_pack/service/lightbulbs
	name = "Replacement Lights"
	desc = "May the light of Aether shine upon this station! Or at least, the light of forty two light tubes and twenty one light bulbs."
	cost = 1000
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	crate_name = "replacement lights"

/datum/supply_pack/service/minerkit
	name = "Shaft Miner Starter Kit"
	desc = "All the miners died too fast? Assistant wants to get a taste of life off-station? Either way, this kit is the best way to turn a regular crewman into an ore-producing, monster-slaying machine. Contains meson goggles, a pickaxe, advanced mining scanner, cargo headset, ore bag, gasmask, an explorer suit and a miner ID upgrade. Requires QM access to open."
	cost = 2500
	access = ACCESS_QM
	access_view = ACCESS_MINING_STATION
	contains = list(/obj/item/storage/backpack/duffelbag/mining_conscript)
	crate_name = "shaft miner starter kit"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/service/vending/bartending
	name = "Booze-o-mat and Coffee Supply Crate"
	desc = "Bring on the booze and coffee vending machine refills."
	cost = 2000
	contains = list(/obj/item/vending_refill/boozeomat,
					/obj/item/vending_refill/coffee)
	crate_name = "bartending supply crate"

/datum/supply_pack/service/vending/cigarette
	name = "Cigarette Supply Crate"
	desc = "Don't believe the reports - smoke today! Contains a cigarette vending machine refill."
	cost = 1500
	contains = list(/obj/item/vending_refill/cigarette)
	crate_name = "cigarette supply crate"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/vending/dinnerware
	name = "Dinnerware Supply Crate"
	desc = "More knives for the chef."
	cost = 1000
	contains = list(/obj/item/vending_refill/dinnerware)
	crate_name = "dinnerware supply crate"

/datum/supply_pack/service/vending/games
	name = "Games Supply Crate"
	desc = "Get your game on with this game vending machine refill."
	cost = 1000
	contains = list(/obj/item/vending_refill/games)
	crate_name = "games supply crate"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/vending/imported
	name = "Imported Vending Machines"
	desc = "Vending machines famous in other parts of the galaxy."
	cost = 4000
	contains = list(/obj/item/vending_refill/sustenance,
					/obj/item/vending_refill/robotics,
					/obj/item/vending_refill/sovietsoda,
					/obj/item/vending_refill/engineering)
	crate_name = "unlabeled supply crate"

/datum/supply_pack/service/vending/ptech
	name = "PTech Supply Crate"
	desc = "Not enough cartridges after half the crew lost their PDA to explosions? This may fix it."
	cost = 1500
	contains = list(/obj/item/vending_refill/cart)
	crate_name = "ptech supply crate"

/datum/supply_pack/service/vending/snack
	name = "Snack Supply Crate"
	desc = "One vending machine refill of cavity-bringin' goodness! The number one dentist recommended order!"
	cost = 1500
	contains = list(/obj/item/vending_refill/snack)
	crate_name = "snacks supply crate"

/datum/supply_pack/service/vending/cola
	name = "Softdrinks Supply Crate"
	desc = "Got whacked by a toolbox, but you still have those pesky teeth? Get rid of those pearly whites with this soda machine refill, today!"
	cost = 1500
	contains = list(/obj/item/vending_refill/cola)
	crate_name = "soft drinks supply crate"

/datum/supply_pack/service/vending/vendomat
	name = "Vendomat Supply Crate"
	desc = "More tools for your IED testing facility."
	cost = 1000
	contains = list(/obj/item/vending_refill/assist)
	crate_name = "vendomat supply crate"

/datum/supply_pack/service/syrup
	name = "Coffee Syrups Box"
	desc = "A packaged box of various syrups, perfect for making your delicious coffee even more diabetic."
	cost = 1400
	contains = list(
		/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/caramel,
		/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/liqueur,
		/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/korta_nectar,
	)
	crate_name = "coffee syrups box"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/syrup_contraband
	contraband = TRUE
	name = "Contraband Syrups Box"
	desc = "A packaged box containing illegal coffee syrups. Possession of these carries a penalty established in the galactic penal code."
	cost = 400
	contains = list(
		/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/laughsyrup,
		/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/laughsyrup,
	)
	crate_name = "illegal syrups box"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/coffeekit
	name = "Coffee Equipment Crate"
	desc = "A complete kit to setup your own cozy coffee shop, the coffeemaker is for some reason not included."
	cost = 1000
	contains = list(
		/obj/item/storage/box/coffeepack/robusta,
		/obj/item/storage/box/coffeepack,
		/obj/item/reagent_containers/food/drinks/bottle/coffeepot,
		/obj/item/storage/box/coffee_condi_display,
		/obj/item/reagent_containers/food/condiment/cream,
		/obj/item/reagent_containers/food/condiment/milk,
		/obj/item/reagent_containers/food/condiment/soymilk,
		/obj/item/reagent_containers/food/condiment/sugar,
		/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/caramel, //one extra syrup as a treat
	)
	crate_name = "coffee equipment crate"

/datum/supply_pack/service/coffeemaker
	name = "Impressa Coffeemaker Crate"
	desc = "An assembled Impressa model coffeemaker."
	cost = 1000
	contains = list(/obj/machinery/coffeemaker/impressa)
	crate_name = "coffeemaker crate"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/emptycrate
	name = "Empty Crate"
	desc = "It's an empty crate, for all your storage needs."
	cost = 700
	contains = list()
	crate_name = "crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Special Clearance////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/clearance
	group = "Unlocked Clearance"
	special = TRUE
	small_item = TRUE
	crate_type = /obj/structure/closet/crate/secure/cheap //:^

/datum/supply_pack/clearance/ka_damage
	name = "KA Damage Mods"
	desc = "Modifiers for a kinetic accelerator that increase the force of its projectiles."
	cost = 350
	contains = list(/obj/item/borg/upgrade/modkit/damage,/obj/item/borg/upgrade/modkit/damage,/obj/item/borg/upgrade/modkit/damage)

/datum/supply_pack/clearance/ka_cooldown
	name = "KA Cooldown Mods"
	desc = "Modifiers for a kinetic accelerator that decrease the time needed for the accelerator to cool between shots."
	cost = 350
	contains = list(/obj/item/borg/upgrade/modkit/cooldown,/obj/item/borg/upgrade/modkit/cooldown,/obj/item/borg/upgrade/modkit/cooldown)

/datum/supply_pack/clearance/ka_range
	name = "KA Range Mods"
	desc = "Modifiers for a kinetic accelerator that increase the range of its projectiles."
	cost = 350
	contains = list(/obj/item/borg/upgrade/modkit/range,/obj/item/borg/upgrade/modkit/range,/obj/item/borg/upgrade/modkit/range)

/datum/supply_pack/clearance/special_mods
	name = "KA Special Mods"
	desc = "Modifiers for a kinetic accelerator that significantly change its properties. Comes in four different forms."
	cost = 750
	contains = list(/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs, /obj/item/borg/upgrade/modkit/cooldown/repeater, /obj/item/borg/upgrade/modkit/resonator_blasts, /obj/item/borg/upgrade/modkit/bounty)

/datum/supply_pack/clearance/kacrate
	name = "Kinetic Accelerator Crate"
	desc = "Two Kinetic Accelerators, self recharging, ranged mining tools that do increased damage in low pressure."
	cost = 900
	contains = list(/obj/item/gun/energy/kinetic_accelerator, /obj/item/gun/energy/kinetic_accelerator)

/datum/supply_pack/clearance/plasmacutter
	name = "Plasmacutter Crate"
	desc = "Two plasmacutters, experimental mining equipment that uses heated plasma as fuel."
	cost = 900
	contains = list(/obj/item/gun/energy/plasmacutter,/obj/item/gun/energy/plasmacutter)

/datum/supply_pack/clearance/plasmacutter_advanced
	name = "Advanced Plasmacutter Crate"
	desc = "A prototype plasmacutter variant with lower cooldown, more efficient fuel usage, and higher range."
	cost = 2000
	contains = list(/obj/item/gun/energy/plasmacutter/adv)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic
	group = "Food & Hydroponics"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/organic/hydroponics
	access_view = ACCESS_HYDROPONICS

/datum/supply_pack/organic/hydroponics/beekeeping_suits
	name = "Beekeeper Suit Crate"
	desc = "Bee business booming? Better be benevolent and boost botany by bestowing bi-Beekeeper-suits! Contains two beekeeper suits and matching headwear."
	cost = 1000
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	crate_name = "beekeeper suits"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Crate"
	desc = "BEES BEES BEES. Contains three honey frames, a beekeeper suit and helmet, flyswatter, bee house, and, of course, a pure-bred Nanotrasen-Standardized Queen Bee!"
	cost = 1500
	contains = list(/obj/structure/beebox/unwrenched,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/melee/flyswatter)
	crate_name = "beekeeping starter crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/randomized/donkpockets
	name = "Donk Pocket Variety Crate"
	desc = "Featuring a line up of Donk Co.'s most popular pastry!"
	cost = 2000
	contains = list(/obj/item/storage/box/donkpockets/donkpocketspicy,
	/obj/item/storage/box/donkpockets/donkpocketteriyaki,
	/obj/item/storage/box/donkpockets/donkpocketpizza,
	/obj/item/storage/box/donkpockets/donkpocketberry,
	/obj/item/storage/box/donkpockets/donkpockethonk,
	/obj/item/storage/box/donkpockets)
	crate_name = "donk pocket crate"

/datum/supply_pack/organic/randomized/chef
	name = "Excellent Meat Crate"
	desc = "The best cuts in the whole galaxy."
	cost = 1000
	small_item = TRUE
	contains = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/slime,
					/obj/item/reagent_containers/food/snacks/meat/slab/killertomato,
					/obj/item/reagent_containers/food/snacks/meat/slab/bear,
					/obj/item/reagent_containers/food/snacks/meat/slab/xeno,
					/obj/item/reagent_containers/food/snacks/meat/slab/spider,
					/obj/item/reagent_containers/food/snacks/meat/rawbacon,
					/obj/item/reagent_containers/food/snacks/meat/slab/penguin,
					/obj/item/reagent_containers/food/snacks/spiderleg,
					/obj/item/reagent_containers/food/snacks/carpmeat,
					/obj/item/reagent_containers/food/snacks/meat/slab/human)
	crate_name = "food crate"

/datum/supply_pack/organic/randomized/chef/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 15)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/organic/exoticseeds
	name = "Exotic Seeds Crate"
	desc = "Any entrepreneuring botanist's dream. Contains fourteen different seeds, including three replica-pod seeds and two mystery seeds!"
	cost = 1500
	access_view = ACCESS_HYDROPONICS
	contains = list(/obj/item/seeds/nettle,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/plump,
					/obj/item/seeds/liberty,
					/obj/item/seeds/amanita,
					/obj/item/seeds/reishi,
					/obj/item/seeds/bamboo,
					/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/rainbow_bunch,
					/obj/item/seeds/rainbow_bunch,
					/obj/item/seeds/random,
					/obj/item/seeds/random)
	crate_name = "exotic seeds crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/food
	name = "Food Crate"
	desc = "Get things cooking with this crate full of useful ingredients! Contains a dozen eggs, three bananas, and some flour, rice, milk, soymilk, salt, pepper, cinnamon, enzyme, sugar, and monkeymeat." // yogs
	cost = 1000
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/reagent_containers/food/condiment/cinnamon, // Yogs -- Adds cinnamon shakers to this crate
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/food/snacks/meat/slab/monkey,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana)
	crate_name = "food crate"

/datum/supply_pack/organic/randomized/chef/fruits
	name = "Fruit Crate"
	desc = "Rich of vitamins, may contain oranges."
	cost = 1500
	contains = list(/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
					/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
					/obj/item/reagent_containers/food/snacks/grown/watermelon,
					/obj/item/reagent_containers/food/snacks/grown/apple,
					/obj/item/reagent_containers/food/snacks/grown/berries,
					/obj/item/reagent_containers/food/snacks/grown/citrus/lemon)
	crate_name = "food crate"

/datum/supply_pack/organic/cream_pie
	name = "High-yield Clown-grade Cream Pie Crate"
	desc = "Designed by Aussec's Advanced Warfare Research Division, these high-yield, Clown-grade cream pies are powered by a synergy of performance and efficiency. Guaranteed to provide maximum results."
	cost = 4500
	contains = list(/obj/item/storage/backpack/duffelbag/clown/cream_pie)
	crate_name = "party equipment crate"
	access = ACCESS_THEATRE
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/organic/hydroponics
	name = "Hydroponics Crate"
	desc = "Supplies for growing a great garden! Contains two bottles of ammonia, two Plant-B-Gone spray bottles, a hatchet, cultivator, plant analyzer, as well as a pair of leather gloves and a botanist's apron."
	cost = 1500
	contains = list(/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/hatchet,
					/obj/item/cultivator,
					/obj/item/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron,
					/obj/item/storage/box/disks_plantgene)
	crate_name = "hydroponics crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/hydrotank
	name = "Hydroponics Backpack Crate"
	desc = "Bring on the flood with this high-capacity backpack crate. Contains 500 units of life-giving H2O. Requires hydroponics access to open."
	cost = 1000
	access = ACCESS_HYDROPONICS
	contains = list(/obj/item/watertank)
	crate_name = "hydroponics backpack crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/organic/pizza
	name = "Pizza Crate"
	desc = "Best prices on this side of the galaxy. All deliveries are guaranteed to be 99% anomaly-free!"
	cost = 6000 // Best prices this side of the galaxy.
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/pineapple,
					/obj/item/pizzabox/seafood,
					/obj/item/pizzabox/sassysage,
					/obj/item/pizzabox/donkpocket)
	crate_name = "pizza crate"
	var/static/anomalous_box_provided = FALSE

/datum/supply_pack/organic/pizza/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 6)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/organic/pizza/fill(obj/structure/closet/crate/C)
	. = ..()
	if(!anomalous_box_provided)
		for(var/obj/item/pizzabox/P in C)
			if(prob(1)) //1% chance for each box, so 4% total chance per order
				var/obj/item/pizzabox/infinite/fourfiveeight = new(C)
				fourfiveeight.boxtag = P.boxtag
				qdel(P)
				anomalous_box_provided = TRUE
				log_game("An anomalous pizza box was provided in a pizza crate at during cargo delivery")
				if(prob(50))
					addtimer(CALLBACK(src, PROC_REF(anomalous_pizza_report)), rand(300, 1800))
				else
					message_admins("An anomalous pizza box was silently created with no command report in a pizza crate delivery.")
				break

/datum/supply_pack/organic/pizza/proc/anomalous_pizza_report()
	print_command_report("[station_name()], our anomalous materials divison has reported a missing object that is highly likely to have been sent to your station during a routine cargo \
	delivery. Please search all crates and manifests provided with the delivery and return the object if is located. The object resembles a standard <b>\[DATA EXPUNGED\]</b> and is to be \
	considered <b>\[REDACTED\]</b> and returned at your leisure. Note that objects the anomaly produces are specifically attuned exactly to the individual opening the anomaly; regardless \
	of species, the individual will find the object edible and it will taste great according to their personal definitions, which vary significantly based on person and species.")

/datum/supply_pack/organic/potted_plants
	name = "Potted Plants Crate"
	desc = "Spruce up the station with these lovely plants! Contains a random assortment of five potted plants from Nanotrasen's potted plant research division. Warranty void if thrown."
	cost = 700
	contains = list(/obj/item/kirbyplants/random,
					/obj/item/kirbyplants/random,
					/obj/item/kirbyplants/random,
					/obj/item/kirbyplants/random,
					/obj/item/kirbyplants/random)
	crate_name = "potted plants crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/seeds
	name = "Seeds Crate"
	desc = "Big things have small beginnings. Contains fourteen different seeds."
	cost = 1000
	contains = list(/obj/item/seeds/chili,
					/obj/item/seeds/cotton,
					/obj/item/seeds/berry,
					/obj/item/seeds/corn,
					/obj/item/seeds/eggplant,
					/obj/item/seeds/tomato,
					/obj/item/seeds/soya,
					/obj/item/seeds/wheat,
					/obj/item/seeds/wheat/rice,
					/obj/item/seeds/carrot,
					/obj/item/seeds/sunflower,
					/obj/item/seeds/chanter,
					/obj/item/seeds/potato,
					/obj/item/seeds/sugarcane,
					/obj/item/seeds/cucumber)
	crate_name = "seeds crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/randomized/chef/vegetables
	name = "Vegetables Crate"
	desc = "Grown in vats."
	cost = 1300
	contains = list(/obj/item/reagent_containers/food/snacks/grown/chili,
					/obj/item/reagent_containers/food/snacks/grown/corn,
					/obj/item/reagent_containers/food/snacks/grown/tomato,
					/obj/item/reagent_containers/food/snacks/grown/potato,
					/obj/item/reagent_containers/food/snacks/grown/carrot,
					/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
					/obj/item/reagent_containers/food/snacks/grown/onion,
					/obj/item/reagent_containers/food/snacks/grown/pumpkin,
					/obj/item/reagent_containers/food/snacks/grown/cucumber)
	crate_name = "food crate"

/datum/supply_pack/organic/classic_ice_cream
	name = "Big Top Ice Cream Classics Crate"
	desc = "A crate with the classic flavors of vanilla, chocolate, and strawberry."
	cost = 600
	contains = list(/obj/item/storage/box/ice_cream_carton/vanilla,
					/obj/item/storage/box/ice_cream_carton/chocolate,
					/obj/item/storage/box/ice_cream_carton/strawberry)
	crate_name = "classic ice cream crate"

/datum/supply_pack/organic/fruity_ice_cream
	name = "Big Top Ice Cream Fruity Crate"
	desc = "A crate with the fruity flavors of banana, peach, and cherry chocolate."
	cost = 600
	contains = list(/obj/item/storage/box/ice_cream_carton/banana,
					/obj/item/storage/box/ice_cream_carton/peach,
					/obj/item/storage/box/ice_cream_carton/cherry_chocolate)
	crate_name = "fruity ice cream crate"

/datum/supply_pack/organic/sweet_ice_cream
	name = "Big Top Ice Cream Sweets Crate"
	desc = "A crate with the sweet flavors of caramel, orange creamsicle, and plain ice cream."
	cost = 600
	contains = list(/obj/item/storage/box/ice_cream_carton/caramel,
					/obj/item/storage/box/ice_cream_carton/orange_creamsicle,
					/obj/item/storage/box/ice_cream_carton)
	crate_name = "sweet ice cream crate"

/datum/supply_pack/organic/special_ice_cream
	name = "Big Top Ice Cream Special Crate"
	desc = "A crate with the special flavors of blue, lemon, and meat."
	cost = 600
	contains = list(/obj/item/storage/box/ice_cream_carton/blue,
					/obj/item/storage/box/ice_cream_carton/lemon_sorbet,
					/obj/item/storage/box/ice_cream_carton/meat)
	crate_name = "special ice cream crate"

/datum/supply_pack/organic/ice_cream_cones
	name = "Big Top Ice Cream Cones Crate"
	desc = "A crate with two cake and chocolate cone boxes each."
	cost = 600
	contains = list(/obj/item/storage/box/ice_cream_carton/cone,
					/obj/item/storage/box/ice_cream_carton/cone,
					/obj/item/storage/box/ice_cream_carton/cone/chocolate,
					/obj/item/storage/box/ice_cream_carton/cone/chocolate)
	crate_name = "ice cream cone crate"

/datum/supply_pack/organic/vending/hydro_refills
	name = "Hydroponics Vending Machines Refills"
	desc = "When the clown takes all the banana seeds. Contains a NutriMax refill and an MegaSeed Servitor refill."
	cost = 2000
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/vending_refill/hydroseeds,
					/obj/item/vending_refill/hydronutrients)
	crate_name = "hydroponics supply crate"

/datum/supply_pack/organic/grill
	name = "Grilling Starter Kit"
	desc = "Hey dad I'm Hungry. Hi Hungry I'm THE NEW GRILLING STARTER KIT ONLY 5000 BUX GET NOW! Contains a grill and fuel."
	cost = 5000
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/stack/sheet/mineral/coal/five,
					/obj/machinery/grill/unwrenched,
					/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy
					)
	crate_name = "grilling starter kit crate"

/datum/supply_pack/organic/grillfuel
	name = "Grilling Fuel Kit"
	desc = "Contains propane and propane accessories. (Note: doesn't contain any actual propane.)"
	cost = 2000
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/stack/sheet/mineral/coal/ten,
					/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy
					)
	crate_name = "grilling fuel kit crate"

/datum/supply_pack/organic/food_cart
	name = "Food Cart Crate"
	desc = "Contains a food cart for all your mobile food needs."
	cost = 5000
	crate_type = /obj/structure/closet/crate/large
	contains = list(/obj/machinery/food_cart)
	crate_name = "food cart crate"

/datum/supply_pack/organic/icecream_vat
	name = "Ice cream Vat Crate"
	desc = "A vat of ice-cold icecream for those hot shifts in Atmospherics."
	cost = 5000
	crate_type = /obj/structure/closet/crate/large
	contains = list(/obj/machinery/icecream_vat)
	crate_name = "ice cream vat crate"

//////////////////////////////////////////////////////////////////////////////
////////////////////////////// Livestock /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/critter
	group = "Livestock"
	crate_type = /obj/structure/closet/crate/critter

/datum/supply_pack/critter/parrot
	name = "Bird Crate"
	desc = "Contains five expert telecommunication birds."
	cost = 4000
	contains = list(/mob/living/simple_animal/parrot)
	crate_name = "parrot crate"

/datum/supply_pack/critter/parrot/generate()
	. = ..()
	for(var/i in 1 to 4)
		new /mob/living/simple_animal/parrot(.)
	if(prob(1))
		new /mob/living/simple_animal/parrot/clock_hawk(.)

/datum/supply_pack/critter/butterfly
	name = "Butterflies Crate"
	desc = "Not a very dangerous insect, but they do give off a better image than, say, flies or cockroaches."//is that a motherfucking worm reference
	contraband = TRUE
	cost = 5000
	contains = list(/mob/living/simple_animal/butterfly)
	crate_name = "entomology samples crate"

/datum/supply_pack/critter/butterfly/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/butterfly(.)

/datum/supply_pack/critter/cat
	name = "Cat Crate"
	desc = "The cat goes meow! Comes with a collar and a nice cat toy! Cheeseburger not included."//i can't believe im making this reference
	cost = 5000 //Cats are worth as much as corgis.
	contains = list(/mob/living/simple_animal/pet/cat,
					/obj/item/clothing/neck/petcollar,
					/obj/item/toy/cattoy)
	crate_name = "cat crate"

/datum/supply_pack/critter/cat/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/cat/C = locate() in .
		qdel(C)
		new /mob/living/simple_animal/pet/cat/Proc(.)

/datum/supply_pack/critter/chick
	name = "Chicken Crate"
	desc = "The chicken goes bwaak!"
	cost = 1000
	contains = list(/mob/living/simple_animal/chick)
	crate_name = "chicken crate"

/datum/supply_pack/critter/corgi
	name = "Corgi Crate"
	desc = "Considered the optimal dog breed by thousands of research scientists, this Corgi is but one dog from the millions of Ian's noble bloodline. Comes with a cute collar!"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/corgi,
					/obj/item/clothing/neck/petcollar)
	crate_name = "corgi crate"

/datum/supply_pack/critter/corgi/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/dog/corgi/D = locate() in .
		if(D.gender == FEMALE)
			qdel(D)
			new /mob/living/simple_animal/pet/dog/corgi/Lisa(.)

/datum/supply_pack/critter/bullterrier
	name = "Bull Terrier Crate"
	desc = "Like a normal dog, but with a head the shape of an egg. Comes with a nice collar!"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/bullterrier,
					/obj/item/clothing/neck/petcollar)
	crate_name = "bull terrier crate"

/datum/supply_pack/critter/cow
	name = "Cow Crate"
	desc = "The cow goes moo!"
	cost = 1500
	contains = list(/mob/living/simple_animal/cow)
	crate_name = "cow crate"

/datum/supply_pack/critter/crab
	name = "Crab Rocket"
	desc = "CRAAAAAAB ROCKET. CRAB ROCKET. CRAB ROCKET. CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB ROCKET. CRAFT. ROCKET. BUY. CRAFT ROCKET. CRAB ROOOCKET. CRAB ROOOOCKET. CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB ROOOOOOOOOOOOOOOOOOOOOOCK EEEEEEEEEEEEEEEEEEEEEEEEE EEEETTTTTTTTTTTTAAAAAAAAA AAAHHHHHHHHHHHHH. CRAB ROCKET. CRAAAB ROCKEEEEEEEEEGGGGHHHHTT CRAB CRAB CRAABROCKET CRAB ROCKEEEET."//fun fact: i actually spent like 10 minutes and transcribed the entire video.
	cost = 5000
	contains = list(/mob/living/simple_animal/crab)
	crate_name = "look sir free crabs"
	DropPodOnly = TRUE

/datum/supply_pack/critter/crab/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/crab(.)

/datum/supply_pack/critter/corgis/exotic
	name = "Exotic Corgi Crate"
	desc = "Corgis fit for a king, these corgis come in a unique color to signify their superiority. Comes with a cute collar!"
	cost = 5500
	contains = list(/mob/living/simple_animal/pet/dog/corgi/exoticcorgi,
					/obj/item/clothing/neck/petcollar)
	crate_name = "exotic corgi crate"

/datum/supply_pack/critter/fox
	name = "Fox Crate"
	desc = "The fox goes...? Comes with a collar!"//what does the fox say
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/fox,
					/obj/item/clothing/neck/petcollar)
	crate_name = "fox crate"

/datum/supply_pack/critter/goat
	name = "Goat Crate"
	desc = "The goat goes baa! Warranty void if used as a replacement for Pete."
	cost = 2500
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)
	crate_name = "goat crate"

/datum/supply_pack/critter/monkey
	name = "Monkey Cube Crate"
	desc = "Stop monkeying around! Contains five monkey cubes. Just add water!"
	cost = 2000
	contains = list (/obj/item/storage/box/monkeycubes)
	crate_type = /obj/structure/closet/crate
	crate_name = "monkey cube crate"

/datum/supply_pack/critter/pug
	name = "Pug Crate"
	desc = "Like a normal dog, but... squished. Comes with a nice collar!"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/pug,
					/obj/item/clothing/neck/petcollar)
	crate_name = "pug crate"

/datum/supply_pack/critter/sheep
	name = "Sheep Crate"
	desc = "The sheep goes baa!"
	cost = 2000
	contains = list(/mob/living/simple_animal/sheep)
	crate_name = "sheep crate"

/datum/supply_pack/critter/snake
	name = "Snake Crate"
	desc = "Tired of these MOTHER FUCKING snakes on this MOTHER FUCKING space station? Then this isn't the crate for you. Contains three non-venomous snakes."
	cost = 3000
	contains = list(/mob/living/simple_animal/hostile/retaliate/poison/snake/novenom,
					/mob/living/simple_animal/hostile/retaliate/poison/snake/novenom,
					/mob/living/simple_animal/hostile/retaliate/poison/snake/novenom)
	crate_name = "snake crate"

/datum/supply_pack/critter/snake/venomous
	name = "Viper Crate"
	desc = "A crate of three Vipers. Handle carefully."
	cost = 5000
	contains = list(/mob/living/simple_animal/hostile/retaliate/poison/snake,
					/mob/living/simple_animal/hostile/retaliate/poison/snake,
					/mob/living/simple_animal/hostile/retaliate/poison/snake)
	crate_name = "viper crate"
	contraband = TRUE

/datum/supply_pack/critter/gator
	name = "Gator Crate"
	desc = "Sewage not included..."
	hidden = TRUE
	cost = 3000
	contains = list(/mob/living/simple_animal/hostile/retaliate/gator,
					/mob/living/simple_animal/hostile/retaliate/gator,
					/mob/living/simple_animal/hostile/retaliate/gator)
	crate_name = "gator crate"

/datum/supply_pack/critter/mothroach
	name = "Mothroach Crate"
	desc = "Put the mothroach on your head and find out what true cuteness looks like."
	cost = 7500
	contains = list(/mob/living/simple_animal/pet/mothroach)
	crate_name = "mothroach crate"

/datum/supply_pack/critter/axolotl
	name = "Axolotl Crate"
	desc = "Contains 4 axolotls to pet."
	cost = 4000
	contains = list(/mob/living/simple_animal/pet/axolotl,
					/mob/living/simple_animal/pet/axolotl,
					/mob/living/simple_animal/pet/axolotl,
					/mob/living/simple_animal/pet/axolotl)
	crate_name = "axolotl crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Costumes & Toys /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/costumes_toys
	group = "Costumes & Toys"

/datum/supply_pack/costumes_toys/randomised
	name = "Collectable Hats Crate"
	desc = "Flaunt your status with three unique, highly-collectable hats!"
	cost = 20000
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/HoP,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	crate_name = "collectable hats crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/contraband
	name = "Contraband Crate"
	desc = "Psst.. bud... want some contraband? I can get you a poster, some nice cigs, dank, even some sponsored items...you know, the good stuff. Just keep it away from the cops, kay?"
	contraband = TRUE
	cost = 3000
	num_contained = 7
	contains = list(/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/reagent_containers/food/snacks/grown/cannabis,
					/obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow,
					/obj/item/reagent_containers/food/snacks/grown/cannabis/white,
					/obj/item/storage/pill_bottle/zoom,
					/obj/item/storage/pill_bottle/happy,
					/obj/item/storage/pill_bottle/lsd,
					/obj/item/storage/pill_bottle/aranesp,
					/obj/item/storage/pill_bottle/stimulant,
					/obj/item/storage/pill_bottle/gummies/omnizine,
					/obj/item/toy/cards/deck/syndicate,
					/obj/item/reagent_containers/food/drinks/bottle/absinthe,
					/obj/item/clothing/under/syndicate/tacticool,
					/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
					/obj/item/storage/fancy/cigarettes/cigpack_shadyjims,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/neck/necklace/dope,
					/obj/item/vending_refill/donksoft)
	crate_name = "crate"

/datum/supply_pack/costumes_toys/foamforce
	name = "Foam Force Crate"
	desc = "Break out the big guns with eight Foam Force shotguns!"
	cost = 1000
	contains = list(/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy)
	crate_name = "foam force crate"

/datum/supply_pack/costumes_toys/foamforce/bonus
	name = "Foam Force Pistols Crate"
	desc = "Psst.. hey bud... remember those old foam force pistols that got discontinued for being too cool? Well I got two of those right here with your name on em. I'll even throw in a spare mag for each, waddya say?"
	contraband = TRUE
	cost = 4000
	contains = list(/obj/item/gun/ballistic/automatic/toy/pistol,
					/obj/item/gun/ballistic/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	crate_name = "foam force crate"

/datum/supply_pack/costumes_toys/formalwear
	name = "Formalwear Crate"
	desc = "You're gonna like the way you look, I guaranteed it. Contains an asston of fancy clothing."
	cost = 3000 //Lots of very expensive items. You gotta pay up to look good!
	contains = list(/obj/item/clothing/under/dress/blacktango,
					/obj/item/clothing/under/rank/civilian/assistantformal,
					/obj/item/clothing/under/rank/civilian/assistantformal,
					/obj/item/clothing/under/rank/civilian/lawyer/bluesuit,
					/obj/item/clothing/suit/toggle/lawyer,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit,
					/obj/item/clothing/suit/toggle/lawyer/purple,
					/obj/item/clothing/under/rank/civilian/lawyer/blacksuit,
					/obj/item/clothing/suit/toggle/lawyer/black,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/neck/tie/blue,
					/obj/item/clothing/neck/tie/red,
					/obj/item/clothing/neck/tie/black,
					/obj/item/clothing/head/bowler,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit/charcoal,
					/obj/item/clothing/under/suit/navy,
					/obj/item/clothing/under/suit/burgundy,
					/obj/item/clothing/under/suit/checkered,
					/obj/item/clothing/under/suit/tan,
					/obj/item/lipstick/random)
	crate_name = "formalwear crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/clownpin
	name = "Hilarious Firing Pin Crate"
	desc = "I uh... I'm not really sure what this does. Wanna buy it?"
	cost = 5000
	contraband = TRUE
	contains = list(/obj/item/firing_pin/clown)
	crate_name = "toy crate" // It's /technically/ a toy. For the clown, at least.
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/lasertag
	name = "Laser Tag Crate"
	desc = "Foam Force is for boys. Laser Tag is for men. Contains three sets of red suits, blue suits, matching helmets, and matching laser tag guns."
	cost = 1500
	contains = list(/obj/item/gun/energy/laser/redtag,
					/obj/item/gun/energy/laser/redtag,
					/obj/item/gun/energy/laser/redtag,
					/obj/item/gun/energy/laser/bluetag,
					/obj/item/gun/energy/laser/bluetag,
					/obj/item/gun/energy/laser/bluetag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	crate_name = "laser tag crate"

/datum/supply_pack/costumes_toys/lasertag/pins
	name = "Laser Tag Firing Pins Crate"
	desc = "Three laser tag firing pins used in laser-tag units to ensure users are wearing their vests."
	cost = 3000
	contraband = TRUE
	contains = list(/obj/item/storage/box/lasertagpins)
	crate_name = "laser tag crate"

/datum/supply_pack/costumes_toys/mech_suits
	name = "Mech Pilot's Suit Crate"
	desc = "Suits for piloting big robots. Contains all three colors!"
	cost = 1500 //state-of-the-art technology doesn't come cheap
	contains = list(/obj/item/clothing/under/costume/mech_suit,
					/obj/item/clothing/under/costume/mech_suit/white,
					/obj/item/clothing/under/costume/mech_suit/blue)
	crate_name = "mech pilot's suit crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/paintball
	name = "Mixed Paintball Supply Crate"
	desc = "Contains four paintball guns and extra ammo."
	cost = 2500
	contraband = TRUE
	contains = list(/obj/item/gun/ballistic/automatic/toy/paintball/blue,
					/obj/item/gun/ballistic/automatic/toy/paintball/blue,
					/obj/item/gun/ballistic/automatic/toy/paintball,
					/obj/item/gun/ballistic/automatic/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball/blue,
					/obj/item/ammo_box/magazine/toy/paintball/blue,
					/obj/item/ammo_box/magazine/toy/paintball/blue)
	crate_name = "mixed paintball supply crate"

/datum/supply_pack/costumes_toys/costume_original
	name = "Original Costume Crate"
	desc = "Reenact Shakespearean plays with this assortment of outfits. Contains eight different costumes!"
	cost = 1000
	contains = list(/obj/item/clothing/head/snowman,
					/obj/item/clothing/suit/snowman,
					/obj/item/clothing/head/chicken,
					/obj/item/clothing/suit/chickensuit,
					/obj/item/clothing/mask/gas/monkeymask,
					/obj/item/clothing/suit/monkeysuit,
					/obj/item/clothing/head/cardborg,
					/obj/item/clothing/suit/cardborg,
					/obj/item/clothing/head/xenos,
					/obj/item/clothing/suit/xenos,
					/obj/item/clothing/suit/hooded/ian_costume,
					/obj/item/clothing/suit/hooded/carp_costume,
					/obj/item/clothing/suit/hooded/bee_costume)
	crate_name = "original costume crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/paintball_ammo
	name = "Paintball Ammo Crate"
	desc = "Plenty of paintball ammo in a variety of colors."
	cost = 700
	contraband = TRUE
	contains = list(/obj/item/ammo_box/magazine/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball,
					/obj/item/ammo_box/magazine/toy/paintball/blue,
					/obj/item/ammo_box/magazine/toy/paintball/blue,
					/obj/item/ammo_box/magazine/toy/paintball/blue,
					/obj/item/ammo_box/magazine/toy/paintball/pink,
					/obj/item/ammo_box/magazine/toy/paintball/pink,
					/obj/item/ammo_box/magazine/toy/paintball/purple,
					/obj/item/ammo_box/magazine/toy/paintball/purple,
					/obj/item/ammo_box/magazine/toy/paintball/orange,
					/obj/item/ammo_box/magazine/toy/paintball/orange)
	crate_name = "paintball ammo crate"

/datum/supply_pack/costumes_toys/costume
	name = "Standard Costume Crate"
	desc = "Supply the station's entertainers with the equipment of their trade with these Nanotrasen-approved costumes! Contains a full clown and mime outfit, along with a bike horn and a bottle of nothing."
	cost = 1000
	access = ACCESS_THEATRE
	contains = list(/obj/item/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/civilian/clown,
					/obj/item/bikehorn,
					/obj/item/clothing/under/rank/civilian/mime,
					/obj/item/clothing/shoes/sneakers/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/frenchberet,
					/obj/item/clothing/suit/suspenders,
					/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/storage/backpack/mime)
	crate_name = "standard costume crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/toys
	name = "Toy Crate"
	desc = "Who cares about pride and accomplishment? Skip the gaming and get straight to the sweet rewards with this product! Contains five random toys. Warranty void if used to prank research directors."
	cost = 5000 // or play the arcade machines ya lazy bum
	num_contained = 5
	contains = list()
	crate_name = "toy crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/toys/generate()
	. = ..()
	var/the_toy
	for(var/i in 1 to num_contained)
		if(prob(50))
			the_toy = pickweight(GLOB.arcade_prize_pool)
		else
			the_toy = pick(subtypesof(/obj/item/toy/plush) - typesof(/obj/item/toy/plush/goatplushie/angry/kinggoat))
			if(istype(the_toy, /obj/item/toy/plush/lizard/azeel/snowflake))
				the_toy = /obj/item/toy/plush/lizard/azeel
		new the_toy(.)

/datum/supply_pack/costumes_toys/archery
	name = "Archery Crate"
	desc = "Shoot apples off of people's heads with this kit that contains everything you need to start your archery career."
	cost = 1000
	contains = list(/obj/item/gun/ballistic/bow,
					/obj/item/storage/belt/quiver/full
	)
	crate_name = "archery crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/toy_bow
	name = "Toy Bow Crate"
	desc = "A crate containing one random toy bow of four to impress your friends with, collect them all!"
	cost = 500
	num_contained = 1
	contains = list(/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/white,
					/obj/item/gun/ballistic/bow/toy/clockwork
	)
	crate_name = "toy bow crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/archery_war
	name = "Archery War Crate"
	desc = "Set up an all out archery war with this simple kit!"
	cost = 5000
	contains = list(/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/gun/ballistic/bow/toy/blue,
					/obj/item/storage/belt/quiver/blue/full,
					/obj/item/storage/belt/quiver/blue/full,
					/obj/item/storage/belt/quiver/blue/full,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/gun/ballistic/bow/toy/red,
					/obj/item/storage/belt/quiver/red/full,
					/obj/item/storage/belt/quiver/red/full,
					/obj/item/storage/belt/quiver/red/full,
					/obj/item/ammo_box/arrow/toy/disabler,
					/obj/item/ammo_box/arrow/toy/energy,
					/obj/item/ammo_box/arrow/toy/pulse,
					/obj/item/ammo_box/arrow/toy/xray,
					/obj/item/ammo_box/arrow/toy/shock,
					/obj/item/ammo_box/arrow/toy/magic
	)
	crate_name = "archery war crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/wizard
	name = "Wizard Costume Crate"
	desc = "Pretend to join the Wizard Federation with this full wizard outfit! Nanotrasen would like to remind its employees that actually joining the Wizard Federation is subject to termination of job and life."
	cost = 2000
	contains = list(/obj/item/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	crate_name = "wizard costume crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	for(var/i in 1 to num_contained)
		var/item = pick_n_take(L)
		new item(C)

/datum/supply_pack/costumes_toys/wardrobes/autodrobe
	name = "Autodrobe Supply Crate"
	desc = "Autodrobe missing your favorite dress? Solve that issue today with this autodrobe refill."
	cost = 1500
	contains = list(/obj/item/vending_refill/autodrobe)
	crate_name = "autodrobe supply crate"

/datum/supply_pack/costumes_toys/wardrobes/cargo
	name = "Cargo Wardrobe Supply Crate"
	desc = "This crate contains a refill for the CargoDrobe."
	cost = 750
	contains = list(/obj/item/vending_refill/wardrobe/cargo_wardrobe)
	crate_name = "cargo department supply crate"

/datum/supply_pack/costumes_toys/wardrobes/engineering
	name = "Engineering Wardrobe Supply Crate"
	desc = "This crate contains refills for the EngiDrobe, AtmosDrobe and NetDrobe."
	cost = 1500
	contains = list(/obj/item/vending_refill/wardrobe/engi_wardrobe,
					/obj/item/vending_refill/wardrobe/atmos_wardrobe,
					/obj/item/vending_refill/wardrobe/sig_wardrobe)
	crate_name = "engineering department wardrobe supply crate"

/datum/supply_pack/costumes_toys/wardrobes/general
	name = "General Wardrobes Supply Crate"
	desc = "This crate contains refills for the CuraDrobe, BarDrobe, ChefDrobe, JaniDrobe, ChapDrobe."
	cost = 3750
	contains = list(/obj/item/vending_refill/wardrobe/curator_wardrobe,
					/obj/item/vending_refill/wardrobe/bar_wardrobe,
					/obj/item/vending_refill/wardrobe/chef_wardrobe,
					/obj/item/vending_refill/wardrobe/jani_wardrobe,
					/obj/item/vending_refill/wardrobe/chap_wardrobe)
	crate_name = "general wardrobes vendor refills"

/datum/supply_pack/costumes_toys/wardrobes/hydroponics
	name = "Hydrobe Supply Crate"
	desc = "This crate contains a refill for the Hydrobe."
	cost = 750
	contains = list(/obj/item/vending_refill/wardrobe/hydro_wardrobe)
	crate_name = "hydrobe supply crate"

/datum/supply_pack/costumes_toys/wardrobes/medical
	name = "Medical Wardrobe Supply Crate"
	desc = "This crate contains refills for the MediDrobe, ChemDrobe, GeneDrobe, and ViroDrobe."
	cost = 3000
	contains = list(/obj/item/vending_refill/wardrobe/medi_wardrobe,
					/obj/item/vending_refill/wardrobe/chem_wardrobe,
					/obj/item/vending_refill/wardrobe/gene_wardrobe,
					/obj/item/vending_refill/wardrobe/viro_wardrobe)
	crate_name = "medical department wardrobe supply crate"

/datum/supply_pack/costumes_toys/wardrobes/science
	name = "Science Wardrobe Supply Crate"
	desc = "This crate contains refills for the SciDrobe and RoboDrobe."
	cost = 1500
	contains = list(/obj/item/vending_refill/wardrobe/robo_wardrobe,
					/obj/item/vending_refill/wardrobe/science_wardrobe)
	crate_name = "science department wardrobe supply crate"

/datum/supply_pack/costumes_toys/wardrobes/security
	name = "Security Wardrobe Supply Crate"
	desc = "This crate contains refills for the SecDrobe and LawDrobe."
	cost = 1500
	contains = list(/obj/item/vending_refill/wardrobe/sec_wardrobe,
					/obj/item/vending_refill/wardrobe/law_wardrobe)
	crate_name = "security department supply crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc
	group = "Miscellaneous Supplies"

/datum/supply_pack/misc/artsupply
	name = "Art Supplies"
	desc = "Make some happy little accidents with six canvasses, two easels, and two rainbow crayons!"
	cost = 400
	contains = list(/obj/structure/easel,
					/obj/structure/easel,
					/obj/item/canvas/nineteenXnineteen,
					/obj/item/canvas/nineteenXnineteen,
					/obj/item/canvas/twentythreeXnineteen,
					/obj/item/canvas/twentythreeXnineteen,
					/obj/item/canvas/twentythreeXtwentythree,
					/obj/item/canvas/twentythreeXtwentythree,
					/obj/item/toy/crayon/rainbow,
					/obj/item/toy/crayon/rainbow)
	crate_name = "art supply crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/bicycle
	name = "Bicycle"
	desc = "Nanotrasen reminds all employees to never toy with powers outside their control."
	cost = 1000000
	contains = list(/obj/vehicle/ridden/bicycle)
	crate_name = "Bicycle Crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/bigband
	name = "Big Band Instrument Collection"
	desc = "Get your sad station movin' and groovin' with this fine collection! Contains ten different instruments!"
	cost = 600
	crate_name = "Big band musical instruments collection"
	contains = list(/obj/item/instrument/violin,
					/obj/item/instrument/guitar,
					/obj/item/instrument/glockenspiel,
					/obj/item/instrument/accordion,
					/obj/item/instrument/saxophone,
					/obj/item/instrument/trombone,
					/obj/item/instrument/recorder,
					/obj/item/instrument/harmonica,
					/obj/item/instrument/banjo,
					/obj/structure/musician/piano/unanchored)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/book_crate
	name = "Book Crate"
	desc = "Surplus from the Nanotrasen Archives, these five books are sure to be good reads."
	cost = 1500
	access_view = ACCESS_LIBRARY
	contains = list(/obj/item/book/codex_gigas,
					/obj/item/book/manual/random/,
					/obj/item/book/manual/random/,
					/obj/item/book/manual/random/,
					/obj/item/book/random/triple)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/paper
	name = "Bureaucracy Crate"
	desc = "High stacks of papers on your desk Are a big problem - make it Pea-sized with these bureaucratic supplies! Contains six pens, some camera film, hand labeler supplies, a paper bin, three folders, a laser pointer, two clipboards and two stamps."//that was too forced
	cost = 1500
	contains = list(/obj/structure/filingcabinet/chestdrawer/wheeled,
					/obj/item/camera_film,
					/obj/item/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/paper_bin,
					/obj/item/storage/pencil_holder,
					/obj/item/pen/fourcolor,
					/obj/item/pen/fourcolor,
					/obj/item/pen,
					/obj/item/pen/fountain,
					/obj/item/pen/blue,
					/obj/item/pen/red,
					/obj/item/pen/green,
					/obj/item/folder/blue,
					/obj/item/folder/red,
					/obj/item/folder/yellow,
					/obj/item/clipboard,
					/obj/item/clipboard,
					/obj/item/stamp,
					/obj/item/stamp/denied,
					/obj/item/laser_pointer/purple)
	crate_name = "bureaucracy crate"

/datum/supply_pack/misc/fountainpens
	name = "Calligraphy Crate"
	desc = "Sign death warrants in style with these seven executive fountain pens."
	cost = 700
	contains = list(/obj/item/storage/box/fountainpens)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "calligraphy crate"

/datum/supply_pack/misc/wrapping_paper
	name = "Festive Wrapping Paper Crate"
	desc = "Want to mail your loved ones gift-wrapped chocolates, stuffed animals, the Clown's severed head? You can do all that, with this crate full of wrapping paper."
	cost = 1000
	contains = list(/obj/item/stack/wrapping_paper)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "festive wrapping paper crate"


/datum/supply_pack/misc/funeral
	name = "Funeral Supply crate"
	desc = "At the end of the day, someone's gonna want someone dead. Give them a proper send-off with these funeral supplies! Contains a coffin with burial garmets and flowers."
	cost = 600 //doesn't sell for 500 credits like a normal crate so its fine
	access_view = ACCESS_CHAPEL_OFFICE
	contains = list(/obj/item/clothing/under/rank/civilian/chaplain/burial,
					/obj/item/reagent_containers/food/snacks/grown/harebell,
					/obj/item/reagent_containers/food/snacks/grown/poppy/geranium)
	crate_name = "coffin"
	crate_type = /obj/structure/closet/crate/coffin

/datum/supply_pack/misc/religious_supplies
	name = "Religious Supplies Crate"
	desc = "Keep your local chaplain happy and well-supplied, lest they call down judgement upon your cargo bay. Contains two bottles of holywater, bibles, chaplain robes, and burial garmets."
	cost = 4000	// it costs so much because the Space Church is ran by Space Jews
	access_view = ACCESS_CHAPEL_OFFICE
	contains = list(/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/storage/book/bible/booze,
					/obj/item/storage/book/bible/booze,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/suit/hooded/chaplain_hoodie)
	crate_name = "religious supplies crate"

/datum/supply_pack/misc/toner
	name = "Toner Crate"
	desc = "Spent too much ink printing butt pictures? Fret not, with these six toner refills, you'll be printing butts 'till the cows come home!'"
	cost = 1000
	contains = list(/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner)
	crate_name = "toner crate"

/datum/supply_pack/misc/jukebox
	name = "Jukebox Crate"
	desc = "Did the bartender not bring his jukebox? Your problem is solved with this ancient jukebox found in a junk pile."
	cost = 5000
	contains = list(/obj/machinery/jukebox)
	crate_name = "jukebox crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/jukebox/disco
	name = "Radiant Dance Machine Mark IV Crate"
	desc = "It's a jukebox with more lights."
	cost = 6000
	contains = list(/obj/machinery/jukebox/disco)
	crate_name = "radiant dance machine mark IV crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/jukebox/disco/portable
	name = "Portable Radiant Dance Machine Crate"
	desc = "It's a jukebox with more lights. Tiny, even..and with no sound. Three of them."
	cost = 4500
	contains = list(/obj/item/discoballdeployer,
					/obj/item/discoballdeployer,
					/obj/item/discoballdeployer)
	crate_name = "portable radiant dance machine crate"

/datum/supply_pack/misc/pda
	name = "Modular Personal Digital Assistant Crate"
	desc = "A create containing a modular PDA."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/modular_computer/tablet/pda/preset/basic)
	crate_name = "pda crate"

/datum/supply_pack/misc/laptop
	name = "Modular Laptop Crate"
	desc = "A create a modular laptop computer."
	cost = 200
	small_item = TRUE
	contains = list(/obj/item/modular_computer/laptop/preset)
	crate_name = "laptop crate"

/datum/supply_pack/misc/tablet
	name = "Modular Tablet Crate"
	desc = "A create a modular tablet computer."
	cost = 600
	small_item = TRUE
	contains = list(/obj/item/modular_computer/tablet/preset/cheap)
	crate_name = "tablet crate"

/datum/supply_pack/misc/phone
	name = "Modular Phone Crate"
	desc = "A create containing a modular phone computer. Does not include games."
	cost = 800
	small_item = TRUE
	contains = list(/obj/item/modular_computer/tablet/phone/preset/cheap)
	crate_name = "phone crate"

/datum/supply_pack/misc/telescreen
	name = "Modular Telescreen Crate"
	desc = "A create containing four modular telescreens, featuring the latest in Nanotrasen digital displaying technology."
	cost = 250
	small_item = TRUE
	contains = list(/obj/item/wallframe/telescreen/preset)
	crate_name = "telescreen crate"

// LIQUIDS TM REMOVE THIS
/datum/supply_pack/service/janitor/pump
	name = "Liquids Pump Crate"
	desc = "A crate containing a portable liquid pump, for stations that lack proper liquid infrastructure."
	cost = 2000
	crate_name = "liquid pump crate"
	contains = list(/obj/structure/liquid_pump)

/datum/supply_pack/misc/blackmarket_telepad
	name = "Black Market LTSRBT"
	desc = "Need a faster and better way of transporting your illegal goods from and to the station? Fear not, the Long-To-Short-Range-Bluespace-Transceiver (LTSRBT for short) is here to help. Contains a LTSRBT circuit, two bluespace crystals, and one ansible."
	cost = 10000
	contraband = TRUE
	contains = list(
		/obj/item/circuitboard/machine/ltsrbt,
		/obj/item/stack/ore/bluespace_crystal/artificial,
		/obj/item/stack/ore/bluespace_crystal/artificial,
		/obj/item/stock_parts/subspace/ansible
	)
	crate_name = "crate"
