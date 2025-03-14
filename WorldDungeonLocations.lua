local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

---@type Array<Dictionary<string>>
private.savedInstances = {}

--- @type table<number, table[]> # mapId => { { position: {x: number, y: number}, childMapIds: number[], areaId: number? } }
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
            ["position"] = {x = 0.34749120473862, y = 0.84045135974884},
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

    -- Caverns of Time
    [71] = {
        {
            ["position"] = {x = 0.64903825521469, y = 0.49888265132904},
            ["childMapIds"] = {75}
        }
    }
}

private.MapLegendData = {
    CategoryTitle = AddOnFolderName,
    CategoryData = {
        {
            Name = "WDLMapLegendMultiDungeonButton",
            Text = L["MULTIPLE_INSTANCES"],
            Tooltip = L["MULTIPLE_INSTANCES_DESCR"],
            TemplateNames = {"WDLMultiDungeonEntrancePinTemplate"}
        },
    }
};

---@type Array<UiMapDetails>
private.mapInfo = {}

---@param mapId number
---@return UiMapDetails
private.GetMapInfo = function(mapId)
    if not private.mapInfo[mapId] then
        private.mapInfo[mapId] = C_Map.GetMapInfo(mapId)
    end

    return private.mapInfo[mapId]
end

---@type Array<string>
private.areaNames = {}

---@param areaId number
---@return string
private.GetAreaName = function(areaId)
    if not private.areaNames[areaId] then
        private.areaNames[areaId] = C_Map.GetAreaInfo(areaId)
    end

    return private.areaNames[areaId]
end

--- @return WDL_TeleportButton
local function createAndInitTeleportButton()
    --- @class WDL_TeleportButton: Button
    local teleportButton = CreateFrame('Button', nil, UIParent, 'InsecureActionButtonTemplate')
    teleportButton:Hide()
    teleportButton:SetFrameLevel(9999) -- make sure we render high
    teleportButton:SetAttribute('pressAndHoldAction', '1'); -- ensure it casts on down, regardless of the ActionButtonUseKeyDown cvar
    teleportButton:RegisterForClicks('AnyDown');
    teleportButton:SetAttribute('type', 'spell');

    teleportButton:SetScript('OnEnter', function(self, ...)
        if self.currentParent then self.currentParent:GetScript('OnEnter')(self.currentParent, ...) end
    end);
    teleportButton:SetScript('OnLeave', function(self, ...)
        if self.currentParent then self.currentParent:GetScript('OnLeave')(self.currentParent, ...) end
    end);

    teleportButton:RegisterEvent('MODIFIER_STATE_CHANGED');
    teleportButton:RegisterEvent('PLAYER_REGEN_DISABLED');
    teleportButton:RegisterEvent('PLAYER_REGEN_ENABLED');
    teleportButton:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end);
    function teleportButton:MODIFIER_STATE_CHANGED()
        if self.currentSpell and not InCombatLockdown() then
            if IsShiftKeyDown() and not self:IsShown() then
                self:SetAttribute('spell', self.currentSpell);
                self:SetParent(self.currentParent);
                self:SetAllPoints(self.currentParent);
                self:Show();
            elseif not IsShiftKeyDown() then
                self:Hide();
            end
        end
    end
    function teleportButton:PLAYER_REGEN_DISABLED()
        self:Hide();
    end
    function teleportButton:PLAYER_REGEN_ENABLED()
        self:MODIFIER_STATE_CHANGED();
    end

    function teleportButton:SetParentAndSpell(parent, spellID)
        self.currentParent = parent;
        self.currentSpell = spellID;
        self:MODIFIER_STATE_CHANGED();
    end

    return teleportButton;
end
-- Create a shared teleport button
private.teleportButton = createAndInitTeleportButton();

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

function WDL:PLAYER_LOGIN()
    for _, category in ipairs(MapLegendScrollFrame.ScrollChild:GetLayoutChildren()) do
        if category.TitleText:GetText() == MAP_LEGEND_CATEGORY_ACTIVITIES then
            for _, button in ipairs(category:GetLayoutChildren()) do
                if button.nameText == MAP_LEGEND_DUNGEON or button.nameText == MAP_LEGEND_RAID then
                    table.insert(button.templates, "WorldDungeonEntrancePinTemplate")
                end

                if button.nameText == MAP_LEGEND_DELVE then
                    table.insert(button.templates, "WDLDelveEntrancePinTemplate")
                end
            end
        end
    end

    local index = 3;
    local category = CreateFrame("Frame", private.MapLegendData.CategoryTitle, QuestMapFrame.MapLegend.ScrollFrame.ScrollChild, "MapLegendCategoryTemplate", index);
    category.TitleText:SetText(private.MapLegendData.CategoryTitle);
    category.layoutIndex = index;
    category:Show();

    local buttons = {};
    for i, categoryData in ipairs(private.MapLegendData.CategoryData) do
        local button = CreateFrame("Button", categoryData.Name, category, "WDLMapLegendButtonTemplate", i);
        button:InitializeButton(categoryData, i);
        table.insert(buttons, button);
    end

    local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 2, 0, 5);
    local anchor = CreateAnchor("TOPLEFT", category, "TOPLEFT", 0, 0);
    AnchorUtil.GridLayout(buttons, anchor, layout);

    category:Layout();
end

WDL:RegisterEvent("BOSS_KILL")
WDL:RegisterEvent("UPDATE_INSTANCE_INFO")
WDL:RegisterEvent("PLAYER_LOGIN")
WDL:SetScript("OnEvent", WDL.OnEvent)
