/obj/structure/secure_safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	base_icon_state = "safe"
	desc = "Excellent for securing things away from grubby hands."
	anchored = TRUE
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/secure_safe, 32)

/obj/structure/secure_safe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/keypad_lock)
	PopulateContents()

/obj/structure/secure_safe/proc/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/structure/secure_safe/HoS
	name = "head of security's safe"
