SELECT
    CONCAT('        [', q.ID, '] = { ', GROUP_CONCAT(DISTINCT q.spellID SEPARATOR ', '), ' }, -- ', q.name) AS result
FROM (
    SELECT -- dungeon teleports
        ji.ID,
        s.ID as spellID,
        s.NameSubtext_lang as name,
        1 AS categoryOrder
    FROM
        Spell s
        JOIN Achievement a ON (
            a.Title_lang LIKE CONCAT('keystone hero: %', s.NameSubtext_lang, '%')
            OR a.Title_lang LIKE CONCAT('%', s.NameSubtext_lang, '%: Gold')
        )
        LEFT JOIN JournalInstance ji ON s.NameSubtext_lang LIKE CONCAT('%', ji.Name_lang, '%')
        LEFT JOIN SkillLineAbility sla ON sla.Spell = s.ID
    WHERE
        s.Description_lang LIKE 'Teleport to the entrance %'

UNION ALL
    SELECT -- raid teleports (also includes some dungeons, they'll have to manually filtered out
        ji.ID,
        s.ID as spellID,
        CONCAT('RAID: ', s.NameSubtext_lang) as name,
        2 AS categoryOrder
    FROM
        Spell s
        LEFT JOIN JournalInstance ji ON s.NameSubtext_lang LIKE CONCAT('%', ji.Name_lang, '%')
    WHERE
        s.NameSubtext_lang IS NOT NULL AND s.Description_lang LIKE 'Teleport to the entrance of %'
) q
GROUP BY q.ID, q.categoryOrder
ORDER BY q.categoryOrder, q.ID
