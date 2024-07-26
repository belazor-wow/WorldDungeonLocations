-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
	if dp.cvar and dp.cvar == 'showDungeonEntrancesOnMap' then
		WorldMapFrame:RemoveDataProvider(dp)
	end
end

-- create new one
local WorldDungeonEntranceDataProviderMixin = CreateFromMixins(DungeonEntranceDataProviderMixin)
WorldDungeonEntranceDataProviderMixin:Init('showDungeonEntrancesOnMap')

function WorldDungeonEntranceDataProviderMixin:RenderDungeons(mapID, parentMapID)
	for _, dungeonInfo in next, C_EncounterJournal.GetDungeonEntrancesForMap(mapID) do
		if parentMapID then
		-- translate map positions
		local continentID, worldPos = C_Map.GetWorldPosFromMapPos(mapID, dungeonInfo.position)
		_, dungeonInfo.position = C_Map.GetMapPosFromWorldPos(continentID, worldPos, parentMapID)
		end

		local pin = self:GetMap():AcquirePin('DungeonEntrancePinTemplate', dungeonInfo)
		pin.dataProvider = self
		pin:UpdateSupertrackedHighlight()
	end
end

function WorldDungeonEntranceDataProviderMixin:OnSuperTrackingChanged()
	for pin in self:GetMap():EnumeratePinsByTemplate("DungeonEntrancePinTemplate") do
		pin:UpdateSupertrackedHighlight();
	end
end

function WorldDungeonEntranceDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DungeonEntrancePinTemplate");
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

WorldMapFrame:AddDataProvider(WorldDungeonEntranceDataProviderMixin)
