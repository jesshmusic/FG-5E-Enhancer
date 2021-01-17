

COLOR_HEALTH_UNWOUNDED = "00ff00";
COLOR_HEALTH_LT_WOUNDS = "d5e409";
COLOR_HEALTH_MOD_WOUNDS = "dd8707";
COLOR_HEALTH_HVY_WOUNDS = "e53506";
COLOR_HEALTH_CRIT_WOUNDS = "fc0006";

function onInit()
	ColorManager.getTieredHealthColor = getTieredHealthColor;
end

function getTieredHealthColor(nPercentWounded)
	local sColor;
	if nPercentWounded >= 1 then
		sColor = COLOR_HEALTH_DYING_OR_DEAD;
	elseif nPercentWounded <= 0 then
		sColor = COLOR_HEALTH_UNWOUNDED;
	elseif OptionsManager.isOption("WNDC", "detailed") then
		if nPercentWounded >= 0.75 then
			sColor = COLOR_HEALTH_CRIT_WOUNDS;
		elseif nPercentWounded >= 0.5 then
			sColor = COLOR_HEALTH_HVY_WOUNDS;
		elseif nPercentWounded >= 0.25 then
			sColor = COLOR_HEALTH_MOD_WOUNDS;
		else
			sColor = COLOR_HEALTH_LT_WOUNDS;
		end
	else
		if nPercentWounded >= 0.5 then
			sColor = COLOR_HEALTH_SIMPLE_BLOODIED;
		else
			sColor = COLOR_HEALTH_SIMPLE_WOUNDED;
		end
	end
	return sColor;
end
