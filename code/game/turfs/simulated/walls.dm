var/list/global/wall_cache = list()

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "generic"
	opacity = 1
	density = 1
	blocks_air = 1
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/damage = 0
	var/damage_overlay = 0
	var/global/damage_overlays[16]
	var/active
	var/can_open = 0
	var/material/material
	var/material/reinf_material
	var/last_state
	var/construction_stage

/turf/simulated/wall/New(var/newloc, var/materialtype, var/rmaterialtype)
	..(newloc)
	icon_state = "blank"
	if(!materialtype)
		materialtype = DEFAULT_WALL_MATERIAL
	material = get_material_by_name(materialtype)
	if(!isnull(rmaterialtype))
		reinf_material = get_material_by_name(rmaterialtype)
	update_material()

	processing_turfs |= src

/turf/simulated/wall/Destroy()
	processing_turfs -= src
	dismantle_wall(null,null,1)
	..()

/turf/simulated/wall/process()
	// Calling parent will kill processing
	if(!radiate())
		return PROCESS_KILL

// Extracts ricochet angle's tan from ricochet position. Mostly copies ricochet code below, so there will be no comments.
/turf/simulated/wall/proc/bullet_ricochetchance_mod(var/obj/item/projectile/Proj)
	if(Proj.starting)
		var/turf/curloc = get_turf(src)
		var/check_x0 = 32 * curloc.x
		var/check_y0 = 32 * curloc.y
		var/check_x1 = 32 * Proj.starting.x
		var/check_y1 = 32 * Proj.starting.y
		var/check_x2 = 32 * Proj.original.x
		var/check_y2 = 32 * Proj.original.y
		var/corner_x0 = check_x0
		var/corner_y0 = check_y0
		if(check_y0 - check_y1 > 0)
			corner_y0 = corner_y0 - 16
		else
			corner_y0 = corner_y0 + 16
		if(check_x0 - check_x1 > 0)
			corner_x0 = corner_x0 - 16
		else
			corner_x0 = corner_x0 + 16
		var/new_y = (check_y2 - corner_y0) * (check_x1 - corner_x0) - (check_x2 - corner_x0) * (check_y1 - corner_y0)
		var/new_func = (corner_x0 - check_x1) * (corner_y0 - check_y1)
		if((new_y * new_func) > 0)
			// Proj.redirect(round((2 * check_x0 - check_x1) / 32), round(check_y1 / 32), curloc, src)
			return abs((check_x0 - check_x1) / (check_y0 - check_y1))
		else
			// Proj.redirect(round(check_x1 / 32), round((2 * check_y0 - check_y1)/32), curloc, src)
			return abs((check_y0 - check_y1) / (check_x0 - check_x1))

/turf/simulated/wall/proc/bullet_ricochet(var/obj/item/projectile/Proj)
	if(Proj.starting)
		var/turf/curloc = get_turf(src)
		if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
			visible_message("\red <B>\The [Proj] critically misses!</B>")
			var/random_value = pick(-1, 0, 1)
			var/critical_x = Proj.starting.x + random_value
			var/critical_y = Proj.starting.y + random_value
			Proj.redirect(critical_x, critical_y, curloc, src)
			return
		var/check_x0 = 32 * curloc.x
		var/check_y0 = 32 * curloc.y
		var/check_x1 = 32 * Proj.starting.x
		var/check_y1 = 32 * Proj.starting.y
		var/check_x2 = 32 * Proj.original.x
		var/check_y2 = 32 * Proj.original.y
		var/corner_x0 = check_x0
		var/corner_y0 = check_y0
		if(check_y0 - check_y1 > 0)
			corner_y0 = corner_y0 - 16
		else
			corner_y0 = corner_y0 + 16
		if(check_x0 - check_x1 > 0)
			corner_x0 = corner_x0 - 16
		else
			corner_x0 = corner_x0 + 16

		// Checks if original is lower or upper than line connecting proj's starting and wall
		// In specific coordinate system that has wall as (0,0) and 'starting' as (r, 0), where r > 0.
		// So, this checks whether 'original's' y-coordinate is positive or negative in new c.s.
		// In order to understand, in which direction bullet will ricochet.
		// Actually new_y isn't y-coordinate, but it has the same sign.
		var/new_y = (check_y2 - corner_y0) * (check_x1 - corner_x0) - (check_x2 - corner_x0) * (check_y1 - corner_y0)
		// Here comes the thing which differs two situations:
		// First - bullet comes from north-west or south-east, with negative func value. Second - NE or SW.
		var/new_func = (corner_x0 - check_x1) * (corner_y0 - check_y1)
		if((new_y * new_func) > 0)
			Proj.redirect(round((2 * check_x0 - check_x1) / 32), round(check_y1 / 32), curloc, src)
		else
			Proj.redirect(round(check_x1 / 32), round((2 * check_y0 - check_y1)/32), curloc, src)
