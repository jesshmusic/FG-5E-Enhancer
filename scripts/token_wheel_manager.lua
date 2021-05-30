--[[
    Script to manage height indicators on tokens.
]]--

function onInit()
  TokenManager.onWheelHelperRef = TokenManager.onWheelHelper;
  TokenManager.onWheelHelper = onWheel;
  Token.onWheel = onWheel;
end


function onWheel(tokenCT, notches)
  if tokenCT == nil then
      return;
  end
  local rotateLock = OptionsManager.getOption('CE_TRA');

  if Input.isShiftPressed() and User.isHost() then
    TokenHeight.updateHeight(tokenCT, notches);
  elseif Input.isControlPressed() then
      -- tokenCT scaling
    TokenManager.onWheelHelperRef(tokenCT, notches);
  elseif rotateLock == 'off' then
    -- tokenCT rotation for all
      tokenCT.setOrientation((tokenCT.getOrientation()+notches)%8);
  elseif Input.isAltPressed() and rotateLock == 'on' then
      -- tokenCT rotation only when Alt pressed
        tokenCT.setOrientation((tokenCT.getOrientation()+notches)%8);
  end

  return true;
end
