SELECT
    CONCAT(
        '    { journalInstanceID = ', ji.ID,
        ', areaPoiID = ', apoi.ID,
        ', atlasName = ', CASE WHEN apoi.UiTextureAtlasMemberID = 6091 THEN '"Dungeon"' ELSE '"Raid"' END,
        ', pos0 = ', apoi.Pos_0,
        ', pos1 = ', apoi.Pos_1,
        ', continentID = ', apoi.ContinentID,
        CASE WHEN pc.RaceMasks_0 < 0 THEN ', faction = "Alliance"' WHEN pc.RaceMasks_0 > 0 THEN ', faction = "Horde"' ELSE '' END,
        ' }, -- ', ji.Name_lang) AS data
FROM JournalInstance ji
LEFT JOIN AreaPOI apoi ON (
    ji.Name_lang = apoi.Name_lang
    OR (
        (ji.ID = 63 AND apoi.ID = 6500) # "Deadmines" vs "The Deadmines"
        OR (ji.ID = 72 AND apoi.ID = 6516) # "Bastion of Twilight" vs "The Bastion of Twilight"
    )
)
LEFT JOIN PlayerCondition pc ON apoi.PlayerConditionID = pc.ID
WHERE
    apoi.UiTextureAtlasMemberID IN (6091, 6092) # Dungeon or Raid atlas respectively
ORDER BY ji.ID, apoi.ID
