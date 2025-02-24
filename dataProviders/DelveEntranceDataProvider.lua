local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

local HBD = LibStub('HereBeDragons-2.0');

local WDLDelveEntranceDataProviderMixin = CreateFromMixins(DelveEntranceDataProviderMixin);
WDLDelveEntranceDataProviderMixin:Init("showDelveEntrancesOnMap");

function WDLDelveEntranceDataProviderMixin:GetPinTemplate()
    return "WDLDelveEntrancePinTemplate";
end

function WDLDelveEntranceDataProviderMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function WDLDelveEntranceDataProviderMixin:RenderDelves(mapID, parentMapID)
    for _, areaPoiID in ipairs(C_AreaPoiInfo.GetDelvesForMap(mapID)) do
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
        if poiInfo then
            local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(mapID, parentMapID)
            if minX then
                local x, y = poiInfo.position:GetXY()
                if x then
                    poiInfo.position:SetXY(
                        Lerp(minX, maxX, x),
                        Lerp(minY, maxY, y)
                    )
                    poiInfo.dataProvider = self

                    self:GetMap():AcquirePin(self:GetPinTemplate(), poiInfo)
                end
            end
        end
    end
end

function WDLDelveEntranceDataProviderMixin:RefreshAllData()
    xpcall(function() -- by default, errors from dataproviders are silenced
        self:RemoveAllData();
        if not self:IsCVarSet() then
            return;
        end

        local mapID = self:GetMap():GetMapID();
        local mapInfo = private.GetMapInfo(mapID);
        if mapInfo.mapType == Enum.UIMapType.Continent then
            for _, childInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
                self:RenderDelves(childInfo.mapID, mapID);
            end
        end
    end, geterrorhandler());
end

--[[ Pin ]]--
WDLDelveEntrancePinMixin = AreaPOIPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DELVE_ENTRANCE");    --PIN_FRAME_LEVEL_WORLD_QUEST, PIN_FRAME_LEVEL_VIGNETTE

function WDLDelveEntrancePinMixin:DoesMapTypeAllowSuperTrack()
	local mapInfo = C_Map.GetMapInfo(self:GetMap():GetMapID())
	if mapInfo then
		return mapInfo.mapType >= Enum.UIMapType.Continent
	end
end

function WDLDelveEntrancePinMixin:GetSuperTrackMarkerOffset()
	return -7, 7;
end

function WDLDelveEntrancePinMixin:OnMouseClickAction(button)
    if button == "LeftButton" then
        if not SuperTrackablePinMixin.OnMouseClickAction(self, button) then
            -- Fallback in case the above fails for whatever reason
            local uiMapPoint = UiMapPoint.CreateFromVector2D(self:GetMap():GetMapID(), self.poiInfo.position, 0);
            C_Map.SetUserWaypoint(uiMapPoint);
            C_SuperTrack.SetSuperTrackedUserWaypoint(true);
        end
    end

    if button == "RightButton" and TomTom and IsAltKeyDown() then
        TomTom:AddWaypoint(self.poiInfo.zonePosition.mapID, self.poiInfo.zonePosition.position.x, self.poiInfo.zonePosition.position.y, {
            title = self.name,
            from = AddOnFolderName,
            persistent = nil,
            minimap = true,
            world = true
        })
    end
end


WorldMapFrame:AddDataProvider(WDLDelveEntranceDataProviderMixin);
