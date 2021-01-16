-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	--DB.addHandler("battle.*.npclist.*","onChildUpdate",updateChallenge);
	
	aRecords = LibraryData.getRecordTypes();
	for kRecordType,vRecordType in pairs(aRecords) do
        if vRecordType == "battle" then
            LibraryData.addIndexButton(vRecordType, "button_new_encounter");
        end
    end
	
end


function updateChallenge (nodeNPCList)

	nodeEncounter=DB.getParent(nodeNPCList);
	encounterWindow=Interface.findWindow("battle",nodeEncounter);	
	encounterWindow.battle_header.cr.onInit();
end





function onDrop(x, y, draginfo)

	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();			
		return addLink_JH(getDatabaseNode().getParent(), sClass, sRecord);
	end
end

function addLink_JH(nodeEncounter, sClass, sRecord, sType)

	if not nodeEncounter then
		return false;
	end
	
	if sClass == "imagewindow" and sType=="map" then
		addMapDB(nodeEncounter, sClass, sRecord);
	elseif sClass == "imagewindow" and sType=="image" then
		addImageDB(nodeEncounter, sClass, sRecord);	
	elseif sClass == "treasureparcel" then
		addParcelDB(nodeEncounter, sClass, sRecord);
	elseif sClass == "encounter" then
		addStoryDB(nodeEncounter, sClass, sRecord);
	elseif sClass == "battle" then
		addEncounterDB(nodeEncounter, sClass, sRecord);
	elseif sClass == "sosound" then
		addSoundDB(nodeEncounter, sClass, sRecord);
		
	else	
		return false;
	end
	
	return true;
end


function addMapDB(nodeEncounter, sClass, sRecord)

	
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end

		
	DB.setValue(nodeEncounter, "map", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeEncounter, "maplink", "windowreference", sClass,  nodeSource.getNodeName());
	
	return true;
end

function addImageDB(nodeEncounter, sClass, sRecord)

	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	DB.setValue(nodeEncounter, "image", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeEncounter, "imagelink", "windowreference", sClass,  nodeSource.getNodeName());
	
	return true;
end


function addParcelDB(nodeEncounter, sClass, sRecord)

	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	DB.setValue(nodeEncounter, "parcel", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeEncounter, "parcellink", "windowreference", sClass,  nodeSource.getNodeName());
	
	return true;
end

function addStoryDB(nodeEncounter, sClass, sRecord)

	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	DB.setValue(nodeEncounter, "story", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeEncounter, "storylink", "windowreference", sClass,  nodeSource.getNodeName());
	
	return true;
end

function addEncounterDB(nodeEncounter, sClass, sRecord)

	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	DB.setValue(nodeEncounter, "encounter", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeEncounter, "encounterlink", "windowreference", sClass,  nodeSource.getNodeName());
	
	return true;
end

function addSoundDB(nodeEncounter, sClass, sRecord)

	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	DB.setValue(nodeEncounter, "sound", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeEncounter, "soundlink", "windowreference", sClass,  nodeSource.getNodeName());
	
	return true;
end


function resolveRefNode(sRecord)
	local nodeSource = DB.findNode(sRecord);
	if not nodeSource then
		local sRecordSansModule = StringManager.split(sRecord, "@")[1];
		nodeSource = DB.findNode(sRecordSansModule .. "@*");
		if not nodeSource then
			outputUserMessage("char_error_missingrecord");
		end
	end
	return nodeSource;
end

