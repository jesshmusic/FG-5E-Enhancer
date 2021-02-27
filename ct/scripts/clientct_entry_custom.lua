function onInit()
	super.onInit();
	onHealthChanged();
end

function onFactionChanged()
	super.onInit();
	updateHealthDisplay();
end

function onHealthChanged()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local nPercentWounded, sStatus, sColor = ColorManagerCustom.getHealthInfo(rActor);
	Debug.console('JH onHealthChanged', rActor);

	if not wounds then
		return;
	end

	wounds.setColor(sColor);
	curhp.setColor(sColor);
	status.setColor(sColor);
end

function updateHealthDisplay()
	local sOption;

	Debug.console('JH updateHealthDisplay', friendfoe, hptotal);

  if not hptotal then
		return;
	end

	if not friendfoe then
		return;
	end

	Debug.console('JH updateHealthDisplay called for a ', friendfoe.getStringValue());

	if friendfoe.getStringValue() == "friend" then
		sOption = OptionsManager.getOption("SHPC");
	else
		sOption = OptionsManager.getOption("SHNPC");
	end

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
