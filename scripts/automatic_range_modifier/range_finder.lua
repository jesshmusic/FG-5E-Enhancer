-- Returns the range between two tokens on the battlemap, minor modifications to core code snippet from 5E Ruleset -> manager_actor2.lua.

function onInit()
	ImageManager.onMeasurePointer = onMeasurePointer;
end


function getRange(rAttacker, rDefender)
	local nodeAttacker = ActorManager.getCTNode(rAttacker);
	local nodeDefender = ActorManager.getCTNode(rDefender);

	if nodeAttacker and nodeDefender then
		local tokenAttacker = CombatManager.getTokenFromCT(nodeAttacker);
		local tokenDefender = CombatManager.getTokenFromCT(nodeDefender);

		if tokenAttacker and tokenDefender then
				local nodeAttackerContainer = tokenAttacker.getContainerNode();
				local nodeDefenderContainer = tokenDefender.getContainerNode();

				if nodeAttackerContainer.getNodeName() == nodeDefenderContainer.getNodeName() then
					local nDU = GameSystem.getDistanceUnitsPerGrid();
					local nAttackerSpace = math.ceil(DB.getValue(nodeAttacker, "space", nDU) / nDU);
					local nDefenderSpace = math.ceil(DB.getValue(nodeDefender, "space", nDU) / nDU);
					local xAttacker, yAttacker = tokenAttacker.getPosition();
					local xDefender, yDefender = tokenDefender.getPosition();

					-- START OF NEW CODE REPLACEMENT
					local ctrlImage = TokenHelper.getControlImageByToken(tokenAttacker);
					local nGrid = ctrlImage.getGridSize();
					-- END OF NEW CODE REPLACEMENT

					local xDiff = math.abs(xAttacker - xDefender);
					local yDiff = math.abs(yAttacker - yDefender);
					local gx = math.floor(xDiff / nGrid);
					local gy = math.floor(yDiff / nGrid);

					local nSquares = 0;
					local nStraights = 0;

					if gx > gy then
						nSquares = nSquares + gy;
						nSquares = nSquares + gx - gy;
					else
						nSquares = nSquares + gx;
						nSquares = nSquares + gy - gx;
					end
					nSquares = nSquares - (nAttackerSpace / 2);
					nSquares = nSquares - (nDefenderSpace / 2);

					-- START OF NEW CODE REPLACEMENT
					local distance2D = 0;
					local distance3D = 0;
					distance2D = math.ceil( (nSquares + 1) * nDU );

					-- local rangeRules = OptionsManager.getOption('CE_RRU');
					-- if (rangeRules == 'option_on') then
					-- distance2D = math.ceil( (nSquares + 1) * nDU );
					-- end
					--[[ disabled rules for the time being as not working properly
					if (rangeRules == 'option_variant') then
						distance2D = Interface.getDistanceDiagMult();
						Debug.chat('option_variant range', distance2D);
					end
					if (rangeRules == 'option_raw') then
						distance2D = math.ceil(((xDiff^2+yDiff^2)^0.5)/(nGrid/nDU));
					end
					]]--

					-- get height from tokens
					local actorHeight = TokenHeight.getTokenHeight(tokenAttacker);
					local targetHeight = TokenHeight.getTokenHeight(tokenDefender);

					-- calculate range with height included
					local heightDifference = actorHeight - targetHeight;
					distance3D = math.sqrt((heightDifference^2)+(distance2D^2));

					-- find final range to return
					distance3D = math.floor(distance3D);
					--Debug.console('Precise range of attack: ', distance3D);

					local modulo = distance3D % 5;

					if (modulo > 0) then
						distance3D = distance3D - modulo + nDU;
					end

					return distance3D;
					-- END OF NEW CODE REPLACEMENT
				end

		end
	end
end

-- Height Extension modifications
local measureLock = false;
function acquireMeasureSemaphore()
	if not measureLock then
		measureLock = true;
		return true;
	end
	return false;
end

