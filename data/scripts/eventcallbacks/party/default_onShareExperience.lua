local event = Event()

function event.onShareExperience(party, exp, rawExp)
	local sharedExperienceMultiplier = 1.20 -- 20%
	local vocationsIds = {}

	local vocationId = party:getLeader():getVocation():getBase():getId()
	if vocationId ~= VOCATION_NONE then vocationsIds[1] = vocationId end

	for _, member in ipairs(party:getMembers()) do
		vocationId = member:getVocation():getBase():getId()
		if not table.contains(vocationsIds, vocationId) and vocationId ~=
			VOCATION_NONE then vocationsIds[#vocationsIds + 1] = vocationId end
	end

	local size = #vocationsIds
	if size > 1 then
		sharedExperienceMultiplier = 1.0 + ((size * (5 * (size - 1) + 10)) / 100)
	end

	exp = math.ceil((exp * sharedExperienceMultiplier) / (#party:getMembers() + 1))
	return exp
end

event:register()
