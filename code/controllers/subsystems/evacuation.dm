/datum/controller/subsystem/evacuation
	name = "Evacuation"
	wait = 2 SECONDS
	flags = SS_NO_TICK_CHECK

/datum/controller/subsystem/evacuation/Initialize()
	if(!emergency_shuttle)
		emergency_shuttle = new
	..()

/datum/controller/subsystem/evacuation/fire()
	emergency_shuttle.process()
