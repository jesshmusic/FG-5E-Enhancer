--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onAttackChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	local nMod = CharWeaponManager.getAttackBonus(nodeChar, nodeWeapon);

	attackview.setValue(nMod);
end

function onAttackAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	-- Build basic attack action record
	local rAction = CharWeaponManager.buildAttackAction(nodeChar, nodeWeapon);

	-- Decrement ammo
	CharWeaponManager.decrementAmmo(nodeChar, nodeWeapon);

	-- Perform action
	local rActor = ActorManager.getActor("pc", nodeChar);

	-- add itemPath to rActor so that when effects are checked we can
	-- make compare against action only effects
	local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
	rActor.itemPath = sRecord;
	-- end Adanced Effects Piece ---

	ActionAttack.performRoll(draginfo, rActor, rAction);
	return true;
end

function onDamageChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	local sDamage = CharWeaponManager.buildDamageString(nodeChar, nodeWeapon);

	damageview.setValue(sDamage);
end

function onDamageAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	-- Build basic damage action record
	local rAction = CharWeaponManager.buildDamageAction(nodeChar, nodeWeapon);

	-- Perform damage action
	local rActor = ActorManager.getActor("pc", nodeChar);

	-- add itemPath to rActor so that when effects are checked we can
	-- make compare against action only effects
	local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
	rActor.itemPath = sRecord;
	-- end Adanced Effects Piece ---

	ActionDamage.performRoll(draginfo, rActor, rAction);
	return true;

end

