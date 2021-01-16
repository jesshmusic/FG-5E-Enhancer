
--accepts extension name and the latest update log for that extension. 
--Checks for an JHCheck version value in DB for this extensions, if no present, or if its lower than the version on the actual extension file that is loaded, then consideres this a first time update of the extnsion. Writes the new value into the JH check DB and pops up an update log


function updateCheck(sExtensionName,textChangeLog)

	tExts=Extension.getExtensions();
	fileName=nil;
	
	while #tExts>0 do
	
		extName=table.remove(tExts,1);
		if extName:match(sExtensionName) then
			fileName=extName;
		end
	
	end

	--requires the ext file name to match the extension name in the ext file or it wont work right
	if not Extension.getExtensionInfo(fileName) then
		--Debug.chat("The ext file name in your extension folder for " .. sExtensionName .. "has been changed. This may cause issues.")
	else
		currentExtInfo = Extension.getExtensionInfo(fileName);
		sCurrentVersion = currentExtInfo.version;					
		sOldVersion = tostring(DB.getValue("JHChecks." .. sExtensionName .. ".version"));	
		
		--Debug.chat("sOldVersion= ",sOldVersion)
		--Debug.chat("sCurrent Version= ",sCurrentVersion)
		
		--Debug.chat(sOldVersion==nil)
		
		if sOldVersion==nil or sOldVersion=="nil" then		
				--Debug.chat("-------------------sOldVersion was found to be nil")
				DB.setValue("JHChecks." .. sExtensionName .. ".version","string",sCurrentVersion);
				DB.setValue("JHChecks." .. sExtensionName .. ".log","formattedtext",textChangeLog);
				displayChangeLog(sExtensionName);
		elseif compareVersions(sOldVersion,sCurrentVersion)=="2" then	
				DB.setValue("JHChecks." .. sExtensionName .. ".version","string",nCurrentVersion);
				DB.setValue("JHChecks." .. sExtensionName .. ".log","formattedtext",textChangeLog);
				displayChangeLog(sExtensionName);				
		else	
		end
			
			
	end
end

function displayChangeLog(sExtensionName)
	Interface.openWindow("change_log_JH",DB.findNode("JHChecks." .. sExtensionName));
end


function test()
	 
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is ".. compareVersions(1,4))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("Blue","Red"))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("213","1.2"))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("1.256","4.243"))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("5.2","14.32"))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("10.5.23","10.05.23"))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("1.23.415","1.23.416"))
	--Debug.chat("XXXXXXXXXXXXXXXXXXXXXXXXXXX Result is "..compareVersions("1.24.415","1.23.416"))

end



-- returns 0 if equal, 1 if version 1 greater, 2 if 2 greater or 3 if it cant tell because of bad arguements
function compareVersions (sVersion1,sVersion2)

	sVersion1=tostring(sVersion1);
		--Debug.chat ("sVersion1 =",sVersion1) 
	
	sVersion2=tostring(sVersion2);
		--Debug.chat ("sVersion2 =",sVersion2) 
	
	
	tVersion1=splitVersion(sVersion1);
		--Debug.chat ("tVersion1 =",tVersion1) 
	
	tVersion2=splitVersion(sVersion2);
		--Debug.chat ("tVersion2 =",tVersion2) 
	
	-- loop until result
	
	while (#tVersion1>#tVersion2) do
		table.insert (tVersion2,"0")
	end
	
	while (#tVersion2>#tVersion1) do
		table.insert (tVersion1,"0")
	end
		
	--Debug.chat ("tVersion1 =",tVersion1) 
	--Debug.chat ("tVersion2 =",tVersion2) 
	
	while(#tVersion1>0) do
	
		seg1=table.remove(tVersion1,1);
		--Debug.chat ("seg1 =", seg1) 
			
		seg2=table.remove(tVersion2,1);
		--Debug.chat ("seg2 =", seg2) 
				
		if not tonumber(seg1) or not tonumber(seg2) then	
			return "3";
		else		
			if tonumber(seg1)>tonumber(seg2) then
				result ="1";
				return result;
			elseif tonumber(seg2)>tonumber(seg1) then
				result="2";
				return result;
			else 
				result="0";
			end	
		end
	end
	  
	return result;
		
end


function segmentValueDEPRECIATED(seg)
		power=1;
		value=0;
			
	i=string.len(seg);
	
	while (i>0) do
		--Debug.chat("seg Val , i =",i)
		--Debug.chat("seg Val , seg =",seg)
		x = tonumber(string.sub(seg, i, 1));
		--Debug.chat("seg Val , x =",x)
		
		value=value+x*power;
		power=power*10;
		i=i-1;
	end
	
	return value;

end


function splitVersion (sVersion,sep)
        if sep == nil then
                sep = "%."
        end
		
        local t={}
        for str in string.gmatch(sVersion, "([^"..sep.."]+)") do
                table.insert(t, str);
        end
		
        return t;
end
