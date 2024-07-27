local private = select(2, ...) ---@class PrivateNamespace

-- Create new dungeon entrance pin mixin
WDEDungeonEntrancePinMixin = CreateFromMixins(DungeonEntrancePinMixin)

function WDEDungeonEntrancePinMixin:UpdateMousePropagation()
    if not InCombatLockdown() then
        self:SetPropagateMouseClicks(not self:DoesMapTypeAllowSuperTrack());
    end
end

function WDEDungeonEntrancePinMixin:CheckShowTooltip()
	if self:UseTooltip() then
        local instanceId = select(10, EJ_GetInstanceInfo(self.journalInstanceID))

		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		local name, description = self:GetBestNameAndDescription();
		GameTooltip_SetTitle(tooltip, name);

		if description then
			GameTooltip_AddNormalLine(tooltip, description);
		end

        if private.savedInstances[instanceId] ~= nil then
            for key, value in pairs(private.savedInstances[instanceId]) do
                tooltip:AddDoubleLine("|cffffffee" .. key .. "|r", value)
            end
        end

		local instructionLine = self:GetTooltipInstructions();
		if instructionLine then
			GameTooltip_AddInstructionLine(tooltip, instructionLine, false);
		end

		tooltip:Show();
	end
end
