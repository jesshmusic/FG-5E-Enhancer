--------------------------------------------------------------------------------------------------------
-- Author: Zack (Gkjsdll) Winchell            									  																		--
-- Purpose: Save presets of open windows to be reopened on demand 																		--
-- Credit: Started by modifying Window Saver by James (lokiare1) Holloway 														--
-- Credit: source - https://www.fantasygrounds.com/forums/showthread.php?38389-Window-Saver-Extension --
--------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------
-- Global variables                         			          		--
-- ---------------------------------------------------------------
-- running - Changes behavior of certain functions during shutdown
running = true;
-- local_current_session - Contains local list of open windows
local_current_session = {};
-- local_restore_session - Contains list of windows last closed with closeAllWindows
local_restore_session = nil;

function onInit()
	OOBManager.registerOOBMsgHandler("window_alert",
		function (data)
			local message = {text=data.text};
			Comm.addChatMessage(message);
		end
	);

	OOBManager.registerOOBMsgHandler("window_client_open", openWindow);
	OOBManager.registerOOBMsgHandler("window_client_close_all", closeAllWindows);

	WindowSaveUtility.sendEvent({type="window_init"});

	Interface.onWindowOpened = WindowSaveUtility.mergeFunctions(Interface.onWindowOpened, onWindowOpened);
	Interface.onWindowClosed = WindowSaveUtility.mergeFunctions(Interface.onWindowClosed, onWindowClosed);
	Interface.onDesktopClose = WindowSaveUtility.mergeFunctions(Interface.onDesktopClose, onDesktopClose);

	onRestoreAllWindows();
end

-- ----------------------------------
-- START Interface event handlers  --
-- ------------------------------------
---------------------------------------------------------------
-- restoreHandler - Tells host to list presets to current user  --
-- ---------------------------------------------------------------
function onRestoreAllWindows()
	if local_restore_session == nil then
		closeAllWindows();
		WindowSaveUtility.sendEvent({type="window_restore"});
	else
		local temp_session = local_restore_session;
		local windowCount = 0;

		closeAllWindows();

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
	end
end

-- ------------------------------------------------------------------
-- onWindowOpened - Tells host the current user opened a window    --
-- ------------------------------------------------------------------
function onWindowOpened(window)
	local path = window.getDatabaseNode();
	if path ~= nil then
		path = path.getPath()
	end

	local containerName = WindowSaveUtility.getContainerName(window.getClass(), path);
	local_current_session[containerName] = window;

	saveWindow({
		name="current_session",
		window=window,
		internalUse="yes"
	});
end

-- -------------------------------------------------------------------
-- onWindowClosed - Tells host the current user closed a window     --
-- -------------------------------------------------------------------
function onWindowClosed(window)
	if running then
		local path = window.getDatabaseNode();
		if path ~= nil then path = path.getPath() end

		WindowSaveUtility.sendEvent({
			type="window_window_close",
			class=window.getClass(),
			path=path
		});

		local containerName = WindowSaveUtility.getContainerName(window.getClass(), path);
		local_current_session[containerName] = nil;
	end
end

-- ---------------------------------------------------------------------
-- OnDesktopClose - Prevents current session from being wiped on exit --
-- ---------------------------------------------------------------------
function onDesktopClose()
	running = false;
end


-- ----------------------------------
-- END Interface event handlers    --
-- ----------------------------------

-- ----------------------------------
-- START client main functions     --
-- ----------------------------------

function openWindow(windowData)
	windowData.path = windowData.path or "";
	local window = Interface.openWindow(windowData.class, windowData.path);
	if window then
		window.setSize(windowData.width, windowData.height);
		window.setPosition(windowData.xPos, windowData.yPos);
	end
end

-- ------------------------------------------------------------------------
-- saveWindow - Tells host geometry of a window for a preset             --
-- ------------------------------------------------------------------------
function handleSave(nameText)
	WindowSaveUtility.sendEvent({type="window_clear", name=nameText, suppressAlert="yes", remake="yes"});
	local windowCount = 0;
	for _,window in pairs(local_current_session) do
		local sentData = saveWindow({name=nameText, window=window});
		if sentData ~= nil then
			windowCount = windowCount + 1;
		end
	end
end

function saveWindow(windowData)
	local path = windowData.window.getDatabaseNode();
	if path ~= nil then
		path = path.getPath()
	end

	local class = windowData.window.getClass();

	local window = nil;

	if windowData.window ~= nil then
		window = windowData.window;
	else
		window = Interface.findWindow(class, path);
	end

	local eventData = {
		type="window_window_save",
		name=windowData.name,
		class=class,
		path=path,
		internalUse=windowData.internalUse
	};

	if window ~= nil then
		local width, height = window.getSize();
		local xPos, yPos = window.getPosition();
		eventData.width=width;
		eventData.height=height;
		eventData.xPos=xPos;
		eventData.yPos=yPos;
		WindowSaveUtility.sendEvent(eventData);
		return eventData;
	end
end

-- ------------------------------------------------------------------------
-- closeAllWindows - Closes all windows open on the client               --
-- ------------------------------------------------------------------------
function closeAllWindows()
	local_restore_session = {};
	for containerName,window in pairs(local_current_session) do
		local width, height = window.getSize();
		local xPos, yPos = window.getPosition();

		local class = window.getClass();
		local path = window.getDatabaseNode();
		if path ~= nil then
			path = path.getPath();
		end

		local windowData = {
			width=width,
			height=height,
			xPos=xPos,
			yPos=yPos,
			class=class,
			path=path,
		};

		if path ~= nil and DB.findNode(WindowSaveUtility.decode(path)) == nil then
			windowData.unbound = true;
		end

		local_restore_session[containerName] = windowData;
		window.close();
	end
end

-- ----------------------------------
-- END client main functions       --
-- ----------------------------------
