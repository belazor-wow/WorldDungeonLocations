local private = select(2, ...) ---@class PrivateNamespace

WDLMultiDungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
WDLMultiDungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap");

function WDLMultiDungeonEntranceDataProviderMixin:GetPinTemplate()
    return "WDLMultiDungeonEntrancePinTemplate";
end

function WDLMultiDungeonEntranceDataProviderMixin:OnAdded(mapCanvas)
    MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
    mapCanvas:SetPinTemplateType(self:GetPinTemplate(), "BUTTON");
end

function WDLMultiDungeonEntranceDataProviderMixin:OnShow()
    CVarMapCanvasDataProviderMixin.OnShow(self);
    EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
end

function WDLMultiDungeonEntranceDataProviderMixin:OnHide()
    CVarMapCanvasDataProviderMixin.OnHide(self);
    EventRegistry:UnregisterCallback("Supertracking.OnChanged", self);
end


function WDLMultiDungeonEntranceDataProviderMixin:OnSuperTrackingChanged()
    for pin in self:GetMap():EnumeratePinsByTemplate(self:GetPinTemplate()) do
        pin:UpdateSupertrackedHighlight();
    end
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

    if #combinedEntranceInfo then
        local poiInfo = {
            atlasName = "Raid",
            name = map.name,
            description = "Test",
            poiID = 6638,
            isAlawysOnFlightmap = false,
            shouldGlow = false,
            isPrimaryMapForPOI = true,
            position = mapOverrideInfo.position
        };

        local pin = map:AcquirePin(self:GetPinTemplate(), combinedEntranceInfo, poiInfo);
        pin.dataProvider = self;
        pin:UpdateSupertrackedHighlight();
        DevTools_Dump(pin)
    end
end

--[[ Pin ]]--
WDLMultiDungeonEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");

function WDLMultiDungeonEntrancePinMixin:OnLoad()
    BaseMapPoiPinMixin.OnLoad(self);

    self:SetNudgeSourceRadius(1);
    self:SetNudgeSourceMagnitude(2, 2);
end

function WDLMultiDungeonEntrancePinMixin:OnAcquired(multiDungeonEntranceInfo, poiInfo) -- override
    SuperTrackablePoiPinMixin.OnAcquired(self, poiInfo);

    self.dungeonEntranceInfo = multiDungeonEntranceInfo;
end

function WDLMultiDungeonEntrancePinMixin:ShouldMouseButtonBePassthrough(button)
    -- Dungeon entrances allow left click to super track and right click to open journal.
    -- Other buttons don't matter at this time.
    return false;
end

function WDLMultiDungeonEntrancePinMixin:UseTooltip()
    return true;
end

function WDLMultiDungeonEntrancePinMixin:GetFallbackName()
    return DUNGEON_MAP_PIN_FALLBACK_NAME;
end

function WDLMultiDungeonEntrancePinMixin:GetTooltipInstructions()
    return DUNGEON_POI_TOOLTIP_INSTRUCTION_LINE;
end

function WDLMultiDungeonEntrancePinMixin:OnMouseClickAction(button)
    SuperTrackablePinMixin.OnMouseClickAction(self, button);
end

function WDLMultiDungeonEntrancePinMixin:GetHighlightType() -- override
    if QuestSuperTracking_ShouldHighlightDungeons(self:GetMap():GetMapID()) then
        return MapPinHighlightType.SupertrackedHighlight;
    end

    return MapPinHighlightType.None;
end

function WDLMultiDungeonEntrancePinMixin:UpdateSupertrackedHighlight()
    MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture);
end

WorldMapFrame:AddDataProvider(CreateFromMixins(WDLMultiDungeonEntranceDataProviderMixin))
