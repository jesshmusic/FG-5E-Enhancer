--
--
-- slash command
--
--

function onInit()
  if User.isHost()  then
    Comm.registerSlashHandler("readycheck", ConnectionManagerADND.processReadyCheck);
  	Comm.registerSlashHandler("dsave", TokenSaveGraphics.deleteSaveWidgets, "5E Enhancer: Delete saves");
  end

	Comm.registerSlashHandler('wsx_clear', clearHandler);
	Comm.registerSlashHandler('wsx_close', closeHandler);
	Comm.registerSlashHandler('wsx_help', helpHandler);
	Comm.registerSlashHandler('wsx_list', listHandler);
	Comm.registerSlashHandler('wsx_load', loadHandler);
	Comm.registerSlashHandler('wsx_open', openHandler);
	Comm.registerSlashHandler('wsx_restore', restoreHandler);
	Comm.registerSlashHandler('wsx_save', saveHandler);
end

-- ------------------------------------------------------------------
-- slashHandler - Parses /wsx for command and arguments            --
-- ------------------------------------------------------------------
function slashHandler(_, userInput)
	local delimiterIndex = userInput:find("%s");
	local command = nil;
	local argument = "";

	if delimiterIndex == nil then
		command = userInput;
	else
		command = userInput:sub(0, delimiterIndex-1);
		argument = userInput:sub(delimiterIndex):gsub("^%s+", "");
	end

  if (command  == "clear") then
		clearHandler(nil, argument);

	elseif (command == "close") then
		closeHandler();

	elseif (command  == "help") then
		helpHandler(nil, argument);

	elseif (command  == "list") then
		listHandler(nil, argument);

	elseif (command  == "load") then
		loadHandler(nil, argument);

	elseif (command  == "open") then
		openHandler(nil, argument);

	elseif (command  == "restore") then
		restoreHandler(nil, argument);

	elseif (command  == "save") then
		saveHandler(nil, argument);

	elseif (command == "share") then
		shareHandler(nil, argument);

	else
		Comm.addChatMessage({text="[WSX] Unrecognized command '"..command.."'"});
	end
end

-- ----------------------------------------------------------------
-- clearHandler - Tells host to remove preset from current user  --
-- ----------------------------------------------------------------
function clearHandler(_, name)
	if name == "" then
		Comm.addChatMessage({text="[WSX] Preset name required to remove"});
	else
		name = WindowSaveUtility.cleanInput(name);
		WindowSaveUtility.sendEvent({type="wsx_clear", name=name});
	end
end

-- ----------------------------------------------------------------
-- closeHandler - Closes all windows, then notifies the user     --
-- ----------------------------------------------------------------
function closeHandler()
	WindowSaveCore.closeAllWindows();
	Comm.addChatMessage({text="[WSX] All windows closed"});
end

-- -------------------------------------------------
-- helpHandler - Tells user of all slash commands --
-- -------------------------------------------------
function helpHandler(_, slashCommand)
	Comm.addChatMessage({text="[WSX] Window Saver X commands: "})
	Comm.addChatMessage({text="/wsx clear [name] - Deletes the preset named [name]"});
	Comm.addChatMessage({text="/wsx close - Closes all open windows"});
	Comm.addChatMessage({text="/wsx help - Displays this message"});
	Comm.addChatMessage({text="/wsx list [page number] - Lists your saved presets"});
	Comm.addChatMessage({text="/wsx load [name] - Closes all open windows, then opens windows in the preset [name]"});
	Comm.addChatMessage({text="/wsx open [name] - Opens windows in the preset [name] without closing windows"});
	Comm.addChatMessage({text="/wsx restore - Reopens all windows closed by the last time you quit the game or loaded a preset"});
	Comm.addChatMessage({text="/wsx save [name] - Saves a preset as [name]"});

	if User.isHost() then
		Comm.addChatMessage({text="GM only commands:"});
		Comm.addChatMessage({text="/wsx share [name] - Opens windows in the preset for everyone, sharing windows as needed"});
	end
end

-- ---------------------------------------------------------------
-- listHandler - Tells host to list presets to current user     --
-- ---------------------------------------------------------------
function listHandler(_, page)
	WindowSaveUtility.sendEvent({type="wsx_list", page=page});
end

-- ---------------------------------------------------------------
-- loadHandler - Closes all windows, then opens a preset        --
-- ---------------------------------------------------------------
function loadHandler(_, name)
	if name == "" then
		Comm.addChatMessage({text="[WSX] Preset name required to load"});
	else
		name = WindowSaveUtility.cleanInput(name);
		WindowSaveUtility.sendEvent({type="wsx_load", name=name});
	end
end

-- ---------------------------------------------------------------
-- openHandler - Opens a preset without closing any windows     --
-- ---------------------------------------------------------------
function openHandler(_, name)
	if name == "" then
		Comm.addChatMessage({text="[WSX] Preset name required to load"});
	else
		name = WindowSaveUtility.cleanInput(name);
		WindowSaveUtility.sendEvent({type="wsx_open", name=name});
	end
end

-- ---------------------------------------------------------------
-- restoreHandler - Tells host to list presets to current user  --
-- ---------------------------------------------------------------
function restoreHandler()
	if WindowSaveCore.local_restore_session == nil then
		WindowSaveCore.closeAllWindows();
		WindowSaveUtility.sendEvent({type="wsx_restore"});
	else
		local temp_session = WindowSaveCore.local_restore_session;
		local windowCount = 0;

		WindowSaveCore.closeAllWindows();

		for containerName,windowData in pairs(temp_session) do
			local path = windowData.path;
			if windowData.unbound ~= true and path ~= nil and DB.findNode(WindowSaveUtility.decode(path)) == nil then
				-- Window with path was deleted since saving
				temp_session[containerName] = nil;
			else
				path = path or "";
				local window = Interface.openWindow(windowData.class, path);
				window.setSize(windowData.width, windowData.height);
				window.setPosition(windowData.xPos, windowData.yPos);
				windowCount = windowCount + 1;
			end
		end
		local message = "[WSX] Restored "..windowCount.." previous window";
		if windowCount ~= 1 then
			message = message.."s";
		end
		Comm.addChatMessage({text=message});
	end
end

-- ---------------------------------------------------------------
-- saveHandler - Tells host to save preset for current user     --
-- ---------------------------------------------------------------
function saveHandler(_, name)
  if name == "" then
		Comm.addChatMessage({text="[WSX] Preset name required to save"});
	else
    name = WindowSaveUtility.cleanInput(name);
  	WindowSaveCore.handleSave(name);
  end
end

-- -------------------------------------------------------------------------
-- shareHandler - (GM only) Opens preset for all users, sharing as needed --
-- -------------------------------------------------------------------------
function shareHandler(_, name)
	if name == "" then
		Comm.addChatMessage({text="[WSX] Preset name required to share"});
	else
		name = WindowSaveUtility.cleanInput(name);
		WindowSaveUtility.sendEvent({type="wsx_share", name=name});
	end
end
