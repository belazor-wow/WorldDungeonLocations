local private = select(2, ...) ---@class PrivateNamespace

--- @return WDL_TeleportButton
local function createAndInitTeleportButton()
    --- @class WDL_TeleportButton: Button
    local teleportButton = CreateFrame('Button', nil, UIParent, 'InsecureActionButtonTemplate')
    teleportButton:Hide()
    teleportButton:SetFrameLevel(9999) -- make sure we render high
    teleportButton:SetAttribute('pressAndHoldAction', '1'); -- ensure it casts on down, regardless of the ActionButtonUseKeyDown cvar
    teleportButton:RegisterForClicks('AnyDown');
    teleportButton:SetAttribute('type', 'spell');

    teleportButton:SetScript('OnEnter', function(self, ...)
        if self.currentParent then self.currentParent:GetScript('OnEnter')(self.currentParent, ...) end
    end);
    teleportButton:SetScript('OnLeave', function(self, ...)
        if self.currentParent then self.currentParent:GetScript('OnLeave')(self.currentParent, ...) end
    end);

    teleportButton:RegisterEvent('MODIFIER_STATE_CHANGED');
    teleportButton:RegisterEvent('PLAYER_REGEN_DISABLED');
    teleportButton:RegisterEvent('PLAYER_REGEN_ENABLED');
    teleportButton:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end);
    function teleportButton:MODIFIER_STATE_CHANGED()
        if self.currentSpell and not InCombatLockdown() then
            if IsShiftKeyDown() and not self:IsShown() then
                self:SetAttribute('spell', self.currentSpell);
                self:SetParent(self.currentParent);
                self:SetAllPoints(self.currentParent);
                self:Show();
            elseif not IsShiftKeyDown() then
                self:Hide();
            end
        end
    end
    function teleportButton:PLAYER_REGEN_DISABLED()
        self:Hide();
    end
    function teleportButton:PLAYER_REGEN_ENABLED()
        self:MODIFIER_STATE_CHANGED();
    end

    function teleportButton:SetParentAndSpell(parent, spellID)
        self.currentParent = parent;
        self.currentSpell = spellID;
        self:MODIFIER_STATE_CHANGED();
    end

    return teleportButton;
end
-- Create a shared teleport button
local teleportButton = createAndInitTeleportButton();

-- Create new dungeon entrance pin mixin
WDLDungeonEntrancePinMixin = CreateFromMixins(DungeonEntrancePinMixin);

function WDLDungeonEntrancePinMixin:UpdateMousePropagation() end

function WDLDungeonEntrancePinMixin:DoesMapTypeAllowSuperTrack()
    return true;
end

local teleportInstructionText = '<' .. StripHyperlinks(WARDROBE_SHORTCUTS_TUTORIAL_2):gsub('[[%]]', '') .. ': ' .. TELEPORT_TO_DUNGEON .. '>';

function WDLDungeonEntrancePinMixin:CheckShowTooltip()
    if self:UseTooltip() then
        local instanceId = select(10, EJ_GetInstanceInfo(self.journalInstanceID));

        local tooltip = GetAppropriateTooltip();
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        local name, description = self:GetBestNameAndDescription();
        GameTooltip_SetTitle(tooltip, name);

        if self.poiInfo and self.poiInfo.faction and self.poiInfo.faction ~= UnitFactionGroup('player') then
            local localizedFaction = self.poiInfo.faction == 'Alliance' and FACTION_ALLIANCE or FACTION_HORDE;
            GameTooltip_AddColoredLine(tooltip, FACTION_CONTROLLED_TERRITORY:format(localizedFaction), RED_FONT_COLOR);
        end

        if description then
            GameTooltip_AddNormalLine(tooltip, description);
        end

        if private.savedInstances[instanceId] ~= nil then
            for key, value in pairs(private.savedInstances[instanceId]) do
                tooltip:AddDoubleLine("|cffffffee" .. key .. "|r", value);
            end
        end

        local instructionLine = self:GetTooltipInstructions();
        if instructionLine then
            GameTooltip_AddInstructionLine(tooltip, instructionLine, false);
        end
        local spellID, cooldownDuration, isKnown = private.TeleportMap:GetByJournalInstanceID(self.journalInstanceID);
        if isKnown then
            teleportButton:SetParentAndSpell(self, spellID);
            local isAvailable = not cooldownDuration and not InCombatLockdown();
            if isAvailable then
                GameTooltip_AddInstructionLine(tooltip, teleportInstructionText, false);
            else
                GameTooltip_AddDisabledLine(tooltip, teleportInstructionText, false);
            end
            if cooldownDuration then
                local minutes = (cooldownDuration / 60) % 60;
                local hours = math.floor(cooldownDuration / 60 / 60);
                GameTooltip_AddColoredLine(tooltip, ITEM_COOLDOWN_TIME:format(
                    (hours and INT_GENERAL_DURATION_HOURS:format(hours) or '')
                    .. ' ' .. INT_GENERAL_DURATION_MIN:format(minutes)
                ), RED_FONT_COLOR, false);
            end
            if InCombatLockdown() then
                GameTooltip_AddColoredLine(tooltip, ERR_NOT_IN_COMBAT, RED_FONT_COLOR, false);
            end
        end

        tooltip:Show();
    end
end
