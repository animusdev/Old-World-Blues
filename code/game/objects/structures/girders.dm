/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = 2
	w_class = ITEM_SIZE_NO_CONTAINER
	var/state = 0
	var/health = 200
	var/cover = 50 //how much cover the girder provides against projectiles.
	var/material/reinf_material
	var/reinforcing = 0

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0
	health = 50
	cover = 25

/obj/structure/girder/attack_generic(var/mob/user, var/damage, var/attack_message = "smashes apart", var/wallbreaker)
	if(!damage || !wallbreaker)
		return 0
	user.do_attack_animation(src)
	visible_message("<span class='danger'>[user] [attack_message] the [src]!</span>")
	spawn(1) dismantle()
	return 1

/obj/structure/girder/bullet_act(var/obj/item/projectile/Proj)
	//Girders only provide partial cover. There's a chance that the projectiles will just pass through. (unless you are trying to shoot the girder)
	if(Proj.original != src && !prob(cover))
		return PROJECTILE_CONTINUE //pass through

	//Tasers and the like should not damage girders.
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return

	var/damage = Proj.damage
	if(!istype(Proj, /obj/item/projectile/beam))
		damage *= 0.4 //non beams do reduced damage

	health -= damage
	..()
	if(health <= 0)
		dismantle()

	return

/obj/structure/girder/proc/reset_girder()
	anchored = 1
	cover = initial(cover)
	health = min(health,initial(health))
	state = 0
	icon_state = initial(icon_state)
	reinforcing = 0
	if(reinf_material)
		reinforce_girder()

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && state == 0)
		if(anchored && !reinf_material)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user << SPAN_NOTE("Now disassembling the girder...")
			if(do_after(user,40))
				if(!src) return
				user << SPAN_NOTE("You dissasembled the girder!")
				dismantle()
		else if(!anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user << SPAN_NOTE("Now securing the girder...")
			if(do_after(user, 40))
				user << SPAN_NOTE("You secured the girder!")
				reset_girder()

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		user << SPAN_NOTE("Now slicing apart the girder...")
		if(do_after(user,30))
			if(!src) return
			user << SPAN_NOTE("You slice apart the girder!")
			dismantle()

	else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		user << SPAN_NOTE("You drill through the girder!")
		dismantle()

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(state == 2)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			user << SPAN_NOTE("Now unsecuring support struts...")
			if(do_after(user,40))
				if(!src) return
				user << SPAN_NOTE("You unsecured the support struts!")
				state = 1
		else if(anchored && !reinf_material)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			reinforcing = !reinforcing
			user << SPAN_NOTE("\The [src] can now be [reinforcing? "reinforced" : "constructed"]!")

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1)
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user << SPAN_NOTE("Now removing support struts...")
		if(do_after(user,40))
			if(!src) return
			user << SPAN_NOTE("You removed the support struts!")
			reinf_material.place_dismantled_product(get_turf(src))
			reinf_material = null
			reset_girder()

	else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored)
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		user << SPAN_NOTE("Now dislodging the girder...")
		if(do_after(user, 40))
			if(!src) return
			user << SPAN_NOTE("You dislodged the girder!")
			icon_state = "displaced"
			anchored = 0
			health = 50
			cover = 25

	else if(ismaterial(W))
		if(reinforcing && !reinf_material)
			if(!reinforce_with_material(W, user))
				return ..()
		else
			if(!construct_wall(W, user))
				return ..()

	else
		return ..()

/obj/structure/girder/proc/construct_wall(obj/item/stack/material/S, mob/user)
	if(S.get_amount() < 2)
		user << SPAN_NOTE("There isn't enough material here to construct a wall.")
		return 0

	var/material/M = S.material
	if(!istype(M))
		return 0

	var/wall_fake
	add_hiddenprint(usr)

	if(M.integrity < 50)
		user << SPAN_NOTE("This material is too soft for use in wall construction.")
		return 0

	user << SPAN_NOTE("You begin adding the plating...")

	if(!do_after(user,40) || !S.use(2))
		return 1 //once we've gotten this far don't call parent attackby()

	if(anchored)
		user << SPAN_NOTE("You added the plating!")
	else
		user << SPAN_NOTE("You create a false wall! Push on it to open or close the passage.")
		wall_fake = 1

	var/turf/Tsrc = get_turf(src)
	Tsrc.ChangeTurf(/turf/simulated/wall)
	var/turf/simulated/wall/T = get_turf(src)
	T.set_material(M, reinf_material)
	if(wall_fake)
		T.can_open = 1
	T.add_hiddenprint(usr)
	qdel(src)
	return 1

/obj/structure/girder/proc/reinforce_with_material(obj/item/stack/material/S, mob/user) //if the verb is removed this can be renamed.
	if(reinf_material)
		user << SPAN_NOTE("\The [src] is already reinforced.")
		return 0

	if(S.get_amount() < 2)
		user << SPAN_NOTE("There isn't enough material here to reinforce the girder.")
		return 0

	var/material/M = S.material
	if(!istype(M) || M.integrity < 50)
		user << "You cannot reinforce \the [src] with that; it is too soft."
		return 0

	user << SPAN_NOTE("Now reinforcing...")
	if (!do_after(user,40) || !S.use(2))
		return 1 //don't call parent attackby() past this point
	user << SPAN_NOTE("You added reinforcement!")

	reinf_material = M
	reinforce_girder()
	return 1

/obj/structure/girder/proc/reinforce_girder()
	cover = reinf_material.hardness
	health = 500
	state = 2
	icon_state = "reinforced"
	reinforcing = 0

/obj/structure/girder/proc/dismantle()
	new /obj/item/stack/material/steel(get_turf(src))
	qdel(src)

//TODO: DNA3 hulk
/*
/obj/structure/girder/attack_hand(mob/user as mob)
	if (HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		dismantle()
		return
	return ..()
*/

/obj/structure/girder/blob_act()
	if(prob(40))
		qdel(src)


/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				dismantle()
			return
		if(3.0)
			if (prob(5))
				dismantle()
			return
		else
	return

/obj/structure/girder/cult
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	health = 250
	cover = 70

/obj/structure/girder/cult/dismantle()
	new /obj/effect/decal/remains/human(get_turf(src))
	qdel(src)

/obj/structure/girder/cult/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		user << SPAN_NOTE("Now disassembling the girder...")
		if(do_after(user,40))
			user << SPAN_NOTE("You dissasembled the girder!")
			dismantle()

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		user << SPAN_NOTE("Now slicing apart the girder...")
		if(do_after(user,30))
			user << SPAN_NOTE("You slice apart the girder!")
		dismantle()

	else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		user << SPAN_NOTE("You drill through the girder!")
		new /obj/effect/decal/remains/human(get_turf(src))
		dismantle()
