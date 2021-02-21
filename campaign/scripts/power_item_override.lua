function subrange(t, first, last)
  local sub = {}
  for i=first,last do
    sub[#sub + 1] = t[i]
  end
  return sub
end


-- only this function is fully overriden, rest are unchanged
function usePower(bShowFull)
	Spell_Automation.Upcast_Dmg_Heal = 0 
	local slot_use = ""
	local node = getDatabaseNode()
	local node_char = node.getChild("...")
	local actor = ActorManager.getActor("pc", node_char)
	local spell_name =  DB.getValue(node, "name", "")
	local clean_name = Spell_Automation.clean_name(spell_name)
	
	local s_quote = string.char(187) 											-- "»"
	local s_at = string.char(64) 												-- "@"
	
	
	local spell_level = DB.getValue(node, "level", 0)
	local use_slot = true
	local spell_casts = DB.getValue(node, "cast", 0)
	local casting_time = DB.getValue(node, "castingtime", "")
	local str_chat = ""
	local upcasted = ""
	
	if Input.isControlPressed() then 
		casting_time = ""
	end
	
	if casting_time ~= "" then 
		str_chat = clean_name .. " (" .. casting_time .. ")"
	else
		str_chat = clean_name
	end
	
		
	local actions_list = self.header.subwindow.actionsmini.getWindows()
	
	local upcast_level = DB.getValue(node_char, "upcast_level", 0)
	DB.setValue(node_char, "upcast_level", "number", 0)
	
	if upcast_level == 0 then							-- Handle @ Upcasted / Ritual spells
		local s_match_at = ""
		s_match_at = string.match(string.upper(spell_name), s_at .. "R")  -- "@"
		if s_match_at then		--ritual
			upcast_level = -1
			use_slot = false
		else
			s_match_at = string.match(spell_name, s_at .. "%d")  -- "@"
			if s_match_at then
				upcast_level = tonumber(string.sub(s_match_at,2,2))  --@level
				if upcast_level==0 then
					spell_level = 0
				end
			end
		end
	end
	
	if Input.isAltPressed() then	-- Ritual Override
		if 	upcast_level==-1 then
			upcast_level=0
		else
			upcast_level = -1
		end
	end		
	
	if (upcast_level == -1) and (spell_level ~= 0) then  --cast as ritual
		upcast_level = 0
		use_slot = false
		str_chat = clean_name .. " (" .. casting_time .." +10 minutes; Ritual)"
	end

	if Input.isControlPressed() then 	-- Use No Slots
		use_slot = false
	end

	if spell_casts > 0 then 			-- Daily Power
		use_slot = false
	else 								-- Spell
		-- update group visibility beforehand 
		windowlist.window.onUsesChanged()
	end
	
	if use_slot and (upcast_level ~= 0) and (spell_level ~= 0) and (spell_level > upcast_level) then
		str_chat = "Must be cast using at least level " .. spell_level .. " slot! (" .. clean_name .. ")"
		ChatManager.Message(str_chat, true, actor)
		return
	end
	
	if  (upcast_level >= 1) and (upcast_level <= 9) and (spell_level ~= 0) and (spell_level < upcast_level) then	-- Spell is upcasted
		Spell_Automation.Upcast_Dmg_Heal = Spell_Automation.upcast_factor(clean_name, upcast_level - spell_level)
		spell_level = upcast_level
		upcasted = "upcasted; "
	end
	

	
	if use_slot and (spell_level ~= 0) then
		-- slots
		local spell_used = DB.getValue(node_char, "powermeta.spellslots" .. spell_level .. ".used", 0)
		local spell_max = DB.getValue(node_char, "powermeta.spellslots" .. spell_level .. ".max", 0)
		local pact_used = DB.getValue(node_char, "powermeta.pactmagicslots" .. spell_level .. ".used", 0)
		local pact_max = DB.getValue(node_char, "powermeta.pactmagicslots" .. spell_level .. ".max", 0)	
		
		if casting_time ~= "" then 
			casting_time = casting_time .. "; "
		end
		
		-- spell usage priority pact->spell->none
		slot_use = "none"
		local already_used = 0
		if spell_max > spell_used then
			slot_use = "spellslots"
			str_chat = clean_name .. " (" .. casting_time .. upcasted .. "used spell slot level " .. spell_level .. ")"
			already_used = spell_used
		end
		if pact_max > pact_used then
			slot_use = "pactmagicslots"
			str_chat = clean_name .. " (" .. casting_time .. upcasted .. "used pact slot level" .. spell_level .. ")"
			already_used = pact_used
		end
			
		if slot_use ~= "none" then
			-- disable group visibility update 1 time 
			Spell_Automation.SkipUsesUpdate = 1
			DB.setValue(node_char, "powermeta." .. slot_use .. spell_level .. ".used", "number", already_used+1)
		else
			str_chat = "No level " .. spell_level .. " slots available! (" .. clean_name .. ")"
			ChatManager.Message(str_chat, true, actor)
			return
		end
	end
	
	--Cast Message
	ChatManager.Message(str_chat, true, actor)
	
	--Cast Actions
	if slot_use ~= "none" then
		local s_match = ""
		local a_num = 0
		
		a_num = tonumber(OptionsManager.getOption("SA_DEF_ACT"))
		
		if string.find(spell_name, s_quote) then  -- "»"
			s_match = string.match(spell_name, s_quote .. "%d")
			if s_match then
				a_num = tonumber(string.sub(s_match,2,2))
			else
				a_num = 9
			end
		end
		
		if Input.isShiftPressed() then
			a_num = 0					-- No Actions
		end	
			
		
		a_num = math.min(#actions_list, a_num)
		
		if a_num > 0 then
			if a_num > 1 then 
				Spell_Automation.action_list = subrange(actions_list,2,a_num)	-- schedule actions
			end
			
			actions_list[1].button.action()										-- execude first action
			
			if a_num == #actions_list then
				windowlist.window.onUsesChanged() --update view					-- if all actions update view
			end
		end
	end

end