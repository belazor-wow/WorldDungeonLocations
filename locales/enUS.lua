-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations?
local L = LibStub("AceLocale-3.0"):NewLocale(AddOnFolderName, "enUS", true, true)

if not L then
    return
end

L["ALT_RIGHT_CLICK_TOMTOM_WAYPOINT"] = "<Alt Right Click to set TomTom waypoint>"
L["SHIFT_CLICK_TELEPORT_DUNGEON"] = "<Shift Click to teleport to dungeon>"
