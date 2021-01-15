-- mainNode - The WindowSaver DB node.
mainNode = nil;

function onInit()
	if User.isHost() then
		mainNode = DB.findNode("WindowSaverX");
		if mainNode == nil then
			mainNode = DB.createNode("WindowSaverX");
		end
	end
	
	OOBManager.registerOOBMsgHandler("wsx_clear", clearUserPreset);
	OOBManager.registerOOBMsgHandler("wsx_init", initializeClient);
	OOBManager.registerOOBMsgHandler("wsx_list", listUserPresets);
	OOBManager.registerOOBMsgHandler("wsx_load", loadUserPreset);
	OOBManager.registerOOBMsgHandler("wsx_open", openUserPreset);
	OOBManager.registerOOBMsgHandler("wsx_share", sharePreset);	
	OOBManager.registerOOBMsgHandler("wsx_restore", restoreWindows);
	OOBManager.registerOOBMsgHandler("wsx_window_close", onWindowClosed);
	OOBManager.registerOOBMsgHandler("wsx_window_save", saveWindow);		
end

-- ------------------------------------------------------------------
-- InitializeClient - Handles current_session to restore_session work --
-- ------------------------------------------------------------------
function initializeClient(data)
	if User.isHost() then
		clearUserPreset({username=data.username, name="restore_session", internalUse=true, suppressAlert=true});
		copyPreset({username=data.username, name="restore_session", internalUse=true});
		clearUserPreset({username=data.username, name="current_session", internalUse=true, suppressAlert=true});
	end
end

-- --------------------------------------------------------------------------------------
-- onWindowClosed - Called when the host is notified of a client closing a window      --
-- --------------------------------------------------------------------------------------
function onWindowClosed(windowData)
	if User.isHost() then
		local currentSession = findUserPreset({username=windowData.username, name="current_session", internalUse=true});
		
		local containerName = WindowSaveUtility.getContainerName(windowData.class, windowData.path);
		
		currentSession.createChild(containerName).delete();
	end
end

-- ---------------------------------------------------------------
-- FindUserPreset - Find preset given a user and preset name		--
-- ---------------------------------------------------------------
function findUserPreset(presetData)
	if User.isHost() then
		local userNode = mainNode.createChild(presetData.username);
		local parentNode = nil;
		local presetNode = nil;

		if presetData.internalUse ~= nil then
			parentNode = userNode;
		else
			parentNode = userNode.createChild("presets");
		end

		local name = WindowSaveUtility.encode(presetData.name);
		if presetData.noCreate == true then
			presetNode = parentNode.getChild(name);
		else
			presetNode = parentNode.createChild(name);
		end

		return presetNode;
	end
end

-- ---------------------------------------------------------------
-- ListUserPresets - Lists all of the user's saved presets			--
-- ---------------------------------------------------------------
function listUserPresets(data)
	if User.isHost() then
		local username = data.username;
		local page = data.page;

		local userNode = mainNode.createChild(username);
		local userPresetsNode = userNode.createChild("presets");
		local presets = {};
		for presetName in pairs(userPresetsNode.getChildren()) do
			table.insert(presets, presetName);
		end
		table.sort(presets);
		local presetCount = WindowSaveUtility.getTableSize(presets);

		local alertText = "[WSX] You have "..presetCount.." preset";
		
		if presetCount ~= 1 then
			alertText = alertText.."s";
		end
		
		if presetCount > 0 then
			local pageCount = math.ceil(presetCount/20);
			page = tonumber(page) or 1;

			if page < 1 or page > pageCount then
				page = 1;
			end

			alertText = alertText.." (Page "..page.." of "..pageCount..")";
			
			WindowSaveUtility.alertClient(alertText..":", username);
			
			for i,presetName in ipairs(presets) do
				if i > (page-1)*20 and i <= page*20 then
					WindowSaveUtility.alertClient("'"..WindowSaveUtility.decode(presetName).."'", username);
				end
			end
		else
			WindowSaveUtility.alertClient(alertText, username);
		end
	end
end

-- ---------------------------------------------------------------
-- copyPreset - Copies current preset to a second preset  			--
-- ---------------------------------------------------------------
function copyPreset(presetData)
	if User.isHost() then
		local currentSession = findUserPreset({username=presetData.username, name="current_session", internalUse=true});
		clearUserPreset({username=presetData.username, name=presetData.name,  internalUse=presetData.internalUse, suppressAlert=true});

		for _,windowData in pairs(currentSession.getChildren()) do
			local geo = windowData.createChild("geometry");
			saveWindow({
				username=presetData.username,
				name=presetData.name,
				class=windowData.getChild("class").getValue(),
				path=windowData.createChild("path").getValue(),
				width=geo.createChild("width").getValue(),
				height=geo.createChild("height").getValue(),
				xPos=geo.createChild("xPos").getValue(),
				yPos=geo.createChild("yPos").getValue(),
				internalUse=true
			});
		end
	end
end

