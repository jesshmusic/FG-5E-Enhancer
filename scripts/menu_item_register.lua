--[[
	Script for adding the extensions menu items.
]]--

function onInit()
	registerMenuItems();
end

-- Add menu items to the Settings menu, pertaining to the 5e Combat Enhancer extension.
function registerMenuItems()
	OptionsManager.registerOption2("CE_HCW", false, "option_header_5eenhancer", "option_actor_health_widget_conditions", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_BOT", false, "option_header_5eenhancer", "option_blood_on_tokens", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_HHB", false, "option_header_5eenhancer", "option_horizontal_health_bars", "option_entry_cycler",
		{ labels = "Off|Left, Default|Left, Taller|Centered, Default|Centered, Taller", values = "option_off|option_v1|option_v2|option_v3|option_v4", default = "option_off" })
	OptionsManager.registerOption2("CE_LHD", false, "option_header_5eenhancer", "option_larger_health_dots", "option_entry_cycler",
		{ labels = "Off|Larger|Largest", values = "option_off|option_larger|option_largest", default = "option_larger" })
	OptionsManager.registerOption2("CE_SC", false, "option_header_5eenhancer", "option_skull_or_cross", "option_entry_cycler",
		{ labels = "Off|Skull|Cross", values = "option_off|option_skull|option_cross", default = "option_skull" })
	OptionsManager.registerOption2("CE_TRA", false, "option_header_5eenhancer", "option_token_rotation_with_alt", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_STG", false, "option_header_5eenhancer", "option_saving_throw_graphics", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
end
