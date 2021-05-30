-- functions that are overridden in the CoreRPG Ruleset, from manager_token.lua file
-- horizontal health bar calls
-- token faction underlay drawing

function onInit()
  TokenManager.updateHealthHelperRef = TokenManager.updateHealthHelper;
  TokenManager.updateHealthHelper = updateHealthHelper;
end

function updateHealthHelper(tokenCT, nodeCT)
  local sOptTH;
  if User.isHost() then
    sOptTH = OptionsManager.getOption("TGMH");
  elseif DB.getValue(nodeCT, "friendfoe", "") == "friend" then
    sOptTH = OptionsManager.getOption("TPCH");
  else
    sOptTH = OptionsManager.getOption("TNPCH");
  end
  local aWidgets = TokenManager.getWidgetList(tokenCT, "health");
  if sOptTH == "off" then
    for _,vWidget in pairs(aWidgets) do
      vWidget.destroy();
    end
  else
    local nPercentWounded, sStatus, sColor = ActorHealthManager.getHealthInfo(nodeCT);

    -- START Manage actor token condition widget if enabled
    if OptionsManager.getOption('CE_HCW') ~= "option_off" then
      Debug.chat(sStatus);
      ActorCondition.updateHealthCondition(tokenCT, nPercentWounded, sStatus);
    end
    -- END Manage actor token condition widget if enabled

    if sOptTH == "bar" or sOptTH == "barhover" then
      local widgetHealthBar = aWidgets["healthbar"];
      if OptionsManager.getOption('CE_HHB') ~= "option_off" then
        if not widgetHealthBar then
          HealthGraphicUpdater.drawHorizontalHealthBar(tokenCT, nil, sOptTH == "bar")
        end
        if widgetHealthBar then
          HealthGraphicUpdater.drawHorizontalHealthBar(tokenCT, widgetHealthBar, sOptTH == "bar")
        end
        -- END Draw horizontal health bar if menu option set
      end
    else
      TokenManager.updateHealthHelperRef(tokenCT, nodeCT);
    end
  end
end
