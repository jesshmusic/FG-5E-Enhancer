-- overriding 5E Ruleset manager_action_save.lua: applySave function to draw save result graphics on tokens, after saving throw has been thrown
-- addSaveWidget, deleteSaveWidgets handle functionality to do so

function onInit()
	ActionSave.applySaveHelper = ActionSave.applySave;
	ActionSave.applySave = applySave;

	-- add watchers for DB entry for save
	DB.addHandler("combattracker.list.*.savingthrowresult", "onUpdate", dbWatcher);
end

function dbWatcher(node)
	local sSave = node.getValue();
	local ctNode = DB.getParent(node);
	addSaveWidget(ctNode, sSave);
end

function applySave(rSource, rOrigin, rAction, sUser)
	ActionSave.applySaveHelper(rSource, rOrigin, rAction, sUser);

	-- Override section: Draw save result bitmap widget on top of token
	if OptionsManager.getOption("CE_STG") == "on" then
		checkSave(rSource, rAction);
	end
end


-- Check save results, call for bitmap widget draw
function checkSave(rSource, rAction)
	-- Create DB entry for save
	local ctNodePath = rSource.sCTNode;
	local ctNode = DB.findNode(ctNodePath);
	local dbNode = DB.getChild(ctNode, "savingthrowresult");

	if (dbNode == nil) then
		dbNode = ctNode.createChild("savingthrowresult", "string");
	end

	if rAction.nTotal >= rAction.nTarget then
		-- success
		dbNode.setValue('SUCCESS');
	else
		-- failure
		dbNode.setValue('FAILURE');
	end
end



-- Draw save result bitmap widget on top of token
function addSaveWidget(ctNode, sSuccess)
	Debug.console('JH ctNode', ctNode);
	Debug.console('JH tokenCT', CombatManager.getTokenFromCT(ctNode))
	local tokenCT = CombatManager.getTokenFromCT(ctNode);
	if tokenCT then
		local saveIconName = '';

		if sSuccess == 'SUCCESS' then
			saveIconName = 'save_success_d20';
		else
			saveIconName = 'save_fail_d20';
		end

		-- start by deleting any other instances of a save bitmap widget on token before adding a new one if any
		local saveWidget = tokenCT.findWidget("save");

		-- if saveWidget then
		-- 	saveWidget.destroy();
		-- end

		-- add new bitmap save widget
		saveWidget = tokenCT.addBitmapWidget(saveIconName);
		saveWidget.setName("save");
		saveWidget.setPosition("topleft");
		saveWidget.bringToFront();
		Helper.resizeForTokenSize(tokenCT, saveWidget, 0.25);
		saveWidget.setVisible(true);
	end
end


-- capture chat macro command '/dsave'
-- delete all bitmap widgets with 'save' name
function deleteSaveWidgets(sCommand, sParams)
	-- get CT entries for loop
	local aEntries = CombatManager.getSortedCombatantList();

	-- iterate through whole CT
	if #aEntries > 0 then
		local nIndexActive = 0;
		for i = nIndexActive + 1, #aEntries do
			local node = aEntries[i];

			-- delete if db entry
			local dbSaveEntry = DB.getChild(node, "savingthrowresult");
			if dbSaveEntry then
				DB.deleteNode(dbSaveEntry);
			end

			local token = CombatManager.getTokenFromCT(node);
			if token ~= nil then
				-- delete individual save bitmap widget if found for that token
				local aWidgets = TokenManager.getWidgetList(token, "");
				local widgetSaves = token.findWidget("save");

				if widgetSaves then
					widgetSaves.destroy();
				end
			end

			nIndexActive = nIndexActive + 1;
		end
	end

	Helper.postChatMessage('/dsave: Save cleared.');
end