-- releases the semaphore if it is held
function releaseMeasureSemaphore()
	if measureLock then
		measureLock = false;
	end
end

-- peek at the semaphore without acquiring it
function checkMeasureSempahore()
	return measureLock;
end

local listCT;
-- We're preforming up to N lookups each time to find tokens
-- at the pointer start/end positions, fortunately,
-- the points given for targeting are directly
-- at the center of each token, the pixel length
-- is useless, the map coords are where the real
-- meat is.
function getNodeHeightsAt(posSX,posSY,posEX,posEY,gridSize)
	local startTokenHeight = nil;
	local endTokenHeight = nil;

	if not listCT then
		listCT = DB.findNode('combattracker.list');
	end

	local ctEntries = listCT.getChildren();

	for k,v in pairs(ctEntries) do
		token = CombatManager.getTokenFromCT(v);
		if token then
			local posX,posY = token.getPosition()
			--Debug.console('coords of token ' .. v.getChild('name').getValue() .. ' X: ' .. posX .. ' Y: ' .. posY .. ' ++VS++ X: ' .. posSX .. ' Y: ' .. posSY);
			if posX == posSX and posY == posSY then
				startTokenHeight = getCTEntryHeight(v);
			elseif posX == posEX and posY == posEY then
				endTokenHeight = getCTEntryHeight(v);
			end
			-- end prematurely
			if startTokenHeight ~= nil and endTokenHeight ~= nil then
				break;
			end
		end
	end

	if startTokenHeight == nil then
		startTokenHeight = 0;
	end
	if endTokenHeight == nil then
		endTokenHeight = 0;
	end


	return startTokenHeight, endTokenHeight;
end

-- just get the node
function getCTNodesAt(posSX,posSY,posEX,posEY)
	local startNodeCT = nil;
	local endNodeCT = nil;

	if not listCT then
		listCT = DB.findNode('combattracker.list');
	end

	local ctEntries = listCT.getChildren();

	for k,v in pairs(ctEntries) do
		token = CombatManager.getTokenFromCT(v);
		if token then
			local posX,posY = token.getPosition()
			--Debug.console('coords of token ' .. v.getChild('name').getValue() .. ' X: ' .. posX .. ' Y: ' .. posY .. ' ++VS++ X: ' .. posSX .. ' Y: ' .. posSY);
			if posX == posSX and posY == posSY then
				startNodeCT = v;
			elseif posX == posEX and posY == posEY then
				endNodeCT = v;
			end
			-- end prematurely
			if startNodeCT ~= nil and endNodeCT ~= nil then
				break;
			end
		end
	end

	return startNodeCT, endNodeCT;
end

-- get the CT Height entry if it exists
function getCTEntryHeight(ctEntry)
	if ctEntry then
		local heightNode = ctEntry.getChild('height');
		if heightNode then
			return heightNode.getValue();
		else
			--Debug.console('no height node!');
		end
	end
	return 0;
end

-- sub in the measurement text for our custom variant for height
function onMeasurePointer(imgCtrl, pixellength, pointertype, startx, starty, endx, endy)
	local lock = acquireMeasureSemaphore();
	if lock then
		local ctNodeStart,ctNodeEnd = getCTNodesAt(startx,starty,endx,endy);
		local calculatedRange = getRange(ctNodeStart,ctNodeEnd);
		releaseMeasureSemaphore();
		if calculatedRange then
			return ('' .. (calculatedRange) .. ' ft');
		end
		local gridSize = imgCtrl.getGridSize();
		local snapSX,snapSY = imgCtrl.snapToGrid(startx,starty);
		local snapEX,snapEY = imgCtrl.snapToGrid(endx,endy);
		local lenX = math.floor(math.abs(snapSX - snapEX)/gridSize);
		local lenY = math.floor(math.abs(snapSY - snapEY)/gridSize);
		calculatedRange = math.max(lenX,lenY) + math.floor(math.min(lenX,lenY)/2);
		return ('' .. (calculatedRange*5) .. ' ft');
	end
	return '';
end