function handleFactionDropOnImage(imagecontrol, x, y)
	if not User.isHost() then return; end
	
	if not UtilityManager.isClientFGU() then
		-- Determine image viewpoint
		-- Handle zoom factor (>100% or <100%) and offset drop coordinates
		local vpx, vpy, vpz = imagecontrol.getViewpoint();
		x = x / vpz;
		y = y / vpz;
	end
	
	-- If grid, then snap drop point and adjust drop spread
	local nDropSpread = 15;
	if imagecontrol.hasGrid() then
		x, y = imagecontrol.snapToGrid(x, y);
		nDropSpread = imagecontrol.getGridSize();
	end

	-- Grab faction data from drag object, and apply to each combatant node
	local sFaction = "foe";
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(v, "friendfoe", "") == sFaction then
			local sToken = DB.getValue(v, "token", "");
			if sToken ~= "" then
				-- Add it to the image at the drop coordinates
				TokenManager.setDragTokenUnits(DB.getValue(v, "space"));
				local tokenMap = imagecontrol.addToken(sToken, x, y);
				TokenManager.endDragTokenWithUnits();

				-- Update token references
				CombatManager.replaceCombatantToken(v, tokenMap);
				
				-- Offset drop coordinates for next token
				if UtilityManager.isClientFGU() then
					x = x - nDropSpread;
					y = y - nDropSpread;
				else
					if x >= (nDropSpread * 1.5) then
						x = x - nDropSpread;
					end
					if y >= (nDropSpread * 1.5) then
						y = y - nDropSpread;
					end
				end
			end
		end
	end
	
	local sFaction = "neutral";
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		if DB.getValue(v, "friendfoe", "") == sFaction then
			local sToken = DB.getValue(v, "token", "");
			if sToken ~= "" then
				-- Add it to the image at the drop coordinates
				TokenManager.setDragTokenUnits(DB.getValue(v, "space"));
				local tokenMap = imagecontrol.addToken(sToken, x, y);
				TokenManager.endDragTokenWithUnits();

				-- Update token references
				CombatManager.replaceCombatantToken(v, tokenMap);
				
				-- Offset drop coordinates for next token
				if UtilityManager.isClientFGU() then
					x = x - nDropSpread;
					y = y - nDropSpread;
				else
					if x >= (nDropSpread * 1.5) then
						x = x - nDropSpread;
					end
					if y >= (nDropSpread * 1.5) then
						y = y - nDropSpread;
					end
				end
			end
		end
	end
	
	
	return true;
end



function findNPCMapLink(nodeEncounter)

	nodeNPClist=DB.getChild(nodeEncounter,"npclist");
	tNPCs=nodeNPClist.getChildren();
	
	for _,npc in pairs (tNPCs) do
		
		maplinks=DB.getChild(npc,"maplink");
		

		
		tMaplinks=maplinks.getChildren();
		
	
		
		for _,maplink in pairs (tMaplinks) do
		
			nodeMaplink = DB.getChild(maplink,"imageref");
			class,record=nodeMaplink.getValue();
			
			
		
		
			if record~=nil and record ~="" then				
				--Interface.openWindow("imagewindow",record);
				
				if string.match(record,".image") then
					record=string.gsub(record,".image","");
				end
				
				--if string.match(record,"%*") then				
				--	record=string.gsub(record,"%*","DD Lost Mine of Phandelver");
			--	end
		
				
				return record;
				
			
			end
			
		end
	end
return false;
end



function shareAllNPCImages(nodeEncounter)

	nodeNPClist=DB.getChild(nodeEncounter,"npclist");
	tNPCs=nodeNPClist.getChildren();
	
	for _,npc in pairs (tNPCs) do
		npcLink=npc.getChild("link");
		
		if npcLink then 
			class,recordname=npcLink.getValue();
			npcNode=DB.findNode(recordname);
			npcText=npcNode.getChild("text");
						
			if npcText then
				sLink=getIMGLinkFromText(npcText.getValue());			
				
				if sLink then
				sLink=string.gsub(sLink,"D&amp;D","D&D");							
					nodeImage=DB.findNode(sLink);
					npcImageWindow=Interface.openWindow("imagewindow",nodeImage);
					npcImageWindow.share();					
				end
			
			end
		end		
	
	
	end

end

function getIMGLinkFromText(sOriginal)
	sLink=string.match(sOriginal, "imagewindow\" recordname=\"(.-)\">")
	return sLink
end

