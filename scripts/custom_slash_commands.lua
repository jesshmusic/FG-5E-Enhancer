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

	Comm.registerSlashHandler('window_clear', clearHandler);
	Comm.registerSlashHandler('window_close', closeHandler);
	Comm.registerSlashHandler('window_help', helpHandler);
	Comm.registerSlashHandler('window_list', listHandler);
	Comm.registerSlashHandler('window_load', loadHandler);
	Comm.registerSlashHandler('window_open', openHandler);
	Comm.registerSlashHandler('window_restore', restoreHandler);
	Comm.registerSlashHandler('window_save', saveHandler);
end

-- ------------------------------------------------------------------
-- slashHandler - Parses /window_for command and arguments            --
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
		WindowSaveUtility.sendEvent({type="window_clear", name=name});
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
	Comm.addChatMessage({text="Window commands: "})
	Comm.addChatMessage({text="/window_clear [name] - Deletes the preset named [name]"});
	Comm.addChatMessage({text="/window_close - Closes all open windows"});
	Comm.addChatMessage({text="/window_help - Displays this message"});
	Comm.addChatMessage({text="/window_list [page number] - Lists your saved presets"});
	Comm.addChatMessage({text="/window_load [name] - Closes all open windows, then opens windows in the preset [name]"});
	Comm.addChatMessage({text="/window_open [name] - Opens windows in the preset [name] without closing windows"});
	Comm.addChatMessage({text="/window_restore - Reopens all windows closed by the last time you quit the game or loaded a preset"});
	Comm.addChatMessage({text="/window_save [name] - Saves a preset as [name]"});

	if User.isHost() then
		Comm.addChatMessage({text="GM only commands:"});
		Comm.addChatMessage({text="/window_share [name] - Opens windows in the preset for everyone, sharing windows as needed"});
	end
end

-- ---------------------------------------------------------------
-- listHandler - Tells host to list presets to current user     --
-- ---------------------------------------------------------------
function listHandler(_, page)
	WindowSaveUtility.sendEvent({type="window_list", page=page});
end

-- ---------------------------------------------------------------
-- loadHandler - Closes all windows, then opens a preset        --
-- ---------------------------------------------------------------
function loadHandler(_, name)
	if name == "" then
		Comm.addChatMessage({text="[WSX] Preset name required to load"});
	else
		name = WindowSaveUtility.cleanInput(name);
		WindowSaveUtility.sendEvent({type="window_load", name=name});
	end
end

-- ---------------------------------------------------------------
-- openHandler - Opens a preset without closing any windows     --
-- ---------------------------------------------------------------
function openHandler(_, name)
	if name == "" then
    WindowSaveUtility.sendEvent({type="window_open", name='default'});
	else
		name = WindowSaveUtility.cleanInput(name);
		WindowSaveUtility.sendEvent({type="window_open", name=name});
	end
end

-- ---------------------------------------------------------------
-- restoreHandler - Tells host to list presets to current user  --
-- ---------------------------------------------------------------
function restoreHandler()
	WindowSaveCore.onRestoreAllWindows();
end

-- ---------------------------------------------------------------
-- saveHandler - Tells host to save preset for current user     --
-- ---------------------------------------------------------------
function saveHandler(_, name)
  if name == "" then
		WindowSaveCore.handleSave('default');
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
		WindowSaveUtility.sendEvent({type="window_share", name=name});
	end
end
