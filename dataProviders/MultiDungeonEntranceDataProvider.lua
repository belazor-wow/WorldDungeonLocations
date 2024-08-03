local private = select(2, ...) ---@class PrivateNamespace

local WDLMultiDungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
WDLMultiDungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap");

function WDLMultiDungeonEntranceDataProviderMixin:GetPinTemplate()
    return "WDLMultiDungeonEntrancePinTemplate";
end

function WDLMultiDungeonEntranceDataProviderMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function WDLMultiDungeonEntranceDataProviderMixin:RefreshAllData(fromOnShow)
    self:RemoveAllData();

    if not self:IsCVarSet() then
        return;
    end

    local map = self:GetMap();
    local mapID = map:GetMapID();
    local mapOverrideInfo = private.mapOverrides[mapID] or {}
    local combinedEntranceInfo = {}

    for _, childMapId in ipairs(mapOverrideInfo.childMapIds) do
        local dungeonEntrances = C_EncounterJournal.GetDungeonEntrancesForMap(childMapId);

        for _, dungeonEntranceInfo in ipairs(dungeonEntrances) do
            table.insert(combinedEntranceInfo, dungeonEntranceInfo);
        end
    end

    local mapName = C_Map.GetMapInfo(mapID).name

    if #combinedEntranceInfo then
        local poiInfo = {
            atlasName = "Raid",
            name = mapName,
            description = "Test",
            isAlwaysOnFlightmap = false,
            shouldGlow = false,
            isPrimaryMapForPOI = true,
            position = CreateVector2D(mapOverrideInfo.position.x, mapOverrideInfo.position.y),
            dataProvider = WDLMultiDungeonEntranceDataProviderMixin
        };

        map:AcquirePin(self:GetPinTemplate(), poiInfo, combinedEntranceInfo, mapOverrideInfo);
    end
end

--[[ Pin ]]--
WDLMultiDungeonEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");    --PIN_FRAME_LEVEL_WORLD_QUEST, PIN_FRAME_LEVEL_VIGNETTE

function WDLMultiDungeonEntrancePinMixin:OnLoad()
    BaseMapPoiPinMixin.OnLoad(self);

    self:SetNudgeSourceRadius(1);
    self:SetNudgeSourceMagnitude(2, 2);
end

function WDLMultiDungeonEntrancePinMixin:OnMouseLeave()
    BaseMapPoiPinMixin.OnMouseLeave(self);
end

function WDLMultiDungeonEntrancePinMixin:OnMouseEnter()
    BaseMapPoiPinMixin.OnMouseEnter(self);
end

function WDLMultiDungeonEntrancePinMixin:UseTooltip()
    return true;
end

function WDLMultiDungeonEntrancePinMixin:GetFallbackName()
    return DUNGEON_MAP_PIN_FALLBACK_NAME;
end

function WDLMultiDungeonEntrancePinMixin:OnAcquired(poiInfo, multiDungeonEntranceInfo, multiDungeonMapOverrideInfo)
    self.poiInfo = poiInfo;
    self.name = poiInfo.name;
    self.description = poiInfo.description;
    self.tooltipWidgetSet = poiInfo.tooltipWidgetSet;
    self.iconWidgetSet = poiInfo.iconWidgetSet;
    self.textureKit = poiInfo.uiTextureKit;

    self:SetDataProvider(poiInfo.dataProvider);
    self:SetTexture(poiInfo);
    self:SetPosition(poiInfo.position:GetXY());

    self.Texture:SetTexture("Interface\\AddOns\\WorldDungeonLocations\\Textures\\dungeon-raid");

    self:SetSize(42, 42);
    self.Texture:SetSize(42, 42);

    self.dungeonEntranceInfo = multiDungeonEntranceInfo;
    self.mapOverrideInfo = multiDungeonMapOverrideInfo;
end

function WDLMultiDungeonEntrancePinMixin:OnMouseClickAction(button)
    if InCombatLockdown() then return end

    if button == "LeftButton" then
        WorldMapFrame:SetMapID(self.mapOverrideInfo.childMapIds[1])
    end
end


WorldMapFrame:AddDataProvider(WDLMultiDungeonEntranceDataProviderMixin);
