local private = select(2, ...) ---@class PrivateNamespace

local HBD = LibStub('HereBeDragons-2.0');

local WDLMultiDungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
WDLMultiDungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap");

function WDLMultiDungeonEntranceDataProviderMixin:GetPinTemplate()
    return "WDLMultiDungeonEntrancePinTemplate";
end

function WDLMultiDungeonEntranceDataProviderMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function WDLMultiDungeonEntranceDataProviderMixin:RenderDungeons(mapID, parentMapID)
    local mapOverrideInfo = private.mapOverrides[mapID] or {}

    for _, pin in ipairs(mapOverrideInfo) do
        local combinedEntranceInfo = {}

        for _, childMapId in ipairs(pin.childMapIds) do
            for _, dungeonInfo in next, private.PinLocations:GetInfoForMap(childMapId) do
                dungeonInfo = CopyTable(dungeonInfo, true);
                combinedEntranceInfo[dungeonInfo.journalInstanceID] = dungeonInfo;
            end
        end

        if next(combinedEntranceInfo) then
            local x, y = pin.position.x, pin.position.y;
            if parentMapID then
                x, y = HBD:TranslateZoneCoordinates(x, y, mapID, parentMapID, false);
            end
            local poiInfo = {
                atlasName = "Raid",
                name = pin.comboName or (pin.areaId and private.GetAreaName(pin.areaId) or private.GetMapInfo(pin.childMapIds[1]).name),
                isAlwaysOnFlightmap = false,
                shouldGlow = false,
                isPrimaryMapForPOI = true,
                position = CreateVector2D(x, y),
                dataProvider = WDLMultiDungeonEntranceDataProviderMixin,
            };

            self:GetMap():AcquirePin(self:GetPinTemplate(), poiInfo, combinedEntranceInfo, pin);
        end
    end
end

function WDLMultiDungeonEntranceDataProviderMixin:RefreshAllData()
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

function WDLMultiDungeonEntrancePinMixin:CheckShowTooltip()
	if self:UseTooltip() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		local name, description = self:GetBestNameAndDescription();
		GameTooltip_SetTitle(tooltip, name);

		if description then
			GameTooltip_AddNormalLine(tooltip, description);
		end

        for _, dungeonEntranceInfo in pairs(self.dungeonEntranceInfo) do
            local _, _, _, _, _, _, _, _, _, instanceId, isRaid = EJ_GetInstanceInfo(dungeonEntranceInfo.journalInstanceID);

            GameTooltip_AddBlankLineToTooltip(tooltip)
            tooltip:AddDoubleLine(dungeonEntranceInfo.name, isRaid and "|cff5ed648" .. MAP_LEGEND_RAID .. "|r" or "|cff549f98" .. MAP_LEGEND_DUNGEON .. "|r")

            if private.savedInstances[instanceId] ~= nil then
                GameTooltip_AddNormalLine(tooltip, dungeonEntranceInfo.name)
                for key, value in pairs(private.savedInstances[instanceId]) do
                    tooltip:AddDoubleLine("|cffffffee" .. key .. "|r", value)
                end
            end
        end

		local instructionLine = self:GetTooltipInstructions();
		if instructionLine then
			GameTooltip_AddInstructionLine(tooltip, instructionLine, false);
		end

		tooltip:Show();
	end
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

--[[
function WDLMultiDungeonEntrancePinMixin:OnMouseClickAction(button)
    if InCombatLockdown() then return end

    if button == "LeftButton" then
        WorldMapFrame:SetMapID(self.mapOverrideInfo.childMapIds[1])
    end
end
]]


WorldMapFrame:AddDataProvider(WDLMultiDungeonEntranceDataProviderMixin);
