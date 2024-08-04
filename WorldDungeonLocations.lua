local private = select(2, ...) ---@class PrivateNamespace
private.savedInstances = {}

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
