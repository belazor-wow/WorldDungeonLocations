local private = select(2, ...); ---@class PrivateNamespace

local HBD = LibStub('HereBeDragons-2.0');

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
    if dp.cvar and dp.cvar == 'showDungeonEntrancesOnMap' then
        WorldMapFrame:RemoveDataProvider(dp);
    end
end

-- create new one
local WorldDungeonEntranceDataProviderMixin = CreateFromMixins(DungeonEntranceDataProviderMixin);
WorldDungeonEntranceDataProviderMixin:Init('showDungeonEntrancesOnMap');

function WorldDungeonEntranceDataProviderMixin:RenderDungeons(mapID, parentMapID)
    for _, dungeonInfo in next, private.PinLocations:GetInfoForMap(mapID) do
        dungeonInfo = CopyTable(dungeonInfo, true);
        if parentMapID then
            dungeonInfo.position = CreateVector2D(HBD:TranslateZoneCoordinates(dungeonInfo.position.x, dungeonInfo.position.y, mapID, parentMapID, false));
        end

        local pin = self:GetMap():AcquirePin('WorldDungeonEntrancePinTemplate', dungeonInfo);
        pin.dataProvider = self;
        pin:UpdateSupertrackedHighlight();
    end
end

function WorldDungeonEntranceDataProviderMixin:OnSuperTrackingChanged()
    for pin in self:GetMap():EnumeratePinsByTemplate('WorldDungeonEntrancePinTemplate') do
        pin:UpdateSupertrackedHighlight();
    end
end

function WorldDungeonEntranceDataProviderMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate('WorldDungeonEntrancePinTemplate');
end

function WorldDungeonEntranceDataProviderMixin:RefreshAllData()
    xpcall(function() -- by default, errors from dataproviders are silenced
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
    end, geterrorhandler());
end

WorldMapFrame:AddDataProvider(WorldDungeonEntranceDataProviderMixin);
