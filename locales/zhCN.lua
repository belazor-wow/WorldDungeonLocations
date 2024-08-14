-- WorldDungeonLocations Locale
-- Please use the Localization App on CurseForge to update this
-- https://legacy.curseforge.com/wow/addons/worlddungeonlocations/localization

-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string

---@type Localizations?
local L = LibStub("AceLocale-3.0"):NewLocale(AddOnFolderName, "zhCN", false)

if not L then
    return
end

--@localization(locale="zhCN", format="lua_additive_table", handle-unlocalized="ignore")@
