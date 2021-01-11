function onInit()
	CombatManager.setCustomTurnStart(onTurnStart);
end

function onTurnStart(nodeEntry)
  if not nodeEntry then
		return;
	end

  -- If there is a save marker, get rid of it at the start of the turn.
	local tokenCT = CombatManager.getTokenFromCT(nodeEntry);
  local saveWidget = tokenCT.findWidget("save");

	if saveWidget then
		saveWidget.destroy();
	end

	-- Handle beginning of turn changes
	DB.setValue(nodeEntry, "reaction", "number", 0);

	-- Check for death saves (based on option)
	if OptionsManager.isOption("HRST", "on") then
		if nodeEntry then
			local sClass, sRecord = DB.getValue(nodeEntry, "link");
			if sClass == "charsheet" and sRecord then
				local nHP = DB.getValue(nodeEntry, "hptotal", 0);
				local nWounds = DB.getValue(nodeEntry, "wounds", 0);
				local nDeathSaveFail = DB.getValue(nodeEntry, "deathsavefail", 0);
				if (nHP > 0) and (nWounds >= nHP) and (nDeathSaveFail < 3) then
					local rActor = ActorManager.getActor("pc", sRecord);
					if not EffectManager5E.hasEffect(rActor, "Stable") then
						ActionSave.performDeathRoll(nil, rActor);
					end
				end
			end
		end
	end
end
