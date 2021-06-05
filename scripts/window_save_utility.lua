-- ------------------------------------------------------------------
-- AlertClient - Used to display messages in client chat from host --
-- ------------------------------------------------------------------
function alertClient(message, recipient)
	sendEvent({
		type="window_alert",
		text=message,
		recipient=recipient
	});
end

-- ---------------------------------------------------------------
-- SendEvent - Used to send messages between client and host		--
-- ---------------------------------------------------------------
function sendEvent(data, recipient)
	data.username = User.getUsername();
	if User.isHost() and data.recipient == data.username then
		-- Host does not receive its own delivered OOB messages, handle manually
		OOBManager.processOOBMessage(data);
	else
		Comm.deliverOOBMessage(data, data.recipient);
	end
end

-- ---------------------------------------------------------------
-- encode - Encodes node path to disable automatic nesting      --
-- ---------------------------------------------------------------
function encode(path)
	local encodedPath = path;
	encodedPath = encodedPath:gsub("%@", "__at__");
	encodedPath = encodedPath:gsub("%.", "__dot__");
	encodedPath = encodedPath:gsub("%&", "__and__");
	encodedPath = encodedPath:gsub("%:", "__colon__");
	encodedPath = encodedPath:gsub("%s", "__space__");
	encodedPath = "_"..encodedPath;
	return encodedPath;
end

-- ---------------------------------------------------------------
-- decode - Decodes node path to enable automatic nesting       --
-- ---------------------------------------------------------------
function decode(path)
	local decodedPath = path:sub(2);
	decodedPath = decodedPath:gsub("__at__", "%@");
	decodedPath = decodedPath:gsub("__dot__", "%.");
	decodedPath = decodedPath:gsub("__and__", "%&");
	decodedPath = decodedPath:gsub("__colon__", "%:");
	decodedPath = decodedPath:gsub("__space__", " ");
	return decodedPath;
end

-- -----------------------------------------------------------------
-- getContainerName - Provides container name from class and path --
-- -----------------------------------------------------------------
function getContainerName(class, path)
	local containerName = class;
	if path ~= nil and path ~= "" then
		containerName = containerName.."."..path;
	end
	return encode(containerName);
end

-- ------------------------------------------------------------------------------------------
-- mergeFunctions - Merges functions to be called at the same time with the same arguments --
-- ------------------------------------------------------------------------------------------
function mergeFunctions(...)
	local handlers = arg;
	function mapFunctions(...)
		for _,handler in pairs(handlers) do
			if type(handler) == "function" then
				handler(unpack(arg));
			end
		end
	end

	return mapFunctions;
end

-- --------------------------------------------------------------
-- getTableSize - Returns the number entries in a table        --
-- --------------------------------------------------------------
function getTableSize(T)
	if type(T) ~= "table" then
		error("getTableSize was given a non-table");
	else
		local size = 0;
		for _ in pairs(T) do
	    size = size + 1;
	    end
    return size;
	end
end

-- ---------------------------------------------------------------
-- cleanInput - Removes unpermitted characters from user input  --
-- ---------------------------------------------------------------
function cleanInput(input)
	local output = input:gsub("[^%w@&:%s%.-]", "");
	output = output:gsub("%s+$", "");
	return output;
end

-- --------------------------------------------------------------
-- doNothing - Does nothing                                    --
-- --------------------------------------------------------------
function doNothing() end
