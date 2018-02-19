//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done
var/list/controllers_by_name = list()
var/list/controller_feedback_by_name = list()

/client/proc/print_random_map()
	set category = "Debug"
	set name = "Display Random Map"
	set desc = "Show the contents of a random map."

	if(!holder)	return

	var/datum/random_map/choice = input("Choose a map to debug.") as null|anything in random_maps
	if(!choice)
		return
	choice.display_map(usr)


/client/proc/create_random_map()
	set category = "Debug"
	set name = "Create Random Map"
	set desc = "Create a random map."

	if(!holder)	return

	var/map_datum = input("Choose a map to create.") as null|anything in typesof(/datum/random_map)-/datum/random_map
	if(!map_datum)
		return
	var/seed = input("Seed? (default null)")  as text|null
	var/tx =    input("X? (default 1)")       as text|null
	var/ty =    input("Y? (default 1)")       as text|null
	var/tz =    input("Z? (default 1)")       as text|null
	new map_datum(seed,tx,ty,tz)

/client/proc/debug_antagonist_template(antag_type in all_antag_types)
	set category = "Debug"
	set name = "Debug Antagonist"
	set desc = "Debug an antagonist template."

	var/datum/antagonist/antag = all_antag_types[antag_type]
	if(antag)
		usr.client.debug_variables(antag)
		message_admins("Admin [key_name_admin(usr)] is debugging the [antag.role_text] template.")

/client/proc/debug_controller(controller in controllers_by_name)
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return

	if(controllers_by_name[controller] && controller_feedback_by_name[controller])
		debug_variables(controllers_by_name[controller])
	else
		to_chat(usr, "Untracked controller, please report this to the bug tracker.")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