/*
// Commented for further possible use of this reflection code
/turf/simulated/wall/proc/laser_reflect(var/obj/item/projectile/Proj)
	// Sends a beam somewhere on diagonal line in square made from Proj's starting and wall, perpendicular to line connecting them.
	if(Proj.starting)
		var/turf/curloc = get_turf(src)
		var/check_x0 = curloc.x
		var/check_y0 = curloc.y
		var/check_x1 = Proj.starting.x
		var/check_y1 = Proj.starting.y
		var/random_value = pick(0, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 8, 8, 9, 10)
		var/resulting_x = (check_x1 - (check_y0 - check_y1)) + round(((check_y0 - check_y1) / 5) * random_value)
		var/resulting_y = (check_y1 - (check_x0 - check_x1)) + round(((check_x0 - check_x1) / 5) * random_value)
		resulting_x = resulting_x + pick(-1, 0, 0, 0, 0, 1)
		resulting_y = resulting_y + pick(-1, 0, 0, 0, 0, 1)
		// redirect the projectile
		Proj.redirect(resulting_x, resulting_y, curloc, src)
*/
// Makes walls made from reflective-able materials reflect beam-type projectiles depending on their reflectance value.
/turf/simulated/wall/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj,/obj/item/projectile/beam))
		if(reinf_material)
			if(material.reflectance + reinf_material.reflectance > 0)
				// Reflection chance depends on materials' var 'reflectance'.
				var/reflectchance = material.reflectance + reinf_material.reflectance - min(round(Proj.damage/3), 50)
				if(prob(reflectchance))
					visible_message("\red <B>\The [Proj] gets reflected by shiny surface of reinforced wall!</B>")
					bullet_ricochet(Proj)
					return PROJECTILE_CONTINUE // complete projectile permutation
				else
					if(material.name == MATERIAL_DIAMOND && reinf_material.name == MATERIAL_DIAMOND)
						// Diamond-walls can deal with laser beams.
						burn(500)
					else
						// Non-diamond walls with positive reflection values deal with laser better than walls with negative.
						burn(1500)
			else
				burn(2000)
		else
			if(material.reflectance > 0)
				// Reflection chance depends on materials' var 'reflectance'.
				var/reflectchance = material.reflectance - min(round(Proj.damage/3), 50)
				if(prob(reflectchance))
					visible_message("\red <B>\The [Proj] gets reflected by shiny surface of wall!</B>")
					bullet_ricochet(Proj)
					return PROJECTILE_CONTINUE // complete projectile permutation
				else
					if(material.name == MATERIAL_DIAMOND)
						// Diamond-walls can deal with laser beams.
						burn(1000)
					else
						// Non-diamond walls with positive reflection values deal with laser better than walls with negative.
						burn(2000)
			else
				burn(2500)

	//else if(istype(Proj,/obj/item/projectile/ion))
	//	burn(500)

	// Makes bullets ricochet from walls made of specific materials with some little chance.
	if(istype(Proj,/obj/item/projectile/bullet))
		if(reinf_material)
			if(material.resilience * reinf_material.resilience > 0)
				var/ricochetchance = round(sqrt(material.resilience * reinf_material.resilience))
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					ricochetchance = round(ricochetchance / 5)
				else
					ricochetchance = min(100, round(bullet_ricochetchance_mod(Proj) * ricochetchance))
				if(prob(ricochetchance))
					visible_message("\red <B>\The [Proj] ricochets from the surface of reinforced wall!</B>")
					bullet_ricochet(Proj)
					return PROJECTILE_CONTINUE // complete projectile permutation
		else
			if(material.resilience > 0)
				var/ricochetchance = round(material.resilience)
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					ricochetchance = round(ricochetchance / 5)
				else
					ricochetchance = min(100, round(bullet_ricochetchance_mod(Proj) * ricochetchance))
				if(prob(ricochetchance))
					visible_message("\red <B>\The [Proj] ricochets from the surface of wall!</B>")
					bullet_ricochet(Proj)
					return PROJECTILE_CONTINUE // complete projectile permutation

	// Tasers and stuff? No thanks. Also no clone or tox damage crap.
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return

	//cap the amount of damage, so that things like emitters can't destroy walls in one hit.
	var/damage = min(Proj.damage, 100)

	take_damage(damage)
	return

