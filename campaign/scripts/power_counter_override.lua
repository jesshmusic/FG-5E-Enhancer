-- only this function is overridden, rest are unchanged
function onClickDown(button, x, y)
	-- update group visibility beforehand
	window.parentcontrol.window.windowlist.window.onUsesChanged()
	-- disable group visibility update 1 time
	Spell_Automation.SkipUsesUpdate = 1
	return super.onClickDown(button, x, y)
end
