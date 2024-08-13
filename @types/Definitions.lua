---@meta

-- ----------------------------------------------------------------------------
-- Types
-- ----------------------------------------------------------------------------
---@class Array<T>: { [integer]: T }
---@class Dictionary<T>: { [string]: T }
---@class Localizations: Dictionary<string>

---@class WDL_PinInfo
---@field areaPoiID number
---@field position Vector2DMixin
---@field zonePosition {mapID: number, position: Vector2DMixin}
---@field name string # Instance name
---@field description string # Localized "Dungeon" or "Raid"
---@field atlasName WDL_PinDescription
---@field journalInstanceID number
---@field faction WDL_Faction? # Only set when a pin is specific to a faction

---@alias WDL_PinDescription
---| '"Dungeon"' # Dungeon
---| '"Raid"' # Raid

---@alias WDL_Faction
---| '"Alliance"'
---| '"Horde"'
