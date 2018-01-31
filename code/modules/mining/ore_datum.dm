var/global/list/ore_data = list()

/ore
	var/name
	var/display_name
	var/alloy
	var/smelts_to
	var/compresses_to
	var/result_amount     // How much ore?
	var/spread = 1	      // Does this type of deposit spread?
	var/spread_chance     // Chance of spreading in any direction
	var/ore	              // Path to the ore produced when tile is mined.
	var/scan_icon         // Overlay for ore scanners.
	// Xenoarch stuff. No idea what it's for, just refactored it to be less awful.
	var/list/xarch_ages = list(
		"thousand" = 999,
		"million" = 999
		)
	var/xarch_source_mineral = MATERIAL_IRON
	var/worth = 0			  // Arbitrary point value for the ore redemption console

/ore/New()
	. = ..()
	if(!display_name)
		display_name = name

/ore/uranium
	name = MATERIAL_URANIUM
	display_name = "pitchblende"
	smelts_to = MATERIAL_URANIUM
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/uranium
	scan_icon = "mineral_uncommon"
	xarch_ages = list(
		"thousand" = 999,
		"million" = 704
		)
	xarch_source_mineral = "potassium"
	worth = 25

/ore/hematite
	name = "hematite"
	display_name = "hematite"
	smelts_to = MATERIAL_IRON
	alloy = 1
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/iron
	scan_icon = "mineral_common"
	worth = 4

/ore/coal
	name = "carbon"
	display_name = "raw carbon"
	smelts_to = MATERIAL_PLASTIC
	alloy = 1
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/coal
	scan_icon = "mineral_common"
	worth = 2

/ore/glass
	name = "sand"
	display_name = "impure silicates"
	smelts_to = MATERIAL_GLASS
	compresses_to = MATERIAL_SANDSTONE
	worth = 1

/ore/phoron
	name = MATERIAL_PHORON
	display_name = "phoron crystals"
	compresses_to = MATERIAL_PHORON
	//smelts_to = something that explodes violently on the conveyor, huhuhuhu
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/phoron
	scan_icon = "mineral_uncommon"
	xarch_ages = list(
		"thousand" = 999,
		"million" = 999,
		"billion" = 13,
		"billion_lower" = 10
		)
	xarch_source_mineral = "phoron"
	worth = 8

/ore/silver
	name = MATERIAL_SILVER
	display_name = "native silver"
	smelts_to = MATERIAL_SILVER
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/silver
	scan_icon = "mineral_uncommon"
	worth = 20

/ore/gold
	smelts_to = MATERIAL_GOLD
	name = MATERIAL_GOLD
	display_name = "native gold"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/gold
	scan_icon = "mineral_uncommon"
	xarch_ages = list(
		"thousand" = 999,
		"million" = 999,
		"billion" = 4,
		"billion_lower" = 3
		)
	worth = 30

/ore/diamond
	name = MATERIAL_DIAMOND
	display_name = MATERIAL_DIAMOND
	compresses_to = MATERIAL_DIAMOND
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/diamond
	scan_icon = "mineral_rare"
	xarch_source_mineral = "nitrogen"
	worth = 50

/ore/platinum
	name = MATERIAL_PLATINUM
	display_name = "raw platinum"
	smelts_to = MATERIAL_PLATINUM
	compresses_to = MATERIAL_OSMIUM
	alloy = 1
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/osmium
	scan_icon = "mineral_rare"
	worth = 15

/ore/hydrogen
	name = MATERIAL_MYTHRIL
	display_name = "metallic hydrogen"
	smelts_to = MATERIAL_TRITIUM
	compresses_to = MATERIAL_MYTHRIL
	scan_icon = "mineral_rare"
	worth = 30