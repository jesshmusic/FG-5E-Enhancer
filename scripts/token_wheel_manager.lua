--[[
    Script to manage height indicators on tokens.
]]--

function onInit()
  Token.onWheelHelper = onWheel;
end


function onWheel(token, notches)
  if token == nil then
      return;
  end
  local rotateLock = OptionsManager.getOption('CE_TRA');

    if Input.isShiftPressed() and User.isHost() then
        TokenHeight.updateHeight(token, notches);
    elseif Input.isControlPressed() then
        -- token scaling
        Token.onWheelHelper(token, notches);
    elseif rotateLock == 'off' then
      -- token rotation for all
        token.setOrientation((token.getOrientation()+notches)%8);
  elseif Input.isAltPressed() and rotateLock == 'on' then
      -- token rotation only when Alt pressed
        token.setOrientation((token.getOrientation()+notches)%8);
  end

  return true;
end
