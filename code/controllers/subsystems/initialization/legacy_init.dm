// Everything in here should eventually be refactored into actual subsystem inits instead of all just crammed in here.

/var/datum/controller/subsystem/legacy_init/SSl_init

/datum/controller/subsystem/legacy_init
	name = "Legacy Setup"
	init_order = SS_INIT_MISC_FIRST
	flags = SS_NO_FIRE

/datum/controller/subsystem/legacy_init/New()
	NEW_SS_GLOBAL(SSl_init)

/datum/controller/subsystem/legacy_init/Initialize()
	if (!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		admin_notice("<span class='danger'>Job setup complete</span>", R_DEBUG)

	if(!syndicate_code_phrase)
		syndicate_code_phrase = generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()

	spawn(20)
		createRandomZlevel()

	setup_objects()
	SetupXenoarch()
//	setupgenetics()

	transfer_controller = new

/datum/controller/subsystem/legacy_init/proc/setup_objects()
	var/count = 0
	// Do these first since character setup will rely on them
	// Set up antagonists.
	populate_antag_type_list()

	//Set up spawn points.
	populate_spawn_points()
/*
	admin_notice("<span class='danger'>Initializing [init_atoms.len] movable atom\s.</span>", R_DEBUG)
	while(init_atoms.len) // Use a while loop so that in the event of new atoms being spawned, we will keep initializing them.
		var/atom/movable/object = init_atoms[1]
		if(!QDELETED(object))
			object.initialize()
		init_atoms -= object
		CHECK_TICK
	init_atoms.Cut()*/

	//Fuck this shit above, it doesn't initialize even a half, idk why

	admin_notice("<span class='danger'>Initializing movable atom\s.</span>", R_DEBUG)
	for(var/atom/movable/object in world)
		object.initialize()
		count++
	admin_notice("<span class='danger'>Initialized [count] movable atom\s.</span>", R_DEBUG)

	admin_notice("<span class='danger'>Building pipe networks</span>", R_DEBUG)
	count = 0
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
		CHECK_TICK
	admin_notice("<span class='danger'>Built [count] pipe network\s</span>", R_DEBUG)

	admin_notice("<span class='danger'>Initializing [all_areas.len] area\s.</span>", R_DEBUG)
	for(var/thing in all_areas)
		thing:initialize()
		CHECK_TICK

	count = 0
	admin_notice("<span class='danger'>Updating atmospherics machinery broadcasting.</span>", R_DEBUG)
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
		CHECK_TICK
	admin_notice("<span class='danger'>Updated [count] atmos broadcast\s</span>", R_DEBUG)

	// Create the mining ore distribution map.
	if(config.generate_asteroid)
		for(var/level in maps_data.asteroid_leves)
			new /datum/random_map(null,13,32,level,217,223)
			new /datum/random_map/ore(null,13,32,level,217,223)
			CHECK_TICK

	count = 0
	admin_notice("<span class='danger'>Casting lights.</span>", R_DEBUG)
	for(var/thing in init_lights)
		var/datum/D = thing
		if(!QDELETED(D))
			D:cast_light(1)
			count++
		CHECK_TICK
	init_lights.Cut()
	lights_initialized = 1

	admin_notice("<span class='danger'>Cast [count] light\s</span>", R_DEBUG)
