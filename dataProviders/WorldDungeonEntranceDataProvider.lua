local private = select(2, ...) ---@class PrivateNamespace

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
    if dp.cvar and dp.cvar == 'showDungeonEntrancesOnMap' then
        WorldMapFrame:RemoveDataProvider(dp)
    end
end

-- create new one
local WorldDungeonEntranceDataProviderMixin = CreateFromMixins(DungeonEntranceDataProviderMixin)
WorldDungeonEntranceDataProviderMixin:Init('showDungeonEntrancesOnMap')

function WorldDungeonEntranceDataProviderMixin:GetPinTemplate()
	return "WorldDungeonEntrancePinTemplate";
end

function WorldDungeonEntranceDataProviderMixin:RenderDungeons(mapID, parentMapID)
    for _, dungeonInfo in next, C_EncounterJournal.GetDungeonEntrancesForMap(mapID) do
        if parentMapID then
            -- translate map positions
            local continentID, worldPos = C_Map.GetWorldPosFromMapPos(mapID, dungeonInfo.position)
            _, dungeonInfo.position = C_Map.GetMapPosFromWorldPos(continentID, worldPos, parentMapID)
        end

        local pin = self:GetMap():AcquirePin(self:GetPinTemplate(), dungeonInfo)
        pin.dataProvider = self
        pin:UpdateSupertrackedHighlight()
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
    self:RemoveAllData()
    if not self:IsCVarSet() then
        return
    end

    local mapID = self:GetMap():GetMapID()
    local mapInfo = C_Map.GetMapInfo(mapID)
    if mapInfo.mapType == Enum.UIMapType.Continent then
        for _, childInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
            self:RenderDungeons(childInfo.mapID, mapID)
        end
    else
        self:RenderDungeons(mapID)
    end
end

-- Create new dungeon entrance pin mixin
WorldDungeonEntrancePinMixin = CreateFromMixins(DungeonEntrancePinMixin)

--[[
function WorldDungeonEntrancePinMixin:UpdateMousePropagation()
    if not InCombatLockdown() then
        self:SetPropagateMouseClicks(not self:DoesMapTypeAllowSuperTrack());
    end
end
]]

function WorldDungeonEntrancePinMixin:UpdateMousePropagation() end
function WorldDungeonEntrancePinMixin:DoesMapTypeAllowSuperTrack() return true; end

function WorldDungeonEntrancePinMixin:CheckShowTooltip()
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

WorldMapFrame:AddDataProvider(WorldDungeonEntranceDataProviderMixin)
