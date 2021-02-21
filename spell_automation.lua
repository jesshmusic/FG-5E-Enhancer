action_list = {}
SkipUsesUpdate = 0
Upcast_Dmg_Heal = 0
action_proceed = false
action_targets = 0
zero_upcast_spells = { "Magic Missile", "Cordon of Arrows", "Crown of Stars", "Flame Arrows", "Enhance Ability", "Heroism", "Animate Objects", "Chain Lightning", "Elemental Bane", "Geas", "Scorching Ray" }
double_upcast_spells = { "Heal", "Bigby’s Hand", "Circle of Death", "Cloud of Daggers", "Color Spray", "Sleep", "Vitriolic Sphere", "Wall of Ice" }
triple_upcast_spells = { "Disintegrate" }
half_upcast_spells = { "Spiritual Weapon", "Flame Blade", "Elemental Weapon" }
half_upcast_roundup_spells = { "Shadow Blade" }
flat_upcast_spells = { "Aid", "Armor of Agathys", "False Life", "Heal" }
single_upcast_spells = { "Spirit", "Word", "Prayer", "Mass" } -- not full list but rather forced exception to previous ones

OOB_MSGTYPE_NEXTACTION = "nextaction";

function subrange(t, first, last)
  local sub = {}
  for i = first, last do
    sub[#sub + 1] = t[i]
  end
  return sub
end


function onInit()
  registerOptions_Spell_Automation()

  OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_NEXTACTION, handleNofifyNextAttack);

  onAttack_old = ActionAttack.onAttack;
  ActionAttack.onAttack = onAttack_override;
  ActionsManager.registerResultHandler("attack", onAttack_override);

  applySave_old = ActionSave.applySave;
  ActionSave.applySave = applySave_override;

  onSave_old = ActionSave.onSave;
  ActionSave.onSave = onSave_override;
  ActionsManager.registerResultHandler("save", onSave_override);

  onDamage_old = ActionDamage.onDamage;
  ActionDamage.onDamage = onDamage_override;
  ActionsManager.registerResultHandler("damage", onDamage_override);

  onHeal_old = ActionHeal.onHeal;
  ActionHeal.onHeal = onHeal_override;
  ActionsManager.registerResultHandler("heal", onHeal_override);

  onEffect_old = ActionEffect.onEffect;
  ActionEffect.onEffect = onEffect_override;
  ActionsManager.registerResultHandler("effect", onEffect_override);

  performAction_old = PowerManager.performAction
  PowerManager.performAction = performAction_override -- disable "Cast message"

  getPCPowerAction_old = PowerManager.getPCPowerAction
  PowerManager.getPCPowerAction = getPCPowerAction_override -- disable "remove symbols"

  actionRoll_old = ActionsManager.actionRoll
  ActionsManager.actionRoll = actionRoll_override
end