/turf/simulated/wall/hitby(AM as mob|obj, var/speed=THROWFORCE_SPEED_DIVISOR)
	..()
	if(ismob(AM))
		return

	var/tforce = AM:throwforce * (speed/THROWFORCE_SPEED_DIVISOR)
	if (tforce < 15)
		return

	take_damage(tforce)

/turf/simulated/wall/proc/clear_plants()
	for(var/obj/effect/overlay/wallrot/WR in src)
		qdel(WR)
	for(var/obj/effect/plant/plant in range(1,src))
		if(!plant.floor) //shrooms drop to the floor
			plant.floor = 1
			plant.update_icon()
			plant.pixel_x = 0
			plant.pixel_y = 0
		plant.update_neighbors()

/turf/simulated/wall/ChangeTurf(var/newtype)
	clear_plants()
	..(newtype)

//Appearance
/turf/simulated/wall/examine(mob/user)
	. = ..()

	if(!damage)
		user << SPAN_NOTE("It looks fully intact.")
	else
		var/dam = damage / material.integrity
		if(dam <= 0.3)
			user << "<span class='warning'>It looks slightly damaged.</span>"
		else if(dam <= 0.6)
			user << "<span class='warning'>It looks moderately damaged.</span>"
		else
			user << "<span class='danger'>It looks heavily damaged.</span>"

	if(locate(/obj/effect/overlay/wallrot) in src)
		user << "<span class='warning'>There is fungus growing on [src].</span>"

//Damage

/turf/simulated/wall/melt()

	if(!can_melt())
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message("<span class='danger'>\The [src] spontaneously combusts!.</span>") //!!OH SHIT!!
	return

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = material.integrity
	if(reinf_material)
		cap += reinf_material.integrity

	if(locate(/obj/effect/overlay/wallrot) in src)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall(no_product = 1)
	else
		update_icon()

	return

/turf/simulated/wall/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	burn(exposed_temperature)

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	burn(adj_temp)
	if(adj_temp > material.melting_point)
		take_damage(log(RAND_F(0.9, 1.1) * (adj_temp - material.melting_point)))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(var/devastated, var/explode, var/no_product)

	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	if(!no_product)
		if(reinf_material)
			reinf_material.place_dismantled_girder(src, reinf_material)
		else
			material.place_dismantled_girder(src)
		material.place_dismantled_product(src,devastated)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/item/weapon/contraband/poster))
			var/obj/item/weapon/contraband/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src

	clear_plants()
	material = get_material_by_name("placeholder")
	reinf_material = null
	check_relatives()

	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
			return
		if(2.0)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
		else
	return

/turf/simulated/wall/blob_act()
	take_damage(rand(75, 125))
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(locate(/obj/effect/overlay/wallrot) in src)
		return
	var/number_rots = rand(2,3)
	for(var/i=0, i<number_rots, i++)
		new/obj/effect/overlay/wallrot(src)

/turf/simulated/wall/proc/can_melt()
	if(material.flags & MATERIAL_UNMELTABLE)
		return 0
	return 1

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(!can_melt())
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	user << "<span class='warning'>The thermite starts melting through the wall.</span>"

	spawn(100)
		if(O)
			qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if (prob(15) && !rotting)
		dismantle_wall()
	else if(prob(70) && !rotting)
		ChangeTurf(/turf/simulated/floor/plating)
	else
		ReplaceWithLattice()
	return 0

/turf/simulated/wall/proc/radiate()
	var/total_radiation = material.radioactivity + (reinf_material ? reinf_material.radioactivity / 2 : 0)
	if(!total_radiation)
		return

	for(var/mob/living/L in range(3,src))
		L.apply_effect(total_radiation, IRRADIATE,0)
	return total_radiation

/turf/simulated/wall/proc/burn(temperature)
	if(material.combustion_effect(src, temperature, 0.7))
		spawn(2)
			new /obj/structure/girder(src)
			src.ChangeTurf(/turf/simulated/floor)
			for(var/turf/simulated/wall/W in RANGE_TURFS(3,src))
				W.burn((temperature/4))
				var/obj/machinery/door/airlock/phoron/D = locate() in W
				if(D)
					D.ignite(temperature/4)
