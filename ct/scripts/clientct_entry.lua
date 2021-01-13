function onInit()
	onFactionChanged();
	onHealthChanged();
end

function onActiveChanged()
	updateDisplay();
end

function onFactionChanged()
	updateHealthDisplay();
	updateDisplay();
end

function onTypeChanged()
	updateHealthDisplay();
end

function onHealthChanged()
	local sColor = ActorManager2.getWoundColor("ct", getDatabaseNode());
	
	wounds.setColor(sColor);
	curhp.setColor(sColor);
	status.setColor(sColor);
end

function updateHealthDisplay()
	Debug.console("MY IMPLEMENTATION client_ct_entry.updateHealthDisplay");
	
	local sOption;
	local sFriendFoe = friendfoe.getStringValue();
	
	Debug.console(sFriendFoe);
	
	if friendfoe.getStringValue() == "friend" then
		sOption = OptionsManager.getOption("SHPC");
	else
		sOption = OptionsManager.getOption("SHNPC");
	end
	
	Debug.console(sOption);

	if sOption == "detailed" then
		hptotal.setVisible(true);
		hptemp.setVisible(true);
		wounds.setVisible(true);
		curhp.setVisible(true);

		status.setVisible(false);
	elseif sOption == "status" then
		hptotal.setVisible(false);
		hptemp.setVisible(false);
		wounds.setVisible(false);
		curhp.setVisible(false);		

		status.setVisible(true);
	else
		hptotal.setVisible(false);
		hptemp.setVisible(false);
		wounds.setVisible(false);
		curhp.setVisible(false);
		
		status.setVisible(false);
	end
end