function registerOptions_Spell_Automation()
  OptionsManager.registerOption2("SA_DEF_ACT", true, "option_header_client", "option_label_Default_Actions", "option_entry_cycler",
    { labels = "option_label_Default_Actions_9|option_label_Default_Actions_1", values = "9|1", baselabel = "option_label_Default_Actions_0", baseval = "0", default = "9" });

  OptionsManager.registerOption2("SA_DEL_HID", true, "option_header_client", "option_label_Actions_Hide", "option_entry_cycler",
    { labels = "option_label_Actions_Hide_Delayed", values = "true", baselabel = "option_label_Actions_Hide_Instant", baseval = "false", default = "false" });

  OptionsManager.registerOption2("SA_CAS_MES", true, "option_header_client", "option_label_Cast_Message", "option_entry_cycler",
    { labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
end



function actionRoll_override(rSource, vTarget, rRolls)
  if rRolls then
    if #rRolls then
      if rRolls[1].sType ~= "save" then

        if vTarget then
          if #vTarget > 0 then
            if #(vTarget[1]) > 0 then
              action_targets = math.max(#vTarget, #(vTarget[1]))
              action_proceed = false
            end
          end
        end

        if action_targets == 0 then
          action_targets = 1
          action_proceed = false
        end
      end
    end
  end

  actionRoll_old(rSource, vTarget, rRolls)
end



function onAttack_override(rSource, rTarget, rRoll) -- Attack
  onAttack_old(rSource, rTarget, rRoll) -- original function

  Hit = attack_results(rSource, rTarget, rRoll) -- Hit or not

  notifyNextAttack(Hit, rSource) -- Handle next action
end



function onSave_override(rSource, rTarget, rRoll) -- Save (autofail check)
  onSave_old(rSource, rTarget, rRoll) -- original function

  local bAutoFail = rRoll.sDesc:match("%[AUTOFAIL%]"); -- Autofail or not
  if bAutoFail then
    if rRoll.sSource ~= "" then
      local Actor = ActorManager.getActor("ct", rRoll.sSource);
      notifyNextAttack(true, Actor) -- Handle next action
    end
  end
end



function applySave_override(rSource, rOrigin, rAction, sUser) -- Save2
  applySave_old(rSource, rOrigin, rAction, sUser) -- original function

  Hit = save_results(rSource, rOrigin, rAction, sUser) -- Hit or not

  notifyNextAttack(Hit, rOrigin) -- Handle next action
end



function onDamage_override(rSource, rTarget, rRoll) -- Damage
  onDamage_old(rSource, rTarget, rRoll) -- original function

  notifyNextAttack(true, rSource) -- Handle next action
end



function onHeal_override(rSource, rTarget, rRoll) -- Heal
  onHeal_old(rSource, rTarget, rRoll) -- original function

  notifyNextAttack(true, rSource) -- Handle next action
end



function onEffect_override(rSource, rTarget, rRoll) -- Effect
  onEffect_old(rSource, rTarget, rRoll) -- original function

  notifyNextAttack(true, rSource) -- Handle next action
end



function getPCPowerAction_override(nodeAction, sSubRoll)
  rAction, rActor = getPCPowerAction_old(nodeAction, sSubRoll)

  rAction.label = clean_name(rAction.label)

  return rAction, rActor;
end



function performAction_override(draginfo, rActor, rAction, nodePower)
  if not rActor or not rAction then
    return false;
  end

  Upcast_Dmg_Heal = math.floor(Upcast_Dmg_Heal)
  if ((rAction.type == "heal") or (rAction.type == "damage")) and Upcast_Dmg_Heal then
    if rAction.clauses then
      if #rAction.clauses then
        for i = 1, #rAction.clauses do
          if (rAction.clauses[i].dice) and (Upcast_Dmg_Heal > 0) then -- increase number of dice
            for j = 1, Upcast_Dmg_Heal do
              -- add additional dice
              rAction.clauses[i].dice[#rAction.clauses[i].dice + 1] = rAction.clauses[i].dice[#rAction.clauses[i].dice]
            end
          elseif (rAction.clauses[i].modifier) and (Upcast_Dmg_Heal < 0) then -- increase modifier
            rAction.clauses[i].modifier = rAction.clauses[i].modifier - Upcast_Dmg_Heal
          end
        end
      end
    end
  end



  if (rAction.type == "cast") and ((rAction.subtype or "") == "") and (OptionsManager.getOption("SA_CAS_MES") == "off") then
    if rAction.range then
      rAction.subtype = "atk"
    elseif ((rAction.save or "") ~= "") then
      rAction.subtype = "save"
    end
  end

  return performAction_old(draginfo, rActor, rAction, nodePower)
end



function notifyNextAttack(Hit, Actor)
  if not Actor then
    return;
  end

  local msgOOB = {};
  msgOOB.type = OOB_MSGTYPE_NEXTACTION;
  msgOOB.Hit = tostring(Hit)

  if ActorManager.getType(Actor) == "pc" then
    local nodePC = ActorManager.getCreatureNode(Actor);
    if nodePC then
      if User.isHost() then
        Comm.deliverOOBMessage(msgOOB, User.getCurrentIdentity()); --	deliver to GM Server

        local sOwner = DB.getOwner(nodePC);
        if sOwner ~= "" then
          for _, vUser in ipairs(User.getActiveUsers()) do
            if vUser == sOwner then
              for _, vIdentity in ipairs(User.getActiveIdentities(vUser)) do
                if nodePC.getName() == vIdentity then
                  Comm.deliverOOBMessage(msgOOB, sOwner); --	deliver to owner Client
                  return;
                end
              end
            end
          end
        end
      else
        if DB.isOwner(nodePC) then
          handleNofifyNextAttack(msgOOB);
          return;
        end
      end
    end
  end
end



function handleNofifyNextAttack(msgOOB)
  if action_targets > 0 then
    action_targets = action_targets - 1
    if msgOOB.Hit == "true" then
      action_proceed = true
    end
  else
    action_targets = 0
    action_proceed = false
    action_list = {}
    return
  end

  if action_targets ~= 0 then
    return
  end

  if action_proceed then
    if #action_list > 0 then
      act = action_list[1]
      if #action_list > 1 then
        action_list = subrange(action_list, 2, #action_list)
      else
        action_targets = 0
        action_proceed = false
        action_list = {}
      end

      if type(act) == "windowinstance" then
        act.button.action()
      elseif type(act) == "function" then
        act()
      end
    end
  else
    action_targets = 0
    action_proceed = false
    action_list = {}
  end

  if #action_list == 0 then
    Upcast_Dmg_Heal = 0
  end
end



function attack_results(rSource, rTarget, rRoll) -- helper function to get Hit/Miss from Attack

  local rAction = {};
  rAction.nTotal = ActionsManager.total(rRoll);

  local nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus = ActorManager5E.getDefenseValue(rSource, rTarget, rRoll);

  if nAtkEffectsBonus ~= 0 then
    rAction.nTotal = rAction.nTotal + nAtkEffectsBonus;
    local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]"
  end
  if nDefEffectsBonus ~= 0 then
    nDefenseVal = nDefenseVal + nDefEffectsBonus;
    local sFormat = "[" .. Interface.getString("effects_def_tag") .. " %+d]"
  end

  local sCritThreshold = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
  local nCritThreshold = tonumber(sCritThreshold) or 20;
  if nCritThreshold < 2 or nCritThreshold > 20 then
    nCritThreshold = 20;
  end

  rAction.nFirstDie = 0;
  if #(rRoll.aDice) > 0 then
    rAction.nFirstDie = rRoll.aDice[1].result or 0;
  end
  if rAction.nFirstDie >= nCritThreshold then
    rAction.bSpecial = true;
    rAction.sResult = "crit";
  elseif rAction.nFirstDie == 1 then
    rAction.sResult = "fumble";
  elseif nDefenseVal then
    if rAction.nTotal >= nDefenseVal then
      rAction.sResult = "hit";
    else
      rAction.sResult = "miss";
    end
  end

  Hit = false;
  if (rAction.sResult == "hit") or (rAction.sResult == "crit") then
    Hit = true
  end
  return Hit
end



function save_results(rSource, rOrigin, rAction, sUser) -- helper function to get Hit/Half/Save from Savingthrow
  local text = "Save [" .. rAction.nTotal .. "]";
  local sAttack = "";
  local bHalfMatch = false;
  if rAction.sSaveDesc then
    sAttack = rAction.sSaveDesc:match("%[SAVE VS[^]]*%] ([^[]+)") or "";
    bHalfMatch = (rAction.sSaveDesc:match("%[HALF ON SAVE%]") ~= nil);
  end
  sResult = "";

  if rAction.nTarget > 0 then
    if rAction.nTotal >= rAction.nTarget then
      text = text .. " [SUCCESS]";

      if rSource then
        local bHalfDamage = bHalfMatch;
        local bAvoidDamage = false;
        if bHalfDamage then
          if EffectManager5E.hasEffectCondition(rSource, "Avoidance") then
            bAvoidDamage = true;
            text = text .. " [AVOIDANCE]";
          elseif EffectManager5E.hasEffectCondition(rSource, "Evasion") then
            local sSave = rAction.sDesc:match("%[SAVE%] (%w+)");
            if sSave then
              sSave = sSave:lower();
            end
            if sSave == "dexterity" then
              bAvoidDamage = true;
              text = text .. " [EVASION]";
            end
          end
        end

        if bAvoidDamage then
          sResult = "none";
        elseif bHalfDamage then
          sResult = "half_success";
        end
      end
    else
      text = text .. " [FAILURE]";

      if rSource then
        local bHalfDamage = false;
        if bHalfMatch then
          if EffectManager5E.hasEffectCondition(rSource, "Avoidance") then
            bHalfDamage = true;
            text = text .. " [AVOIDANCE]";
          elseif EffectManager5E.hasEffectCondition(rSource, "Evasion") then
            local sSave = rAction.sDesc:match("%[SAVE%] (%w+)");
            if sSave then
              sSave = sSave:lower();
            end
            if sSave == "dexterity" then
              bHalfDamage = true;
              text = text .. " [EVASION]";
            end
          end
        end

        if bHalfDamage then
          sResult = "half_failure";
        end
      end
    end
  end

  Hit = false;
  if string.match(sResult, "half") or string.match(text, "FAILURE") then
    Hit = true
  end
  return Hit
end


function clean_name(spell_name)
  local clean_name = spell_name

  local s_space = string.char(32) -- " "
  local s_quote = string.char(187) -- "»"
  local s_quote2 = string.char(194) .. string.char(187) -- "»" (Unity)
  local s_at = string.char(64) -- "@"
  local s_circle = string.char(226) .. string.char(151) .. string.char(143) -- "●" (Unity)
  local s_dot = string.char(183) -- "·"
  local s_dot2 = string.char(194) .. string.char(183) -- "·" (Unity)


  clean_name = string.gsub(clean_name, s_space .. s_quote2 .. "%d", "") --" »2" (Unity)
  clean_name = string.gsub(clean_name, s_space .. s_quote .. "%d", "") --" »2"
  clean_name = string.gsub(clean_name, s_quote2 .. "%d", "") --"»2" (Unity)
  clean_name = string.gsub(clean_name, s_quote .. "%d", "") --"»2"
  clean_name = string.gsub(clean_name, s_space .. s_quote2, "") --" »" (Unity)
  clean_name = string.gsub(clean_name, s_space .. s_quote, "") --" »"
  clean_name = string.gsub(clean_name, s_quote2, "") --"»" (Unity)
  clean_name = string.gsub(clean_name, s_quote, "") --"»"

  clean_name = string.gsub(clean_name, s_space .. s_at .. "r", "") --" @r"
  clean_name = string.gsub(clean_name, s_at .. "r", "") --"@r"
  clean_name = string.gsub(clean_name, s_space .. s_at .. "R", "") --" @R"
  clean_name = string.gsub(clean_name, s_at .. "R", "") --"@R"
  clean_name = string.gsub(clean_name, s_space .. s_at .. "%d", "") --" @2"
  clean_name = string.gsub(clean_name, s_at .. "%d", "") --"@2"
  clean_name = string.gsub(clean_name, s_space .. s_at, "") --" @"
  clean_name = string.gsub(clean_name, s_at, "") --"@"

  clean_name = string.gsub(clean_name, s_space .. s_circle, "") --" ●" (Unity)
  clean_name = string.gsub(clean_name, s_circle, "") --"●" (Unity)

  clean_name = string.gsub(clean_name, s_space .. s_dot2, "") --" ·" (Unity)
  clean_name = string.gsub(clean_name, s_space .. s_dot, "") --" ·"
  clean_name = string.gsub(clean_name, s_dot2, "") --"·" (Unity)
  clean_name = string.gsub(clean_name, s_dot, "") --"·"

  return clean_name
end



function upcast_factor(name, levels)
  name = string.lower(name)
  local factor = 1

  for i = 1, #zero_upcast_spells do
    if string.match(name, string.lower(zero_upcast_spells[i])) then
      return 0
    end
  end

  for i = 1, #triple_upcast_spells do
    if string.match(name, string.lower(triple_upcast_spells[i])) then
      return 3 * levels
    end
  end

  for i = 1, #half_upcast_spells do
    if string.match(name, string.lower(half_upcast_spells[i])) then
      return 0.5 * levels
    end
  end

  for i = 1, #half_upcast_roundup_spells do
    if string.match(name, string.lower(half_upcast_roundup_spells[i])) then
      return 0.5 * levels + 0.5
    end
  end

  for i = 1, #single_upcast_spells do
    if string.match(name, string.lower(single_upcast_spells[i])) then
      return 1 * levels
    end
  end

  for i = 1, #double_upcast_spells do
    if string.match(name, string.lower(double_upcast_spells[i])) then
      factor = 2
    end
  end

  for i = 1, #flat_upcast_spells do
    if string.match(name, string.lower(flat_upcast_spells[i])) then
      factor = (-5) * factor
    end
  end

  return factor * levels
end


function Upcast_double_click(window)
  if Input.isControlPressed() then

    local bVisible = true
    bVisible = window.contents.subwindow.weapontitle.isVisible();
    if bVisible then
      window.contents.subwindow.weapontitle.setVisible(false);
    else
      window.contents.subwindow.weapontitle.setVisible(true);
    end

    bVisible = window.contents.subwindow.spellslots_cast.subwindow.slotstitle.isVisible();
    if bVisible then
      window.contents.subwindow.spellslots_cast.subwindow.slotstitle.setVisible(false);
    else
      window.contents.subwindow.spellslots_cast.subwindow.slotstitle.setVisible(true);
    end

  else
    local node = window.getDatabaseNode();
    local DelayedHide = OptionsManager.getOption("SA_DEL_HID")

    local str_chat = "Expending Spell Slots Extension:\nNormal - In Combat Mode spells without remaining slots will be hidden immediately (original behavior).";

    if DelayedHide == "false" then
      DelayedHide = "true";
      str_chat = "Expending Spell Slots Extension:\nDelayed - In Combat Mode spells without remaining slots will be hidden only after use of their last action or after next cast.";
    else
      DelayedHide = "false";
    end

    ChatManager.Message(str_chat, false, " ");
    OptionsManager.setOption("SA_DEL_HID", DelayedHide)
  end
end



function Power_counter_click(button, x, y, window, super)
  -- update group visibility beforehand
  window.parentcontrol.window.windowlist.window.onUsesChanged()

  local node = window.getDatabaseNode()
  local node_char = node.getChild("...")
  -- disable group visibility update 1 time
  Spell_Automation.SkipUsesUpdate = 1

  return super.onClickDown(button, x, y)
end
