/mob
	density = 1
	layer = 4.0
	animate_movement = 2
//	flags = NOREACT
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	//Not in use yet
	var/obj/effect/organstructure/organStructure = null

	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/pullin = null
	var/obj/screen/purged = null
	var/obj/screen/internals = null
	var/obj/screen/oxygen = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/toxin = null
	var/obj/screen/fire = null
	var/obj/screen/bodytemp = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null
	var/obj/screen/nutrition_icon = null
	var/obj/screen/pressure = null
	var/obj/screen/damageoverlay = null
	var/obj/screen/pain = null
	var/obj/screen/gun/item/item_use_icon = null
	var/obj/screen/gun/radio/radio_use_icon = null
	var/obj/screen/gun/move/gun_move_icon = null
	var/obj/screen/gun/run/gun_run_icon = null
	var/obj/screen/gun/mode/gun_setting_icon = null

	//spells hud icons - this interacts with add_spell and remove_spell
	var/list/obj/screen/movable/spell_master/spell_masters = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/zone_sel/zone_sel = null

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/birth = 0
	var/obj/machinery/machine = null
	var/other_mobs = null
//	var/memory = ""
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/transforming = null	//Carbon
	var/other = 0.0
	var/hand = null
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = null	//Carbon
	var/slurring = null		//Carbon
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/blinded = null
	var/bhunger = 0			//Carbon
	var/ajourn = 0
	var/druggy = 0			//Carbon
	var/horny = 0			//Carbon //for aphrodisiac
	var/confused = 0		//Carbon
	var/antitoxs = null
	var/phoron = null
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/canmove = 1
	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.
	var/unacidable = 0
	var/small = 0
	var/list/pinned = list()            // List of things pinning this creature to walls (see living_defense.dm)
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/list/language_keys = list()     // For access to languages.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/facing_dir = null   // Used for the ancient art of moonwalking.

	var/name_archive //For admin things like possession

	var/timeofdeath = 0.0//Living
	var/cpr_time = 1.0//Carbon

	var/bodytemperature = 310.055	//98.7 F
	var/old_x = 0
	var/old_y = 0
	var/drowsyness = 0.0//Carbon
	var/charges = 0.0
	var/nutrition = 400.0//Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0//Carbon
	var/intent = null//Living
	var/shakecamera = 0
	var/a_intent = I_HELP//Living
	var/m_int = null//Living
	var/m_intent = "run"//Living
	var/lastKnownIP = null
	var/obj/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/obj/item/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	var/seer = 0 //for cult//Carbon, probably Human

	var/datum/hud/hud_used = null

	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/inertia_dir = 0

	var/music_lastplayed = "null"

	var/job = null//Living

	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/list/augmentations = list() //Carbon -- Doohl
	//see: setup.dm for list of augmentations

	var/voice_name = "unidentifiable voice"

	var/faction = "neutral" //Used for checking whether hostile simple animals will attack you, possibly more stuff later
	var/captured = 0 //Functionally, should give the same effect as being buckled into a chair when true.

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

	var/tmp/list/radar_blips = list() // list of screen objects, radar blips
	var/radar_open = 0 	// nonzero is radar is open

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/spell/list/spell_list = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak

	var/stance_damage = 0 //Whether this mob's ability to stand has been affected

	//If set, indicates that the client "belonging" to this (clientless) mob is currently controlling some other mob
	//so don't treat them as being SSD even though their client var is null.
	var/mob/teleop = null

	var/turf/listed_turf = null  	//the current turf being examined in the stat panel
	var/list/shouldnt_see = list()	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes


