local AddOnFolderName = ... ---@type string
local private = select(2, ...); ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
    if dp.cvar and dp.cvar == 'showDungeonEntrancesOnMap' then
        WorldMapFrame:RemoveDataProvider(dp);
    end
end

-- create new one
local WorldDungeonEntranceDataProviderMixin = CreateFromMixins(DungeonEntranceDataProviderMixin);
WorldDungeonEntranceDataProviderMixin:Init('showDungeonEntrancesOnMap');

function WorldDungeonEntranceDataProviderMixin:GetPinTemplate()
    return "WorldDungeonEntrancePinTemplate";
end

function WorldDungeonEntranceDataProviderMixin:RenderDungeons(mapID, parentMapID)
    local mapOverrideInfo = private.mapOverrides[mapID] or {};

    local entranceIgnoreList = {}; -- already handled by the MultiDungeonEntranceDataProvider, skip them here
    for _, pin in ipairs(mapOverrideInfo) do
        for _, childMapId in ipairs(pin.childMapIds) do
            for _, dungeonInfo in next, private.PinLocations:GetInfoForMap(childMapId) do
                entranceIgnoreList[dungeonInfo.journalInstanceID] = true;
            end
        end
    end

    for _, dungeonInfo in next, private.PinLocations:GetInfoForMap(mapID, parentMapID) do
        if not entranceIgnoreList[dungeonInfo.journalInstanceID] then
            local pin = self:GetMap():AcquirePin(self:GetPinTemplate(), dungeonInfo)
            pin.dataProvider = self;
            pin:UpdateSupertrackedHighlight();
        end
    end
end

function WorldDungeonEntranceDataProviderMixin:OnSuperTrackingChanged()
    for pin in self:GetMap():EnumeratePinsByTemplate(self:GetPinTemplate()) do
        pin:UpdateSupertrackedHighlight();
    end
end

function WorldDungeonEntranceDataProviderMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function WorldDungeonEntranceDataProviderMixin:RefreshAllData()
    xpcall(function() -- by default, errors from dataproviders are silenced
        self:RemoveAllData();
        if not self:IsCVarSet() then
            return;
        end

        local mapID = self:GetMap():GetMapID();
        local mapInfo = private.GetMapInfo(mapID);
        if mapInfo.mapType == Enum.UIMapType.Continent then
            for _, childInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
                self:RenderDungeons(childInfo.mapID, mapID);
            end
        else
            self:RenderDungeons(mapID);
        end
    end, geterrorhandler());
end

-- Create new dungeon entrance pin mixin
WorldDungeonEntrancePinMixin = CreateFromMixins(DungeonEntrancePinMixin)

function WorldDungeonEntrancePinMixin:UpdateMousePropagation() end
function WorldDungeonEntrancePinMixin:DoesMapTypeAllowSuperTrack() return true; end

function WorldDungeonEntrancePinMixin:OnMouseClickAction(button)
    if button == "RightButton" and TomTom and IsAltKeyDown() then
        TomTom:AddWaypoint(self.poiInfo.zonePosition.mapID, self.poiInfo.zonePosition.position.x, self.poiInfo.zonePosition.position.y, {
            title = self.name,
            from = AddOnFolderName,
            persistent = nil,
            minimap = true,
            world = true
        })

        return
    else
        SuperTrackablePinMixin.OnMouseClickAction(self, button);
    end

    if button == "RightButton" then
        EncounterJournal_LoadUI();
        EncounterJournal_OpenJournal(nil, self.journalInstanceID);
    end
end

function WorldDungeonEntrancePinMixin:CheckShowTooltip()
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
            private.teleportButton:SetParentAndSpell(self, spellID);
            local isAvailable = not cooldownDuration and not InCombatLockdown();
            if isAvailable then
                GameTooltip_AddInstructionLine(tooltip, L["SHIFT_CLICK_TELEPORT_DUNGEON"], false);
            else
                GameTooltip_AddDisabledLine(tooltip, L["SHIFT_CLICK_TELEPORT_DUNGEON"], false);
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

        if TomTom then
            GameTooltip_AddInstructionLine(tooltip, L["ALT_RIGHT_CLICK_TOMTOM_WAYPOINT"], false);
        end

        tooltip:Show();
    end
end

WorldMapFrame:AddDataProvider(WorldDungeonEntranceDataProviderMixin)
