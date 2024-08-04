local private = select(2, ...) ---@class PrivateNamespace
private.savedInstances = {}

private.mapOverrides = {
    -- Burning Steppes
    [36] = {
        {
            ["position"] = {x = 0.21056824922562, y = 0.38353234529495},
            ["childMapIds"] = {33, 34, 35}
        }
    },

    -- Searing Gorge
    [32] = {
        {
            ["position"] = {x = 0.3478, y = 0.8392},
            ["childMapIds"] = {33, 34, 35}
        }
    },

    -- Blackrock Mountain
    [33] = {
        {
            ["areaId"] = 1584, -- Use 1583 if showing "Blackrock Spire" would be more appropriate
            ["position"] = {x = 0.46468424797058, y = 0.50324219465256},
            ["childMapIds"] = {35}
        },
        {
            ["areaId"] = 4926,
            ["position"] = {x = 0.67666578292847, y = 0.61508738994598},
            ["childMapIds"] = {34}
        },
    },
}

private.mapNames = {}

private.GetMapName = function(mapId)
    if not private.mapNames[mapId] then
        private.mapNames[mapId] = C_Map.GetMapInfo(mapId).name
    end

    return private.mapNames[mapId]
end

private.areaNames = {}

private.GetAreaName = function(areaId)
    if not private.areaNames[areaId] then
        private.areaNames[areaId] = C_Map.GetAreaInfo(areaId)
    end

    return private.areaNames[areaId]
end

local function UpdateSavedInstances()
    table.wipe(private.savedInstances)
    for i = 1, GetNumSavedInstances() do
        local name, _, _, _, locked, _, _, _, _, difficultyName, numEncounters, encounterProgress, _, journalInstanceID = GetSavedInstanceInfo(i)
        if locked then
            private.Debug(name, difficultyName, encounterProgress, "/", numEncounters, journalInstanceID);

            if not private.savedInstances[journalInstanceID] then
                private.savedInstances[journalInstanceID] = { }
            end
            private.savedInstances[journalInstanceID][difficultyName] = encounterProgress .. "/" .. numEncounters
        end
    end
end

local WDL = CreateFrame("Frame")

function WDL:OnEvent(event, ...)
    self[event](self, event, ...)
end

function WDL:BOSS_KILL()
    RequestRaidInfo()
end

function WDL:UPDATE_INSTANCE_INFO()
    UpdateSavedInstances()
end

WDL:RegisterEvent("BOSS_KILL")
WDL:RegisterEvent("UPDATE_INSTANCE_INFO")
WDL:SetScript("OnEvent", WDL.OnEvent)
