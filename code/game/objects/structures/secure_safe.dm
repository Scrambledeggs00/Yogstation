/obj/structure/secure_safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	desc = "Excellent for securing things away from grubby hands."
	w_class = WEIGHT_CLASS_GIGANTIC
	anchored = TRUE
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/secure_safe, 32)

/obj/structure/secure_safe/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(null, list(/obj/item/storage/briefcase/secure))
	STR.max_w_class = 8 //??
	AddComponent(/datum/component/keypad_lock)

/obj/structure/secure_safe/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/structure/secure_safe/HoS
	name = "head of security's safe"
