local private = select(2, ...) ---@class PrivateNamespace
private.savedInstances = {}

local function UpdateSavedInstances()
    table.wipe(private.savedInstances)
    for i = 1, GetNumSavedInstances() do
        local name, _, _, _, locked, _, _, _, _, difficultyName, numEncounters, encounterProgress, _, journalInstanceID = GetSavedInstanceInfo(i)
        if locked then
            private.Debug(name, difficultyName, numEncounters, encounterProgress, journalInstanceID);

            if not private.savedInstances[journalInstanceID] then
                private.savedInstances[journalInstanceID] = { }
            end
            private.savedInstances[journalInstanceID][difficultyName] = encounterProgress .. "/" .. numEncounters
        end
    end
end

local WDE = CreateFrame("Frame")

function WDE:OnEvent(event, ...)
	self[event](self, event, ...)
end

function WDE:UPDATE_INSTANCE_INFO()
    UpdateSavedInstances()
end

WDE:RegisterEvent("UPDATE_INSTANCE_INFO")
WDE:SetScript("OnEvent", WDE.OnEvent)