-- ---------------------------------------------------------------
-- LoadUserPreset - Sends list of windows to the client to open	--
-- ---------------------------------------------------------------
function loadUserPreset(presetData)
	if User.isHost() then
		local preset = nil;
		if (presetData.usePreset ~= nil) then
			preset = presetData.usePreset;
		else
			preset = findUserPreset({username=presetData.username, name=presetData.name, internalUse=presetData.internalUse, noCreate=true});
		end
		
		local windowCount = 0;

		if preset ~= nil then
			if presetData.noClose == nil then
				closeAllWindows(presetData.username);
			end

			for _,windowData in pairs(preset.getChildren()) do
					local class = windowData.getChild("class").getValue();
					local path = windowData.getChild("path");
					if path ~= nil then
						path = path.getValue();
					end
					local unbound = windowData.getChild("unbound") ~= nil;
			
					if unbound == false and path ~= nil and DB.findNode(WindowSaveUtility.decode(path)) == nil then
						-- Window with path was deleted since saving
						windowData.delete()
					else
						local geometry = windowData.getChild("geometry");
			
						WindowSaveUtility.sendEvent({
							type="wsx_client_open",
							class=class,
							path=path,
							height=geometry.getChild("height").getValue(),
							width=geometry.getChild("width").getValue(),
							xPos=geometry.getChild("xPos").getValue(),
							yPos=geometry.getChild("yPos").getValue(),
							recipient=presetData.username
						});
						windowCount = windowCount + 1;
					end
			end

			if presetData.suppressAlert == nil then
				
				local message = nil;
				if presetData.noCreate == nil then
					message = "[WSX] Loaded "..windowCount.." window";
				else
					message = "[WSX] Opened "..windowCount.." window";
				end

				if windowCount ~= 1 then
					message = message.."s";
				end
				message = message.." from '"..presetData.name.."'";
				WindowSaveUtility.alertClient(message, presetData.username);
			end
		else
			if presetData.suppressAlert == nil then
				WindowSaveUtility.alertClient("[WSX] No preset exists with the name '"..presetData.name.."'", presetData.username);
			end
		end
		return {windowCount=windowCount};
	end
end

-- ---------------------------------------------------------------
-- ClearUserPreset - Removes a preset for the current user      --
-- ---------------------------------------------------------------
function clearUserPreset(presetData)
	if User.isHost() then
		presetData.noCreate=true;
		local preset = findUserPreset(presetData);

		if preset then
			preset.delete();
			if presetData.suppressAlert == nil then
				WindowSaveUtility.alertClient("[WSX] Removed '"..presetData.name.."'", presetData.username);
			end
		elseif presetData.suppressAlert == nil then
			WindowSaveUtility.alertClient("[WSX] No preset with the name '"..presetData.name.."'", presetData.username);
		end
		-- Allows for creation of empty presets
		if presetData.remake ~= nil then
			presetData.noCreate = nil;
			findUserPreset(presetData);
		end
	end
end

-- ---------------------------------------------------------------
-- CloseAllWindows - Closes all open windows on the client      --
-- ---------------------------------------------------------------
function closeAllWindows(username)
	if User.isHost() then
		clearUserPreset({username=username, name="current_session", internalUse=true, suppressAlert=true});
		WindowSaveUtility.sendEvent({type="wsx_client_close_all", recipient=username});
	end
end

-- ---------------------------------------------------------------
-- saveWindow - Saves geometry data of a window                 --
-- ---------------------------------------------------------------
function saveWindow(windowData)
	if User.isHost() then
		local preset = findUserPreset(windowData);

		local containerName = WindowSaveUtility.getContainerName(windowData.class, windowData.path);
		local containerNode = preset.createChild(containerName);
		local geometryNode = containerNode.createChild("geometry");

		local classNode = containerNode.createChild("class", "string");
		classNode.setValue(windowData.class);

		local pathNode = containerNode.createChild("path", "string");
		pathNode.setValue(windowData.path);

		local widthNode = geometryNode.createChild("width", "number");
		widthNode.setValue(tonumber(windowData.width));
		local heightNode = geometryNode.createChild("height", "number");
		heightNode.setValue(tonumber(windowData.height));

		local xPosNode = geometryNode.createChild("xPos", "number");
		xPosNode.setValue(tonumber(windowData.xPos));
		local yPosNode = geometryNode.createChild("yPos", "number");
		yPosNode.setValue(tonumber(windowData.yPos));

		-- Differentiates things like reference manual from deleted nodes
		if windowData.path and DB.findNode(WindowSaveUtility.decode(windowData.path)) == nil then
			local unbound = containerNode.createChild("unbound", "boolean");
			unbound.setValue(true);
		end
	end
end

-- --------------------------------------------------------------------------------
-- restoreWindows - Reopens all windows closed by last game close or preset load --
-- --------------------------------------------------------------------------------
function restoreWindows(data)
	if User.isHost() then
		local loadData = loadUserPreset({
			username=data.username,
			name="restore_session",
			internalUse=true,
			suppressAlert=true,
			noClose=true
		});
		WindowSaveUtility.alertClient("[WSX] Restored "..loadData.windowCount.." previous windows", data.username);
	end
end

-- ---------------------------------------------------------------------------------------
-- openUserPreset - Sends list of windows to the client to open without closing windows --
-- ---------------------------------------------------------------------------------------
function openUserPreset(presetData)
	if User.isHost() then
		presetData.noClose = true;
		loadUserPreset(presetData);
	end
end

-- --------------------------------------------------------------
-- sharePreset - Opens preset for all users, sharing as needed --
-- --------------------------------------------------------------
function sharePreset(presetData)
	if User.isHost() then
		local preset = findUserPreset({username=presetData.username, name=presetData.name, noCreate=true});

		for _,windowData in pairs(preset.getChildren()) do
			local path = windowData.getChild("path");
			if path ~= nil then
				path = path.getValue();
			end
			local node = DB.findNode(path);
			if (path ~= "" and node) then
				node.setPublic(true);
			end
		end
		
		presetData.suppressAlert = true;
		presetData.usePreset = preset;
		openUserPreset(presetData);
		for _,v in ipairs(User.getActiveUsers()) do
			presetData.username = v;
			openUserPreset(presetData);
		end
		Comm.addChatMessage({text="[WSX] Shared "..presetData.name});
	end
end