function calcBattleChallenge(nodeEncounter)
	
	local tNPCs = DB.getChild(nodeEncounter,"npclist").getChildren();
	
	nNPCs=0;

	local nXP = 0;
	for _, vNPCItem in pairs(tNPCs) do
		local sClass, sRecord = DB.getValue(vNPCItem, "link", "", "");
		if sRecord ~= "" then
			local nodeNPC = DB.findNode(sRecord);
			if nodeNPC then
				nXP = nXP + (DB.getValue(vNPCItem, "count", 0) * DB.getValue(nodeNPC, "xp", 0));
				nNPCs= nNPCs + DB.getValue(vNPCItem, "count", 0);
			
			else
				local sMsg = string.format(Interface.getString("enc_message_refreshxp_missingnpclink"), DB.getValue(vNPCItem, "name", ""));
				ChatManager.SystemMessage(sMsg);
			end
		end
	end
	
	
	
	local nEasy =0;
	local nMedium =0
	local nHard =0;
	local nDeadly =0
	
	
	nodePS=DB.createChild("partysheet","partyinformation");
	local tPCList = nodePS.getChildren();

	
	for _, pc in pairs(tPCList) do
	
		nodeChar= PartyManager.mapPStoChar(pc);
		nLevel=DB.getValue(nodeChar,"level");
			
		if nLevel ==1 then 
			nEasy=nEasy+25;
			nMedium=nMedium+50;
			nHard=nHard+75;
			nDeadly=nDeadly+100;
		elseif nLevel ==2 then 
			nEasy=nEasy+50;
			nMedium=nMedium+100;
			nHard=nHard+150;
			nDeadly=nDeadly+200;
		elseif nLevel ==3 then 
			nEasy=nEasy+75;
			nMedium=nMedium+150;
			nHard=nHard+225;
			nDeadly=nDeadly+400;
		elseif nLevel ==4 then 
			nEasy=nEasy+125;
			nMedium=nMedium+250;
			nHard=nHard+375;
			nDeadly=nDeadly+500;
		elseif nLevel ==5 then 
			nEasy=nEasy+250;
			nMedium=nMedium+500;
			nHard=nHard+750;
			nDeadly=nDeadly+1100;
		elseif nLevel ==6 then 
			nEasy=nEasy+300;
			nMedium=nMedium+600;
			nHard=nHard+900;
			nDeadly=nDeadly+1400;
		elseif nLevel ==7 then 
			nEasy=nEasy+350;
			nMedium=nMedium+750;
			nHard=nHard+1100;
			nDeadly=nDeadly+1700;
		elseif nLevel ==8 then 
			nEasy=nEasy+450;
			nMedium=nMedium+900;
			nHard=nHard+1400;
			nDeadly=nDeadly+2100;
		elseif nLevel ==9 then 
			nEasy=nEasy+550;
			nMedium=nMedium+1100;
			nHard=nHard+1600;
			nDeadly=nDeadly+2400;
		elseif nLevel ==10 then 
			nEasy=nEasy+600;
			nMedium=nMedium+1200;
			nHard=nHard+1900;
			nDeadly=nDeadly+2800;
		elseif nLevel ==11 then 
			nEasy=nEasy+800;
			nMedium=nMedium+1600;
			nHard=nHard+2400;
			nDeadly=nDeadly+3600;
		elseif nLevel ==12 then 
			nEasy=nEasy+1000;
			nMedium=nMedium+2000;
			nHard=nHard+3000;
			nDeadly=nDeadly+4500;
		elseif nLevel ==13 then 
			nEasy=nEasy+1100;
			nMedium=nMedium+2200;
			nHard=nHard+3400;
			nDeadly=nDeadly+5100;
		elseif nLevel ==14 then 
			nEasy=nEasy+1250;
			nMedium=nMedium+2500;
			nHard=nHard+3800;
			nDeadly=nDeadly+5700;
		elseif nLevel ==15 then 
			nEasy=nEasy+1400;
			nMedium=nMedium+2800;
			nHard=nHard+4300;
			nDeadly=nDeadly+6400;
		elseif nLevel ==16 then 
			nEasy=nEasy+1600;
			nMedium=nMedium+3200;
			nHard=nHard+4800;
			nDeadly=nDeadly+7200;
		elseif nLevel ==17 then 
			nEasy=nEasy+2000;
			nMedium=nMedium+3900;
			nHard=nHard+5900;
			nDeadly=nDeadly+8800;
		elseif nLevel ==18 then 
			nEasy=nEasy+2100;
			nMedium=nMedium+4200;
			nHard=nHard+6300;
			nDeadly=nDeadly+9500;
		elseif nLevel ==19 then 
			nEasy=nEasy+2400;
			nMedium=nMedium+4900;
			nHard=nHard+7300;
			nDeadly=nDeadly+10900;
		elseif nLevel ==20 then 
			nEasy=nEasy+2800;
			nMedium=nMedium+5700;
			nHard=nHard+8500;
			nDeadly=nDeadly+12700;
		else
		
		end
		
	end
	
	if nNPCs==1 then
		nMultiplier=1;
	elseif nNPCs==2 then
		nMultiplier=1.5;
	elseif nNPCs<=6 then
		nMultiplier=2;
	elseif nNPCs<=10 then
		nMultiplier=2.5;
	elseif nNPCs<=14 then
		nMultiplier=3;
	else
		nMultiplier=4;
	end
	

	nAXP = nXP* nMultiplier;

	sChallenge="";
	
	if nAXP < nEasy then
		sChallenge="Trivial";		
	elseif nAXP< nMedium then
		sChallenge="Easy";		
	elseif nAXP< nHard then 
		sChallenge="Medium";
	elseif nAXP< nDeadly then 
		sChallenge="Hard";
	elseif nAXP< nDeadly*3 then
		sChallenge="Deadly"
	else
		sChallenge="Certain Death"
	end
	
		
	DB.setValue(nodeBattle, "challenge", "string", sChallenge);
	DB.setValue(nodeBattle, "exp", "number", nXP);
	
	return sChallenge;
	
end


	