local private = select(2, ...) ---@class PrivateNamespace

local TeleportMap = {}
private.TeleportMap = TeleportMap;

local playerFaction = UnitFactionGroup('player');

--- @param journalInstanceID number
--- @return number? spellID # nil if no teleport spell exists for given instance
--- @return number? duration # if on cooldown: seconds of CD duration left, nil otherwise
--- @return boolean? spellIsKnown # true if spell is known
function TeleportMap:GetByJournalInstanceID(journalInstanceID)
    local spellID = self.data[playerFaction][journalInstanceID] or self.data['Neutral'][journalInstanceID];
    if not spellID then return nil, nil, false; end

    local cooldownInfo = C_Spell.GetSpellCooldown(spellID);
    local duration = cooldownInfo and cooldownInfo.duration;
    if not duration or duration < 3 then -- global cooldown is counted here as well, so lets just ignore anything below 3 seconds
        duration = nil; ---@diagnostic disable-line: cast-local-type
    end

    return spellID, duration, IsSpellKnown(spellID);
end

-- gerenated by .query/Teleports.sql
TeleportMap.data = {
    ['Alliance'] = {
        [1023] = 445418, -- ALLIANCE - Siege of Boralus
    },
    ['Horde'] = {
        [1023] = 464256, -- HORDE - Siege of Boralus
    },
    ['Neutral'] = {
        [65] = 424142, -- Throne of the Tides
        [68] = 410080, -- The Vortex Pinnacle
        [71] = 445424, -- Grim Batol
        [239] = 393222, -- Uldaman: Legacy of Tyr
        [246] = 131232, -- Scholomance
        [302] = 131205, -- Stormstout Brewery
        [303] = 131225, -- Gate of the Setting Sun
        [311] = 131231, -- Scarlet Halls
        [312] = 131206, -- Shado-Pan Monastery
        [313] = 131204, -- Temple of the Jade Serpent
        [316] = 131229, -- Scarlet Monastery
        [321] = 131222, -- Mogu'shan Palace
        [324] = 131228, -- Siege of Niuzao Temple
        [385] = 159895, -- Bloodmaul Slag Mines
        [476] = 159898, -- Skyreach
        [536] = 159900, -- Grimrail Depot
        [537] = 159899, -- Shadowmoon Burial Grounds
        [547] = 159897, -- Auchindoun
        [556] = 159901, -- The Everbloom
        [558] = 159896, -- Iron Docks
        [559] = 159902, -- Upper Blackrock Spire
        [721] = 393764, -- Halls of Valor
        [740] = 424153, -- Black Rook Hold
        [745] = 373262, -- Karazhan
        [762] = 424163, -- Darkheart Thicket
        [767] = 410078, -- Neltharion's Lair
        [800] = 393766, -- Court of Stars
        [968] = 424187, -- Atal'Dazar
        [1001] = 410071, -- Freehold
        [1021] = 424167, -- Waycrest Manor
        [1022] = 410074, -- The Underrot
        [1178] = 373274, -- Operation: Mechagon
        [1182] = 354462, -- The Necrotic Wake
        [1183] = 354463, -- Plaguefall
        [1184] = 354464, -- Mists of Tirna Scithe
        [1185] = 354465, -- Halls of Atonement
        [1186] = 354466, -- Spires of Ascension
        [1187] = 354467, -- Theater of Pain
        [1188] = 354468, -- De Other Side
        [1189] = 354469, -- Sanguine Depths
        [1194] = 367416, -- Tazavesh, the Veiled Market
        [1196] = 393267, -- Brackenhide Hollow
        [1197] = 393222, -- Uldaman: Legacy of Tyr
        [1198] = 393262, -- The Nokhud Offensive
        [1199] = 393276, -- Neltharus
        [1201] = 393273, -- Algeth'ar Academy
        [1202] = 393256, -- Ruby Life Pools
        [1203] = 393279, -- The Azure Vault
        [1204] = 393283, -- Halls of Infusion
        [1209] = 424197, -- Dawn of the Infinite
        [1210] = 445441, -- Darkflame Cleft
        [1267] = 445444, -- Priory of the Sacred Flame
        [1268] = 445443, -- The Rookery
        [1269] = 445269, -- The Stonevault
        [1270] = 445414, -- The Dawnbreaker
        [1271] = 445417, -- Ara-Kara, City of Echoes
        [1272] = 445440, -- Cinderbrew Meadery
        [1274] = 445416, -- City of Threads
        [1190] = 373190, -- Raid: Castle Nathria
        [1193] = 373191, -- Raid: Sanctum of Domination
        [1195] = 373192, -- Raid: Sepulcher of the First Ones
        [1200] = 432254, -- Raid: Vault of the Incarnates
        [1207] = 432258, -- Raid: Amirdrassil, the Dream's Hope
        [1208] = 432257, -- Raid: Aberrus, the Shadowed Crucible
    },
};
