local private = select(2, ...) ---@class PrivateNamespace

local PinLocations = {};
private.PinLocations = PinLocations;

local HBD = LibStub('HereBeDragons-2.0');
local AZEROTH_MAP_ID = 947;

local function CopyTablePartial(tbl)
    local newTbl = {};
    for k, v in next, tbl do
        newTbl[k] = CopyTable(v, true);
    end

    return newTbl;
end

PinLocations.cache = {};

--- @param mapID number
--- @param parentMapID number?
--- @return table<number, WDL_PinInfo>
function PinLocations:GetInfoForMap(mapID, parentMapID)
    if mapID == AZEROTH_MAP_ID then return {}; end -- don't show them on the azeroth map
    self.cache[mapID] = self.cache[mapID] or {};
    parentMapID = parentMapID or -1;
    if self.cache[mapID][parentMapID] then return CopyTablePartial(self.cache[mapID][parentMapID]); end
    self.cache[mapID][parentMapID] = {};

    for _, data in next, self.data do
        local zoneX, zoneY = HBD:GetZoneCoordinatesFromWorld(data.pos1, data.pos0, mapID, false)
        if zoneX and zoneY then
            local position = CreateVector2D(zoneX, zoneY);
            local continentID, _ = C_Map.GetWorldPosFromMapPos(mapID, position);
            if continentID == data.continentID then
                data.name = data.name or EJ_GetInstanceInfo(data.journalInstanceID);
                self.cache[mapID][parentMapID][data.areaPoiID] = {
                    areaPoiID = data.areaPoiID,
                    position = position,
                    zonePosition = { mapID = mapID, position = position },
                    name = data.name,
                    description = data.atlasName == "Dungeon" and MAP_LEGEND_DUNGEON or MAP_LEGEND_RAID,
                    atlasName = data.atlasName,
                    journalInstanceID = data.journalInstanceID,
                    faction = data.faction,
                };
            end
        end
    end
    for _, dungeonInfo in next, C_EncounterJournal.GetDungeonEntrancesForMap(mapID) do
        dungeonInfo.zonePosition = { mapID = mapID, position = dungeonInfo.position }
        self.cache[mapID][parentMapID][dungeonInfo.areaPoiID] = dungeonInfo;
    end
    if parentMapID > -1 then
        local pins = self.cache[mapID][parentMapID];
        for _, pinInfo in next, pins do
            self:ApplyZoneCoordinateTranslation(pinInfo, mapID, parentMapID);
        end
    end

    return CopyTablePartial(self.cache[mapID][parentMapID]);
end

--- @param pinInfo WDL_PinInfo
--- @param mapID number
--- @param parentMapID number
--- @private
function PinLocations:ApplyZoneCoordinateTranslation(pinInfo, mapID, parentMapID)
    local override = self.dataOverrides[pinInfo.journalInstanceID] and self.dataOverrides[pinInfo.journalInstanceID][parentMapID];
    if override then
        pinInfo.position = CreateVector2D(override.zoneX, override.zoneY);

        return;
    end
    pinInfo.position = CreateVector2D(HBD:TranslateZoneCoordinates(pinInfo.position.x, pinInfo.position.y, mapID, parentMapID, false));
end

--[[
    Overrides map coordinates for certain journalInstanceID's
]]
--- @type table<number, table<number, {zoneX: number, zoneY: number}>> # [journalInstanceID][parentMapID] = positionOverride
--- @private
PinLocations.dataOverrides = {
    [362] = { -- Throne of Thunder
        [424] = { zoneX = 0.24396495365692, zoneY = 0.090617580118319 }, -- Pandaria continent map
    },
};

