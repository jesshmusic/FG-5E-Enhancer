--[[
	Script for adding the extensions menu items.
]]--

function onInit()		
	registerflankingItems();		
end

-- Add menu items to the Settings menu, pertaining to the 5e Combat Enhancer extension.
function registerflankingItems()			
	OptionsManager.registerOption2("CE_ARM", false, "option_header_5eenhancer", "option_automatic_ranged_modifiers", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })		
	OptionsManager.registerOption2("CE_FR", false, "option_header_5eenhancer", "option_flanking_rules", "option_entry_cycler",
		{ labels = "Advantage|+1|+2|+5", values = "option_val_on|option_val_1|option_val_2|option_val_on_5", baselabel = "option_val_off", baseval = "option_val_off", default = "option_val_off" })								
	OptionsManager.registerOption2("CE_RMM", false, "option_header_5eenhancer", "option_ranged_melee_modifier", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })	
	OptionsManager.registerOption2("CE_RRU", false, "option_header_5eenhancer", "option_range_rules_used", "option_entry_cycler",
		{ labels = "Standard|RAW", values = "option_standard|option_raw", default = "option_standard" })	
end