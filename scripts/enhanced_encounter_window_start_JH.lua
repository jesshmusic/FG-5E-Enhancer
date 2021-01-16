function onInit()
	aRecords = LibraryData.getRecordTypes();
	for kRecordType,vRecordType in pairs(aRecords) do
        if vRecordType == "battle" then
            LibraryData.addIndexButton(vRecordType, "button_new_encounter");
        end
    end
end