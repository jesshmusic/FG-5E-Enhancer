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
	OptionsManager.registerOption2("CE_ARM", false, "option_header_5eenhancer", "option_automatic_ranged_modifiers", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_BOT", false, "option_header_5eenhancer", "option_blood_on_tokens", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_BP", false, "option_header_5eenhancer", "option_blood_pool", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_HHB", false, "option_header_5eenhancer", "option_horizontal_health_bars", "option_entry_cycler",
		{ labels = "Off|Left, Default|Left, Taller|Centered, Default|Centered, Taller", values = "option_off|option_v1|option_v2|option_v3|option_v4", default = "option_off" })
	OptionsManager.registerOption2("CE_LHD", false, "option_header_5eenhancer", "option_larger_health_dots", "option_entry_cycler",
		{ labels = "Off|Larger|Largest", values = "option_off|option_larger|option_largest", default = "option_larger" })
	OptionsManager.registerOption2("CE_TRA", false, "option_header_5eenhancer", "option_token_rotation_with_alt", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_SRU", false, "option_header_5eenhancer", "option_show_reach_underlay", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_SFU", false, "option_header_5eenhancer", "option_show_faction_underlay", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_SC", false, "option_header_5eenhancer", "option_skull_or_cross", "option_entry_cycler",
		{ labels = "Off|Skull|Cross", values = "option_off|option_skull|option_cross", default = "option_skull" })
--	OptionsManager.registerOption2("CE_STR", false, "option_header_5eenhancer", "option_stop_token_rotate", "option_entry_cycler",
--		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })
	OptionsManager.registerOption2("CE_TRBC", false, "option_header_5eenhancer", "option_token_remove_button_combo", "option_entry_cycler",
		{ labels = "Alt + L-Click|Alt + Shift + L-Click", values = "option_val_alt|option_val_alt_shift", default = "option_val_alt" })
	OptionsManager.registerOption2("CE_HFS", false, "option_header_5eenhancer", "option_height_font_size", "option_entry_cycler",
		{ labels = "small|medium|large", values = "option_small|option_medium|option_large", default = "option_medium" })
	OptionsManager.registerOption2("CE_SAAU", false, "option_header_5eenhancer", "option_gm_underlay_show_ct_active_actor_underlay", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })
	OptionsManager.registerOption2("CE_UOP", false, "option_header_5eenhancer", "option_gm_underlay_opacity", "option_entry_cycler",
		{ labels = "100%|90%|80%|70%|60%|50%|40%|30%|20% (best)|10%", values = "100|90|80|70|60|50|40|30|20|10", default = "20" })
	OptionsManager.registerOption2("CE_US", false, "option_header_5eenhancer", "option_gm_underlay_size", "option_entry_cycler",
		{ labels = "full|half", values = "option_full|option_half", default = "option_full" })
	OptionsManager.registerOption2("CE_FR", false, "option_header_5eenhancer", "option_flanking_rules", "option_entry_cycler",
		{ labels = "Advantage|+1|+2|+5", values = "option_val_on|option_val_1|option_val_2|option_val_on_5", baselabel = "option_val_off", baseval = "option_val_off", default = "option_val_off" })
	OptionsManager.registerOption2("CE_RMM", false, "option_header_5eenhancer", "option_ranged_melee_modifier", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
--	OptionsManager.registerOption2("CE_RRU", false, "option_header_5eenhancer", "option_range_rules_used", "option_entry_cycler",
--		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })
	OptionsManager.registerOption2("CE_SNIA", false, "option_header_5eenhancer", "option_skip_non_initiatived_actor", "option_entry_cycler",
		{ labels = "option_val_on", valueSs = "on", baselabel = "option_val_off", baseval = "off", default = "off" })
	OptionsManager.registerOption2("CE_STG", false, "option_header_5eenhancer", "option_saving_throw_graphics", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
end
