

COLOR_HEALTH_UNWOUNDED = "00ff00";
COLOR_HEALTH_LT_WOUNDS = "d5e409";
COLOR_HEALTH_MOD_WOUNDS = "dd8707";
COLOR_HEALTH_HVY_WOUNDS = "e53506";
COLOR_HEALTH_CRIT_WOUNDS = "fc0006";
COLOR_HEALTH_DYING_OR_DEAD = "A04040";

COLOR_HEALTH_SIMPLE_WOUNDED = "40ff00";
COLOR_HEALTH_SIMPLE_BLOODIED = "C11B17";

COLOR_HEALTH_GRADIENT_TOP = { r = 0, g = 200, b = 0 };
COLOR_HEALTH_GRADIENT_MID = { r = 210, g = 112, b = 23 };
COLOR_HEALTH_GRADIENT_BOTTOM = { r = 220, g = 0, b = 0 };

function onInit()
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_UNCONSCIOUS, COLOR_HEALTH_DYING_OR_DEAD);
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_HEALTHY, COLOR_HEALTH_UNWOUNDED);
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_LIGHT, COLOR_HEALTH_LT_WOUNDS);
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_MODERATE, COLOR_HEALTH_MOD_WOUNDS);
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_HEAVY, COLOR_HEALTH_HVY_WOUNDS);
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_CRITICAL, COLOR_HEALTH_CRIT_WOUNDS);
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_DEAD, COLOR_HEALTH_DYING_OR_DEAD);

	ColorManager.getHealthColor = getHealthColor;
  ActorHealthManager.getHealthInfo = getHealthInfo;
--	ColorManager.getTieredHealthColor = getTieredHealthColor;
--	ColorManager.getGradientHealthColorRef = ColorManager.getGradientHealthColor
--	ColorManager.getGradientHealthColor = getGradientHealthColor;
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

function getGradientHealthColor(nPercentWounded)
	local sColor;
	if nPercentWounded >= 1 then
		sColor = COLOR_HEALTH_DYING_OR_DEAD;
	elseif nPercentWounded <= 0 then
		sColor = COLOR_HEALTH_UNWOUNDED;
	else
		local nBarR, nBarG, nBarB;
		if nPercentWounded >= 0.5 then
			local nPercentGrade = (nPercentWounded - 0.5) * 2;
			nBarR = math.floor((COLOR_HEALTH_GRADIENT_BOTTOM.r * nPercentGrade) + (COLOR_HEALTH_GRADIENT_MID.r * (1.0 - nPercentGrade)) + 0.5);
			nBarG = math.floor((COLOR_HEALTH_GRADIENT_BOTTOM.g * nPercentGrade) + (COLOR_HEALTH_GRADIENT_MID.g * (1.0 - nPercentGrade)) + 0.5);
			nBarB = math.floor((COLOR_HEALTH_GRADIENT_BOTTOM.b * nPercentGrade) + (COLOR_HEALTH_GRADIENT_MID.b * (1.0 - nPercentGrade)) + 0.5);
		else
			local nPercentGrade = nPercentWounded * 2;
			nBarR = math.floor((COLOR_HEALTH_GRADIENT_MID.r * nPercentGrade) + (COLOR_HEALTH_GRADIENT_TOP.r * (1.0 - nPercentGrade)) + 0.5);
			nBarG = math.floor((COLOR_HEALTH_GRADIENT_MID.g * nPercentGrade) + (COLOR_HEALTH_GRADIENT_TOP.g * (1.0 - nPercentGrade)) + 0.5);
			nBarB = math.floor((COLOR_HEALTH_GRADIENT_MID.b * nPercentGrade) + (COLOR_HEALTH_GRADIENT_TOP.b * (1.0 - nPercentGrade)) + 0.5);
		end
		sColor = string.format("%02X%02X%02X", nBarR, nBarG, nBarB);
	end
	return sColor;
end

function getHealthColor(nPercentWounded, bBar)
	local sColor;
	if not bBar or OptionsManager.isOption("BARC", "tiered") then
		sColor = getTieredHealthColor(nPercentWounded);
	else
		sColor = getGradientHealthColor(nPercentWounded);
	end
	return sColor;
end

-- Based on the percent wounded, change the font color for the Wounds field
function getHealthInfo(v)
	local nPercentWounded,sStatus = ActorHealthManager.getWoundPercent(v);
	local  sColor = getHealthColor(nPercentWounded, false);

	return nPercentWounded,sStatus,sColor;
end
