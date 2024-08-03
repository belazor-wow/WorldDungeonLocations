local private = select(2, ...) ---@class PrivateNamespace
private.savedInstances = {}

private.mapOverrides = {
    [36] = {
        -- ["comboName"] = "BWL / UBRS / LBRS / BRD / MC",
        ["position"] = {x = 0.21056824922562, y = 0.38353234529495},
        ["childMapIds"] = {33, 35}
    },
    [32] = {
        -- ["comboName"] = "BWL / UBRS / LBRS / BRD / MC",
        ["position"] = {x = 0.3478, y = 0.8392},
        ["childMapIds"] = {33, 35}
    },
}

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
