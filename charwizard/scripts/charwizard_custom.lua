function onInit()
end

function updateHitPoints(nodeChar, sClass, sRecord, nClassLevel)
	local aClassNames = {};
	local nTotalHP = DB.getValue(nodeChar, "hp.total", "number", 0);
	local nAddHP = 0;
	local nHP = 0;
	local nPrevLevel = 1;
	local bInclude = false;

  Debug.chat(nodeChar);

	local nConBonus = DB.getValue(nodeChar, "abilities.constitution.bonus", 0);
	for _,vClass in pairs(CampaignRegistry.charwizard.classes) do
		if not vClass.appliedHP then
			for _,vImpClass in pairs(CampaignRegistry.charwizard.impclasses) do
				if vClass.record == vImpClass.record then
					nPrevLevel = vImpClass.level;
					table.insert(aClassNames, vClass.name);
					if tonumber(vClass.level) > vImpClass.level then
						bInclude = true;
					end
				end
			end

			if not StringManager.contains(aClassNames, vClass.name) or bInclude then
				nHP = 0;
				nAddHP = 0;

				local nClassLevel = tonumber(vClass.level);
				local bHDFound = false;
				local nHDMult = 1;
				local nHDSides = 6;
				local sHD = DB.getText(DB.findNode(vClass.record), "hp.hitdice.text");
				if sHD then
					local sMult, sSides = sHD:match("(%d)d(%d+)");
					if sMult and sSides then
						nHDMult = tonumber(sMult);
						nHDSides = tonumber(sSides);
						bHDFound = true;
					end
				end
				if not bHDFound then
					outputUserMessage("char_error_addclasshd");
				end

				local nLevelDelta = (nClassLevel - nPrevLevel);
				if nLevelDelta < 1 then
					nLevelDelta = 1;
				end

				for i = 1,nLevelDelta do
					nAddHP = math.floor(((nHDMult * (nHDSides + 1)) / 2) + 0.5);
					nHP = nHP + nAddHP + nConBonus;
					outputUserMessage("char_abilities_message_hpaddavg", vClass.name, DB.getValue(nodeChar, "name", ""), nAddHP+nConBonus);
				end
			end
			vClass.appliedHP = true;
		end
		nTotalHP = nTotalHP + nHP;
	end
	DB.setValue(nodeChar, "hp.total", "number", nTotalHP);
end