--[[
Missing locations:
    - Tazavesh (doesn't have a place that really fits)
    - Eternal Palace
    - Return to Karazahn (could use Karazahn raid for supertracking)
--]]

-- generated from .query/PinLocations.sql
--- @private
PinLocations.data = {
    { journalInstanceID = 63, areaPoiID = 6500, atlasName = "Dungeon", pos0 = -11071.00000000000, pos1 = 1527.07995605470, continentID = 0 }, -- Deadmines
    { journalInstanceID = 64, areaPoiID = 6725, atlasName = "Dungeon", pos0 = -234.22999572754, pos1 = 1563.19995117190, continentID = 0 }, -- Shadowfang Keep
    { journalInstanceID = 65, areaPoiID = 6684, atlasName = "Dungeon", pos0 = -5592.43017578120, pos1 = 5408.10986328120, continentID = 0 }, -- Throne of the Tides
    { journalInstanceID = 66, areaPoiID = 6662, atlasName = "Dungeon", pos0 = -7570.73095703120, pos1 = -1326.66491699220, continentID = 0 }, -- Blackrock Caverns
    { journalInstanceID = 67, areaPoiID = 6687, atlasName = "Dungeon", pos0 = 1025.96997070310, pos1 = 635.51800537109, continentID = 646 }, -- The Stonecore
    { journalInstanceID = 68, areaPoiID = 6685, atlasName = "Dungeon", pos0 = -11512.40039062500, pos1 = -2309.03002929690, continentID = 1 }, -- The Vortex Pinnacle
    { journalInstanceID = 69, areaPoiID = 6686, atlasName = "Dungeon", pos0 = -10678.40039062500, pos1 = -1306.93005371090, continentID = 1 }, -- Lost City of the Tol'vir
    { journalInstanceID = 70, areaPoiID = 6688, atlasName = "Dungeon", pos0 = -10210.70019531200, pos1 = -1837.76000976560, continentID = 1 }, -- Halls of Origination
    { journalInstanceID = 71, areaPoiID = 6689, atlasName = "Dungeon", pos0 = -4058.27001953120, pos1 = -3449.87011718750, continentID = 0 }, -- Grim Batol
    { journalInstanceID = 72, areaPoiID = 6516, atlasName = "Raid", pos0 = -4893.58984375000, pos1 = -4234.72021484380, continentID = 0 }, -- The Bastion of Twilight
    { journalInstanceID = 73, areaPoiID = 6517, atlasName = "Raid", pos0 = -7539.79003906250, pos1 = -1193.70996093750, continentID = 0 }, -- Blackwing Descent
    { journalInstanceID = 74, areaPoiID = 6515, atlasName = "Raid", pos0 = -11391.78515625000, pos1 = 149.36979675293, continentID = 1 }, -- Throne of the Four Winds
    { journalInstanceID = 75, areaPoiID = 6518, atlasName = "Raid", pos0 = -1204.52001953120, pos1 = 1082.56994628910, continentID = 732 }, -- Baradin Hold
    { journalInstanceID = 76, areaPoiID = 6682, atlasName = "Dungeon", pos0 = -11916.70019531200, pos1 = -1212.50000000000, continentID = 0 }, -- Zul'Gurub
    { journalInstanceID = 77, areaPoiID = 6683, atlasName = "Dungeon", pos0 = 6851.12011718750, pos1 = -7987.93017578120, continentID = 530 }, -- Zul'Aman
    { journalInstanceID = 78, areaPoiID = 6514, atlasName = "Raid", pos0 = 3976.53393554690, pos1 = -2916.09887695310, continentID = 1 }, -- Firelands
    { journalInstanceID = 184, areaPoiID = 6667, atlasName = "Dungeon", pos0 = -8261.12988281250, pos1 = -4452.50000000000, continentID = 1 }, -- End Time
    { journalInstanceID = 185, areaPoiID = 6665, atlasName = "Dungeon", pos0 = -8592.31640625000, pos1 = -3996.59375000000, continentID = 1 }, -- Well of Eternity
    { journalInstanceID = 186, areaPoiID = 6668, atlasName = "Dungeon", pos0 = -8293.65039062500, pos1 = -4600.62988281250, continentID = 1 }, -- Hour of Twilight
    { journalInstanceID = 187, areaPoiID = 6512, atlasName = "Raid", pos0 = -8220.87207031250, pos1 = -4502.54150390620, continentID = 1 }, -- Dragon Soul
    { journalInstanceID = 226, areaPoiID = 6846, atlasName = "Dungeon", pos0 = 1807.85412597660, pos1 = -4405.53320312500, continentID = 1 }, -- Ragefire Chasm
    { journalInstanceID = 227, areaPoiID = 6498, atlasName = "Dungeon", pos0 = 4142.10009765620, pos1 = 883.05999755859, continentID = 1 }, -- Blackfathom Deeps
    { journalInstanceID = 228, areaPoiID = 6499, atlasName = "Dungeon", pos0 = -7178.85986328120, pos1 = -926.03497314453, continentID = 0 }, -- Blackrock Depths
    { journalInstanceID = 229, areaPoiID = 6661, atlasName = "Dungeon", pos0 = -7524.19628906250, pos1 = -1334.52087402340, continentID = 0 }, -- Lower Blackrock Spire
    { journalInstanceID = 231, areaPoiID = 6502, atlasName = "Dungeon", pos0 = -5183.72998046880, pos1 = 599.61999511719, continentID = 0 }, -- Gnomeregan
    { journalInstanceID = 232, areaPoiID = 6503, atlasName = "Dungeon", pos0 = -1422.55004882810, pos1 = 2919.41992187500, continentID = 1 }, -- Maraudon
    { journalInstanceID = 233, areaPoiID = 6728, atlasName = "Dungeon", pos0 = -4651.12988281250, pos1 = -2490.25000000000, continentID = 1 }, -- Razorfen Downs
    { journalInstanceID = 234, areaPoiID = 6727, atlasName = "Dungeon", pos0 = -4464.08984375000, pos1 = -1666.45996093750, continentID = 1 }, -- Razorfen Kraul
    { journalInstanceID = 237, areaPoiID = 6722, atlasName = "Dungeon", pos0 = -10431.00000000000, pos1 = -3828.87988281250, continentID = 0 }, -- The Temple of Atal'hakkar
    { journalInstanceID = 238, areaPoiID = 6723, atlasName = "Dungeon", pos0 = -8781.09960937500, pos1 = 833.44097900391, continentID = 0 }, -- The Stockade
    { journalInstanceID = 239, areaPoiID = 6721, atlasName = "Dungeon", pos0 = -6088.95019531250, pos1 = -3192.82006835940, continentID = 0 }, -- Uldaman
    { journalInstanceID = 240, areaPoiID = 6720, atlasName = "Dungeon", pos0 = -820.92401123047, pos1 = -2124.55004882810, continentID = 1 }, -- Wailing Caverns
    { journalInstanceID = 241, areaPoiID = 6719, atlasName = "Dungeon", pos0 = -6831.22021484380, pos1 = -2910.62988281250, continentID = 1 }, -- Zul'Farrak
    { journalInstanceID = 246, areaPoiID = 6726, atlasName = "Dungeon", pos0 = 1257.73999023440, pos1 = -2584.35009765620, continentID = 0 }, -- Scholomance
    { journalInstanceID = 247, areaPoiID = 6715, atlasName = "Dungeon", pos0 = -3361.59008789060, pos1 = 5210.64990234380, continentID = 530 }, -- Auchenai Crypts
    { journalInstanceID = 248, areaPoiID = 6709, atlasName = "Dungeon", pos0 = -358.69299316406, pos1 = 3064.69995117190, continentID = 530 }, -- Hellfire Ramparts
    { journalInstanceID = 249, areaPoiID = 6718, atlasName = "Dungeon", pos0 = 12886.90039062500, pos1 = -7330.66015625000, continentID = 530 }, -- Magisters' Terrace
    { journalInstanceID = 249, areaPoiID = 8510, atlasName = "Dungeon", pos0 = 11638.40039062500, pos1 = -4964.12988281250, continentID = 0 }, -- Magisters' Terrace
    { journalInstanceID = 250, areaPoiID = 6716, atlasName = "Dungeon", pos0 = -3090.50000000000, pos1 = 4942.54980468750, continentID = 530 }, -- Mana-Tombs
    { journalInstanceID = 251, areaPoiID = 6666, atlasName = "Dungeon", pos0 = -8322.17968750000, pos1 = -4051.38989257810, continentID = 1 }, -- Old Hillsbrad Foothills
    { journalInstanceID = 252, areaPoiID = 6717, atlasName = "Dungeon", pos0 = -3361.94995117190, pos1 = 4674.95996093750, continentID = 530 }, -- Sethekk Halls
    { journalInstanceID = 253, areaPoiID = 6714, atlasName = "Dungeon", pos0 = -3634.62988281250, pos1 = 4943.43017578120, continentID = 530 }, -- Shadow Labyrinth
    { journalInstanceID = 254, areaPoiID = 6713, atlasName = "Dungeon", pos0 = 3309.92993164060, pos1 = 1337.22998046880, continentID = 530 }, -- The Arcatraz
    { journalInstanceID = 255, areaPoiID = 6664, atlasName = "Dungeon", pos0 = -8775.83886718750, pos1 = -4157.16845703120, continentID = 1 }, -- The Black Morass
    { journalInstanceID = 256, areaPoiID = 6708, atlasName = "Dungeon", pos0 = -302.40798950195, pos1 = 3162.91992187500, continentID = 530 }, -- The Blood Furnace
    { journalInstanceID = 257, areaPoiID = 6711, atlasName = "Dungeon", pos0 = 3409.85009765620, pos1 = 1486.26000976560, continentID = 530 }, -- The Botanica
    { journalInstanceID = 258, areaPoiID = 6712, atlasName = "Dungeon", pos0 = 2867.92993164060, pos1 = 1550.94995117190, continentID = 530 }, -- The Mechanar
    { journalInstanceID = 259, areaPoiID = 6710, atlasName = "Dungeon", pos0 = -306.67498779297, pos1 = 3057.13989257810, continentID = 530 }, -- The Shattered Halls
    { journalInstanceID = 260, areaPoiID = 6705, atlasName = "Dungeon", pos0 = 731.02099609375, pos1 = 7013.75000000000, continentID = 530 }, -- The Slave Pens
    { journalInstanceID = 261, areaPoiID = 6706, atlasName = "Dungeon", pos0 = 817.92401123047, pos1 = 6937.56005859380, continentID = 530 }, -- The Steamvault
    { journalInstanceID = 262, areaPoiID = 6707, atlasName = "Dungeon", pos0 = 781.11901855469, pos1 = 6751.41015625000, continentID = 530 }, -- The Underbog
    { journalInstanceID = 271, areaPoiID = 6704, atlasName = "Dungeon", pos0 = 3642.57006835940, pos1 = 2035.15002441410, continentID = 571 }, -- Ahn'kahet: The Old Kingdom
    { journalInstanceID = 272, areaPoiID = 6703, atlasName = "Dungeon", pos0 = 3675.43994140620, pos1 = 2169.15991210940, continentID = 571 }, -- Azjol-Nerub
    { journalInstanceID = 273, areaPoiID = 6702, atlasName = "Dungeon", pos0 = 4774.60986328120, pos1 = -2032.09997558590, continentID = 571 }, -- Drak'Tharon Keep
    { journalInstanceID = 274, areaPoiID = 6701, atlasName = "Dungeon", pos0 = 6956.00000000000, pos1 = -4417.14013671880, continentID = 571 }, -- Gundrak
    { journalInstanceID = 275, areaPoiID = 6699, atlasName = "Dungeon", pos0 = 9179.29980468750, pos1 = -1382.14001464840, continentID = 571 }, -- Halls of Lightning
    { journalInstanceID = 276, areaPoiID = 6698, atlasName = "Dungeon", pos0 = 5628.60009765620, pos1 = 1975.29003906250, continentID = 571 }, -- Halls of Reflection
    { journalInstanceID = 277, areaPoiID = 6700, atlasName = "Dungeon", pos0 = 8922.50000000000, pos1 = -974.03198242188, continentID = 571 }, -- Halls of Stone
    { journalInstanceID = 278, areaPoiID = 6697, atlasName = "Dungeon", pos0 = 5593.56982421880, pos1 = 2011.72998046880, continentID = 571 }, -- Pit of Saron
    { journalInstanceID = 279, areaPoiID = 6663, atlasName = "Dungeon", pos0 = -8756.89550781250, pos1 = -4492.58837890620, continentID = 1 }, -- The Culling of Stratholme
    { journalInstanceID = 280, areaPoiID = 6696, atlasName = "Dungeon", pos0 = 5669.83007812500, pos1 = 2004.34997558590, continentID = 571 }, -- The Forge of Souls
    { journalInstanceID = 281, areaPoiID = 6695, atlasName = "Dungeon", pos0 = 3832.27001953120, pos1 = 6922.58007812500, continentID = 571 }, -- The Nexus
    { journalInstanceID = 282, areaPoiID = 6694, atlasName = "Dungeon", pos0 = 3842.39990234380, pos1 = 7037.41015625000, continentID = 571 }, -- The Oculus
    { journalInstanceID = 283, areaPoiID = 6845, atlasName = "Dungeon", pos0 = 5693.41503906250, pos1 = 503.33160400391, continentID = 571 }, -- The Violet Hold
    { journalInstanceID = 284, areaPoiID = 6692, atlasName = "Dungeon", pos0 = 8572.01953125000, pos1 = 792.32501220703, continentID = 571 }, -- Trial of the Champion
    { journalInstanceID = 285, areaPoiID = 6691, atlasName = "Dungeon", pos0 = 1120.77001953120, pos1 = -4897.29003906250, continentID = 571 }, -- Utgarde Keep
    { journalInstanceID = 286, areaPoiID = 6690, atlasName = "Dungeon", pos0 = 1242.39001464840, pos1 = -4857.41992187500, continentID = 571 }, -- Utgarde Pinnacle
    { journalInstanceID = 302, areaPoiID = 6677, atlasName = "Dungeon", pos0 = -712.19299316406, pos1 = 1263.64001464840, continentID = 870 }, -- Stormstout Brewery
    { journalInstanceID = 303, areaPoiID = 6681, atlasName = "Dungeon", pos0 = 692.15301513672, pos1 = 2080.19995117190, continentID = 870 }, -- Gate of the Setting Sun
    { journalInstanceID = 311, areaPoiID = 6496, atlasName = "Dungeon", pos0 = 2865.19995117190, pos1 = -822.24298095703, continentID = 0 }, -- Scarlet Halls
    { journalInstanceID = 312, areaPoiID = 6679, atlasName = "Dungeon", pos0 = 3638.18994140620, pos1 = 2542.12011718750, continentID = 870 }, -- Shado-Pan Monastery
    { journalInstanceID = 313, areaPoiID = 6676, atlasName = "Dungeon", pos0 = 958.83197021484, pos1 = -2470.58007812500, continentID = 870 }, -- Temple of the Jade Serpent
    { journalInstanceID = 316, areaPoiID = 6497, atlasName = "Dungeon", pos0 = 2920.65991210940, pos1 = -799.56896972656, continentID = 0 }, -- Scarlet Monastery
    { journalInstanceID = 317, areaPoiID = 6511, atlasName = "Raid", pos0 = 3984.15991210940, pos1 = 1109.08996582030, continentID = 870 }, -- Mogu'shan Vaults
    { journalInstanceID = 320, areaPoiID = 6509, atlasName = "Raid", pos0 = 955.52899169922, pos1 = -56.07300186157, continentID = 870 }, -- Terrace of Endless Spring
    { journalInstanceID = 321, areaPoiID = 6680, atlasName = "Dungeon", pos0 = 1390.40002441410, pos1 = 439.26098632813, continentID = 870 }, -- Mogu'shan Palace
    { journalInstanceID = 324, areaPoiID = 6678, atlasName = "Dungeon", pos0 = 1436.80004882810, pos1 = 5086.68017578120, continentID = 870 }, -- Siege of Niuzao Temple
    { journalInstanceID = 330, areaPoiID = 6510, atlasName = "Raid", pos0 = 167.67300415039, pos1 = 4056.39990234380, continentID = 870 }, -- Heart of Fear
    { journalInstanceID = 362, areaPoiID = 6508, atlasName = "Raid", pos0 = 7264.84716796880, pos1 = 5014.46191406250, continentID = 1064 }, -- Throne of Thunder
    { journalInstanceID = 369, areaPoiID = 6507, atlasName = "Raid", pos0 = 1230.90002441410, pos1 = 613.85198974609, continentID = 870 }, -- Siege of Orgrimmar
    { journalInstanceID = 385, areaPoiID = 6672, atlasName = "Dungeon", pos0 = 7263.70996093750, pos1 = 4453.39013671880, continentID = 1116 }, -- Bloodmaul Slag Mines
    { journalInstanceID = 457, areaPoiID = 6505, atlasName = "Raid", pos0 = 8107.20019531250, pos1 = 850.10302734375, continentID = 1116 }, -- Blackrock Foundry
    { journalInstanceID = 476, areaPoiID = 6674, atlasName = "Dungeon", pos0 = 25.52420043945, pos1 = 2524.65991210940, continentID = 1116 }, -- Skyreach
    { journalInstanceID = 477, areaPoiID = 6506, atlasName = "Raid", pos0 = 3471.11010742190, pos1 = 7437.35009765620, continentID = 1116 }, -- Highmaul
    { journalInstanceID = 536, areaPoiID = 6670, atlasName = "Dungeon", pos0 = 7860.20996093750, pos1 = 556.24200439453, continentID = 1116 }, -- Grimrail Depot
    { journalInstanceID = 537, areaPoiID = 6675, atlasName = "Dungeon", pos0 = 759.75897216797, pos1 = 134.11099243164, continentID = 1116 }, -- Shadowmoon Burial Grounds
    { journalInstanceID = 547, areaPoiID = 6673, atlasName = "Dungeon", pos0 = 1489.80004882810, pos1 = 3073.13989257810, continentID = 1116 }, -- Auchindoun
    { journalInstanceID = 556, areaPoiID = 6669, atlasName = "Dungeon", pos0 = 7100.97998046880, pos1 = 194.89900207520, continentID = 1116 }, -- The Everbloom
    { journalInstanceID = 558, areaPoiID = 6671, atlasName = "Dungeon", pos0 = 8851.92968750000, pos1 = 1353.10998535160, continentID = 1116 }, -- Iron Docks
    { journalInstanceID = 559, areaPoiID = 6660, atlasName = "Dungeon", pos0 = -7485.54003906250, pos1 = -1324.34545898440, continentID = 0 }, -- Upper Blackrock Spire
    { journalInstanceID = 669, areaPoiID = 6504, atlasName = "Raid", pos0 = 4090.89672851560, pos1 = -757.33508300781, continentID = 1116 }, -- Hellfire Citadel
    { journalInstanceID = 707, areaPoiID = 5092, atlasName = "Dungeon", pos0 = -1802.32995605470, pos1 = 6663.89990234380, continentID = 1220 }, -- Vault of the Wardens
    { journalInstanceID = 716, areaPoiID = 5091, atlasName = "Dungeon", pos0 = -0.26868098974, pos1 = 5800.75976562500, continentID = 1220 }, -- Eye of Azshara
    { journalInstanceID = 721, areaPoiID = 5096, atlasName = "Dungeon", pos0 = 2449.69262695310, pos1 = 818.15277099609, continentID = 1220 }, -- Halls of Valor
    { journalInstanceID = 726, areaPoiID = 5099, atlasName = "Dungeon", pos0 = 1168.82995605470, pos1 = 4372.70019531250, continentID = 1220 }, -- The Arcway
    { journalInstanceID = 727, areaPoiID = 5097, atlasName = "Dungeon", pos0 = 3419.00878906250, pos1 = 1988.63537597660, continentID = 1220 }, -- Maw of Souls
    { journalInstanceID = 740, areaPoiID = 5093, atlasName = "Dungeon", pos0 = 3116.41992187500, pos1 = 7555.50976562500, continentID = 1220 }, -- Black Rook Hold
    { journalInstanceID = 741, areaPoiID = 6535, atlasName = "Raid", pos0 = -7498.65625000000, pos1 = -1036.15100097660, continentID = 0 }, -- Molten Core
    { journalInstanceID = 742, areaPoiID = 6536, atlasName = "Raid", pos0 = -7664.78125000000, pos1 = -1217.35241699220, continentID = 0 }, -- Blackwing Lair
    { journalInstanceID = 743, areaPoiID = 6538, atlasName = "Raid", pos0 = -8417.66015625000, pos1 = 1504.38000488280, continentID = 1 }, -- Ruins of Ahn'Qiraj
    { journalInstanceID = 744, areaPoiID = 6537, atlasName = "Raid", pos0 = -8235.21972656250, pos1 = 1996.33996582030, continentID = 1 }, -- Temple of Ahn'Qiraj
    { journalInstanceID = 745, areaPoiID = 6528, atlasName = "Raid", pos0 = -11115.09960937500, pos1 = -2008.00000000000, continentID = 0 }, -- Karazhan
    { journalInstanceID = 746, areaPoiID = 6529, atlasName = "Raid", pos0 = 3535.17993164060, pos1 = 5098.79980468750, continentID = 530 }, -- Gruul's Lair
    { journalInstanceID = 747, areaPoiID = 6531, atlasName = "Raid", pos0 = -338.29400634766, pos1 = 3134.06005859380, continentID = 530 }, -- Magtheridon's Lair
    { journalInstanceID = 748, areaPoiID = 6530, atlasName = "Raid", pos0 = 812.83197021484, pos1 = 6865.64990234380, continentID = 530 }, -- Serpentshrine Cavern
    { journalInstanceID = 749, areaPoiID = 6534, atlasName = "Raid", pos0 = 3087.92993164060, pos1 = 1380.17004394530, continentID = 530 }, -- The Eye
    { journalInstanceID = 750, areaPoiID = 6513, atlasName = "Raid", pos0 = -8185.10986328120, pos1 = -4224.68994140620, continentID = 1 }, -- The Battle for Mount Hyjal
    { journalInstanceID = 751, areaPoiID = 6532, atlasName = "Raid", pos0 = -3644.98999023440, pos1 = 316.81799316406, continentID = 530 }, -- Black Temple
    { journalInstanceID = 752, areaPoiID = 6533, atlasName = "Raid", pos0 = 12556.90039062500, pos1 = -6774.72998046880, continentID = 530 }, -- Sunwell Plateau
    { journalInstanceID = 753, areaPoiID = 6526, atlasName = "Raid", pos0 = 5484.91015625000, pos1 = 2840.30004882810, continentID = 571 }, -- Vault of Archavon
    { journalInstanceID = 754, areaPoiID = 6524, atlasName = "Raid", pos0 = 3667.72998046880, pos1 = -1271.56994628910, continentID = 571 }, -- Naxxramas
    { journalInstanceID = 755, areaPoiID = 6520, atlasName = "Raid", pos0 = 3442.75000000000, pos1 = 261.04000854492, continentID = 571 }, -- The Obsidian Sanctum
    { journalInstanceID = 756, areaPoiID = 6525, atlasName = "Raid", pos0 = 3870.26000976560, pos1 = 6984.22998046880, continentID = 571 }, -- The Eye of Eternity
    { journalInstanceID = 757, areaPoiID = 6522, atlasName = "Raid", pos0 = 8515.34960937500, pos1 = 730.16998291016, continentID = 571 }, -- Trial of the Crusader
    { journalInstanceID = 758, areaPoiID = 6521, atlasName = "Raid", pos0 = 5785.58007812500, pos1 = 2069.72998046880, continentID = 571 }, -- Icecrown Citadel
    { journalInstanceID = 759, areaPoiID = 6523, atlasName = "Raid", pos0 = 9353.96972656250, pos1 = -1115.03002929690, continentID = 571 }, -- Ulduar
    { journalInstanceID = 760, areaPoiID = 6527, atlasName = "Raid", pos0 = -4691.12988281250, pos1 = -3716.30004882810, continentID = 1 }, -- Onyxia's Lair
    { journalInstanceID = 761, areaPoiID = 6519, atlasName = "Raid", pos0 = 3608.34008789060, pos1 = 186.46400451660, continentID = 571 }, -- The Ruby Sanctum
    { journalInstanceID = 762, areaPoiID = 5094, atlasName = "Dungeon", pos0 = 3812.90893554690, pos1 = 6347.58935546880, continentID = 1220 }, -- Darkheart Thicket
    { journalInstanceID = 767, areaPoiID = 5103, atlasName = "Dungeon", pos0 = 3732.35424804690, pos1 = 4184.58837890620, continentID = 1220 }, -- Neltharion's Lair
    { journalInstanceID = 768, areaPoiID = 5095, atlasName = "Raid", pos0 = 3588.27514648440, pos1 = 6483.40478515620, continentID = 1220 }, -- The Emerald Nightmare
    { journalInstanceID = 777, areaPoiID = 5098, atlasName = "Dungeon", pos0 = -953.05731201172, pos1 = 4333.45996093750, continentID = 1220 }, -- Assault on Violet Hold
    { journalInstanceID = 786, areaPoiID = 5101, atlasName = "Raid", pos0 = 1324.74475097660, pos1 = 4230.58691406250, continentID = 1220 }, -- The Nighthold
    { journalInstanceID = 800, areaPoiID = 5100, atlasName = "Dungeon", pos0 = 1019.79998779300, pos1 = 3839.73999023440, continentID = 1220 }, -- Court of Stars
    { journalInstanceID = 861, areaPoiID = 5164, atlasName = "Raid", pos0 = 2360.08862304690, pos1 = 906.56250000000, continentID = 1220 }, -- Trial of Valor
    { journalInstanceID = 875, areaPoiID = 5250, atlasName = "Raid", pos0 = -552.58001708984, pos1 = 2452.31005859380, continentID = 1220 }, -- Tomb of Sargeras
    { journalInstanceID = 900, areaPoiID = 5251, atlasName = "Dungeon", pos0 = -434.19445800781, pos1 = 2421.15795898440, continentID = 1220 }, -- Cathedral of Eternal Night
    { journalInstanceID = 945, areaPoiID = 5327, atlasName = "Dungeon", pos0 = 5392.79003906250, pos1 = 10823.59960937500, continentID = 1669 }, -- Seat of the Triumvirate
    { journalInstanceID = 946, areaPoiID = 5440, atlasName = "Raid", pos0 = -3206.96020507810, pos1 = 9415.29394531250, continentID = 1669 }, -- Antorus, the Burning Throne
    { journalInstanceID = 968, areaPoiID = 5838, atlasName = "Dungeon", pos0 = -848.49133300781, pos1 = 2025.18750000000, continentID = 1642 }, -- Atal'Dazar
    { journalInstanceID = 1001, areaPoiID = 5834, atlasName = "Dungeon", pos0 = -1582.69616699220, pos1 = -1284.94104003910, continentID = 1643 }, -- Freehold
    { journalInstanceID = 1002, areaPoiID = 5831, atlasName = "Dungeon", pos0 = 27.36284828186, pos1 = -2655.09033203120, continentID = 1643 }, -- Tol Dagor
    { journalInstanceID = 1012, areaPoiID = 5836, atlasName = "Dungeon", pos0 = -1996.81079101560, pos1 = 961.49829101563, continentID = 1642, faction = "Horde" }, -- The MOTHERLODE!!
    { journalInstanceID = 1012, areaPoiID = 5837, atlasName = "Dungeon", pos0 = -2657.35424804690, pos1 = 2383.64575195310, continentID = 1642, faction = "Alliance" }, -- The MOTHERLODE!!
    { journalInstanceID = 1021, areaPoiID = 5832, atlasName = "Dungeon", pos0 = 784.93231201172, pos1 = 3372.31250000000, continentID = 1643 }, -- Waycrest Manor
    { journalInstanceID = 1022, areaPoiID = 5841, atlasName = "Dungeon", pos0 = 1263.05041503910, pos1 = 753.74133300781, continentID = 1642 }, -- The Underrot
    { journalInstanceID = 1023, areaPoiID = 5830, atlasName = "Dungeon", pos0 = -211.11631774902, pos1 = -1560.82983398440, continentID = 1643, faction = "Horde" }, -- Siege of Boralus
    { journalInstanceID = 1023, areaPoiID = 5833, atlasName = "Dungeon", pos0 = 1099.66491699220, pos1 = -622.72393798828, continentID = 1643, faction = "Alliance" }, -- Siege of Boralus
    { journalInstanceID = 1030, areaPoiID = 5840, atlasName = "Dungeon", pos0 = 3180.89062500000, pos1 = 3152.07910156250, continentID = 1642 }, -- Temple of Sethraliss
    { journalInstanceID = 1031, areaPoiID = 5842, atlasName = "Raid", pos0 = 1320.05725097660, pos1 = 601.89581298828, continentID = 1642 }, -- Uldir
    { journalInstanceID = 1036, areaPoiID = 5835, atlasName = "Dungeon", pos0 = 4154.92187500000, pos1 = -1118.15625000000, continentID = 1643 }, -- Shrine of the Storm
    { journalInstanceID = 1041, areaPoiID = 5839, atlasName = "Dungeon", pos0 = -848.25866699219, pos1 = 2528.38793945310, continentID = 1642 }, -- Kings' Rest
    { journalInstanceID = 1176, areaPoiID = 6012, atlasName = "Raid", pos0 = -309.88198852539, pos1 = 1117.42004394530, continentID = 1642, faction = "Horde" }, -- Battle of Dazar'alor
    { journalInstanceID = 1176, areaPoiID = 6013, atlasName = "Raid", pos0 = 908.13366699219, pos1 = -530.21008300781, continentID = 1643, faction = "Alliance" }, -- Battle of Dazar'alor
    { journalInstanceID = 1177, areaPoiID = 6116, atlasName = "Raid", pos0 = 3386.62329101560, pos1 = -1419.18579101560, continentID = 1643 }, -- Crucible of Storms
    { journalInstanceID = 1178, areaPoiID = 6129, atlasName = "Dungeon", pos0 = 3112.61010742190, pos1 = 4915.89990234380, continentID = 1643 }, -- Operation: Mechagon
    { journalInstanceID = 1180, areaPoiID = 6539, atlasName = "Raid", pos0 = 1140.57995605470, pos1 = 1465.63000488280, continentID = 870 }, -- Ny'alotha, the Waking City
    { journalInstanceID = 1180, areaPoiID = 6540, atlasName = "Raid", pos0 = -9844.04003906250, pos1 = -976.20202636719, continentID = 1 }, -- Ny'alotha, the Waking City
    { journalInstanceID = 1182, areaPoiID = 6582, atlasName = "Dungeon", pos0 = -3317.14941406250, pos1 = -4098.30908203120, continentID = 2222 }, -- The Necrotic Wake
    { journalInstanceID = 1183, areaPoiID = 6585, atlasName = "Dungeon", pos0 = 2085.92358398440, pos1 = -3115.11279296880, continentID = 2222 }, -- Plaguefall
    { journalInstanceID = 1184, areaPoiID = 6586, atlasName = "Dungeon", pos0 = -6935.44628906250, pos1 = 1785.00866699220, continentID = 2222 }, -- Mists of Tirna Scithe
    { journalInstanceID = 1185, areaPoiID = 6588, atlasName = "Dungeon", pos0 = -2185.12011718750, pos1 = 5000.87011718750, continentID = 2222 }, -- Halls of Atonement
    { journalInstanceID = 1186, areaPoiID = 6583, atlasName = "Dungeon", pos0 = -2132.80395507810, pos1 = -5325.68603515620, continentID = 2222 }, -- Spires of Ascension
    { journalInstanceID = 1187, areaPoiID = 6584, atlasName = "Dungeon", pos0 = 2594.17993164060, pos1 = -2718.94995117190, continentID = 2222 }, -- Theater of Pain
    { journalInstanceID = 1188, areaPoiID = 6587, atlasName = "Dungeon", pos0 = -7529.18994140620, pos1 = -583.57800292969, continentID = 2222 }, -- De Other Side
    { journalInstanceID = 1189, areaPoiID = 6589, atlasName = "Dungeon", pos0 = -1473.90002441410, pos1 = 6542.77978515620, continentID = 2222 }, -- Sanguine Depths
    { journalInstanceID = 1190, areaPoiID = 6590, atlasName = "Raid", pos0 = -1900.55004882810, pos1 = 6804.50976562500, continentID = 2222 }, -- Castle Nathria
    { journalInstanceID = 1193, areaPoiID = 6994, atlasName = "Raid", pos0 = 4849.50244140620, pos1 = 5779.50634765620, continentID = 2222 }, -- Sanctum of Domination
    { journalInstanceID = 1195, areaPoiID = 7021, atlasName = "Raid", pos0 = -3829.78002929690, pos1 = -1532.20996093750, continentID = 2374 }, -- Sepulcher of the First Ones
    { journalInstanceID = 1196, areaPoiID = 7209, atlasName = "Dungeon", pos0 = -4472.91992187500, pos1 = 4239.95019531250, continentID = 2444 }, -- Brackenhide Hollow
    { journalInstanceID = 1197, areaPoiID = 7216, atlasName = "Dungeon", pos0 = -6064.89990234380, pos1 = -3164.90991210940, continentID = 0 }, -- Uldaman: Legacy of Tyr
    { journalInstanceID = 1198, areaPoiID = 7215, atlasName = "Dungeon", pos0 = -546.51599121094, pos1 = 2212.54003906250, continentID = 2444 }, -- The Nokhud Offensive
    { journalInstanceID = 1199, areaPoiID = 7211, atlasName = "Dungeon", pos0 = 2376.69995117190, pos1 = 2603.47998046880, continentID = 2444 }, -- Neltharus
    { journalInstanceID = 1200, areaPoiID = 7048, atlasName = "Raid", pos0 = 486.02777099609, pos1 = -4459.86621093750, continentID = 2444 }, -- Vault of the Incarnates
    { journalInstanceID = 1201, areaPoiID = 7213, atlasName = "Dungeon", pos0 = 1347.50000000000, pos1 = -2781.45996093750, continentID = 2444 }, -- Algeth'ar Academy
    { journalInstanceID = 1202, areaPoiID = 7212, atlasName = "Dungeon", pos0 = 1344.28002929690, pos1 = -139.05700683594, continentID = 2444 }, -- Ruby Life Pools
    { journalInstanceID = 1203, areaPoiID = 7214, atlasName = "Dungeon", pos0 = -5615.50000000000, pos1 = 1258.94995117190, continentID = 2444 }, -- The Azure Vault
    { journalInstanceID = 1204, areaPoiID = 7210, atlasName = "Dungeon", pos0 = 117.31700134277, pos1 = -2876.42993164060, continentID = 2444 }, -- Halls of Infusion
    { journalInstanceID = 1207, areaPoiID = 7631, atlasName = "Raid", pos0 = -153.21006774902, pos1 = 8849.32812500000, continentID = 2548 }, -- Amirdrassil, the Dream's Hope
    { journalInstanceID = 1208, areaPoiID = 7491, atlasName = "Raid", pos0 = 1751.89001464840, pos1 = 2548.79003906250, continentID = 2454 }, -- Aberrus, the Shadowed Crucible
    { journalInstanceID = 1209, areaPoiID = 7525, atlasName = "Dungeon", pos0 = -1495.03002929690, pos1 = -3071.85009765620, continentID = 2444 }, -- Dawn of the Infinite
    { journalInstanceID = 1210, areaPoiID = 7821, atlasName = "Dungeon", pos0 = 2790.92993164060, pos1 = -3651.12011718750, continentID = 2601 }, -- Darkflame Cleft
    { journalInstanceID = 1267, areaPoiID = 7858, atlasName = "Dungeon", pos0 = 2209.55004882810, pos1 = 968.24298095703, continentID = 2601 }, -- Priory of the Sacred Flame
    { journalInstanceID = 1268, areaPoiID = 7655, atlasName = "Dungeon", pos0 = 2800.81005859380, pos1 = -2203.08007812500, continentID = 2552 }, -- The Rookery
    { journalInstanceID = 1269, areaPoiID = 7820, atlasName = "Dungeon", pos0 = 3419.19995117190, pos1 = -2730.84008789060, continentID = 2601 }, -- The Stonevault
    { journalInstanceID = 1270, areaPoiID = 7892, atlasName = "Dungeon", pos0 = 1446.09997558590, pos1 = -159.27600097656, continentID = 2601 }, -- The Dawnbreaker
    { journalInstanceID = 1271, areaPoiID = 7545, atlasName = "Dungeon", pos0 = -2166.21997070310, pos1 = -935.37298583984, continentID = 2601 }, -- Ara-Kara, City of Echoes
    { journalInstanceID = 1272, areaPoiID = 7857, atlasName = "Dungeon", pos0 = 2646.95996093750, pos1 = -4881.93017578120, continentID = 2552 }, -- Cinderbrew Meadery
    { journalInstanceID = 1273, areaPoiID = 7546, atlasName = "Raid", pos0 = -2592.19995117190, pos1 = -524.44097900391, continentID = 2601 }, -- Nerub-ar Palace
    { journalInstanceID = 1274, areaPoiID = 7548, atlasName = "Dungeon", pos0 = -1623.54003906250, pos1 = -743.47399902344, continentID = 2601 }, -- City of Threads
    { journalInstanceID = 1296, areaPoiID = 8240, atlasName = "Raid", pos0 = 30.28472328186, pos1 = 563.92706298828, continentID = 2706 }, -- Liberation of Undermine
    { journalInstanceID = 1298, areaPoiID = 8162, atlasName = "Dungeon", pos0 = 1931.68005371090, pos1 = -2686.12011718750, continentID = 2601 }, -- Operation: Floodgate
    { journalInstanceID = 1299, areaPoiID = 8386, atlasName = "Dungeon", pos0 = 5216.62988281250, pos1 = -3194.00000000000, continentID = 0 }, -- Windrunner Spire
    { journalInstanceID = 1300, areaPoiID = 6718, atlasName = "Dungeon", pos0 = 12886.90039062500, pos1 = -7330.66015625000, continentID = 530 }, -- Magisters' Terrace
    { journalInstanceID = 1300, areaPoiID = 8510, atlasName = "Dungeon", pos0 = 11638.40039062500, pos1 = -4964.12988281250, continentID = 0 }, -- Magisters' Terrace
    { journalInstanceID = 1301, areaPoiID = 6499, atlasName = "Dungeon", pos0 = -7178.85986328120, pos1 = -926.03497314453, continentID = 0 }, -- Blackrock Depths
    { journalInstanceID = 1302, areaPoiID = 8363, atlasName = "Raid", pos0 = 2027.53002929690, pos1 = 1789.50000000000, continentID = 2738 }, -- Manaforge Omega
    { journalInstanceID = 1303, areaPoiID = 8321, atlasName = "Dungeon", pos0 = -558.29302978516, pos1 = -160.96899414063, continentID = 2738 }, -- Eco-Dome Al'dani
    { journalInstanceID = 1304, areaPoiID = 8217, atlasName = "Dungeon", pos0 = 8630.79980468750, pos1 = -4941.20996093750, continentID = 0 }, -- Murder Row
    { journalInstanceID = 1308, areaPoiID = 8271, atlasName = "Raid", pos0 = 10147.00000000000, pos1 = -4616.85009765620, continentID = 0 }, -- March on Quel'Danas
    { journalInstanceID = 1309, areaPoiID = 8481, atlasName = "Dungeon", pos0 = -1412.68005371090, pos1 = 1574.83996582030, continentID = 2694 }, -- The Blinding Vale
    { journalInstanceID = 1311, areaPoiID = 8472, atlasName = "Dungeon", pos0 = 3257.97998046880, pos1 = -6311.62011718750, continentID = 0 }, -- Den of Nalorakk
    { journalInstanceID = 1313, areaPoiID = 8647, atlasName = "Dungeon", pos0 = 4385.06005859380, pos1 = -451.66299438477, continentID = 2771 }, -- Voidscar Arena
    { journalInstanceID = 1314, areaPoiID = 8482, atlasName = "Raid", pos0 = -647.70300292969, pos1 = -1069.33996582030, continentID = 2694 }, -- The Dreamrift
    { journalInstanceID = 1315, areaPoiID = 8480, atlasName = "Dungeon", pos0 = 5942.83984375000, pos1 = -7565.14013671880, continentID = 0 }, -- Maisara Caverns
    { journalInstanceID = 1316, areaPoiID = 8644, atlasName = "Dungeon", pos0 = 1466.65002441410, pos1 = -1805.78002929690, continentID = 2771 }, -- Nexus-Point Xenas
};
