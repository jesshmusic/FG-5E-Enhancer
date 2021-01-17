function onInit()
	CombatManager.setCustomTurnStart(onTurnStart);
end

function onTurnStart(nodeEntry)
  if not nodeEntry then
		return;
	end

  -- If there is a save marker, get rid of it at the start of the turn.
	local tokenCT = CombatManager.getTokenFromCT(nodeEntry);
	if tokenCT then
	  local saveWidget = tokenCT.findWidget("save");

		if saveWidget then
			saveWidget.destroy();
		end
	end

	CombatManager2.onTurnStart
end
