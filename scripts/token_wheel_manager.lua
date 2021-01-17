--[[
    Script to manage height indicators on tokens.
]]--

function onInit()
  Token.onWheelHelper = Token.onWheel;
  Token.onWheel = onWheel;
end


function onWheel(token, notches)
  if token == nil then
      return;
  end
  local rotateLock = OptionsManager.getOption('CE_TRA');
  if rotateLock == 'off' then
      -- token rotation for all
    Token.onWheelHelper(token, notches);
  elseif Input.isAltPressed() and rotateLock == 'on' then
      -- token rotation only when Alt pressed
    Token.onWheelHelper(token, notches);
  end

  return true;
end
