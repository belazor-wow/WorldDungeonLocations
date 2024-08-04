SELECT DISTINCT result AS result
FROM (
    SELECT -- dungeon teleports
        ji.ID,
        CONCAT('        [', ji.ID, '] = ', s.ID, ', -- ', CASE WHEN sla.RaceMask > 0 THEN 'ALLIANCE - ' WHEN sla.RaceMask < 0 THEN 'HORDE - ' ELSE '' END, s.NameSubtext_lang) AS result,
        CASE WHEN sla.RaceMask > 0 THEN 1 WHEN sla.RaceMask < 0 THEN 2 ELSE 3 END AS categoryOrder
    FROM
        Spell s
        JOIN Achievement a ON (
            a.Title_lang LIKE CONCAT('keystone hero: %', s.NameSubtext_lang, '%')
            OR a.Title_lang LIKE CONCAT('%', s.NameSubtext_lang, '%: Gold')
        )
        LEFT JOIN JournalInstance ji ON s.NameSubtext_lang LIKE CONCAT('%', ji.Name_lang, '%')
        LEFT JOIN SkillLineAbility sla ON sla.Spell = s.ID
    WHERE
        s.Description_lang LIKE 'Teleport to the entrance to %'

UNION ALL
    SELECT -- raid teleports
        ji.ID,
        CONCAT('        [', ji.ID, '] = ', s.ID, ', -- Raid: ', s.NameSubtext_lang) AS result,
        4 AS categoryOrder
    FROM
        Spell s
        LEFT JOIN JournalInstance ji ON s.NameSubtext_lang LIKE CONCAT('%', ji.Name_lang, '%')
    WHERE
        s.NameSubtext_lang IS NOT NULL AND s.Description_lang LIKE 'Teleport to the entrance of %'
) q
ORDER BY q.categoryOrder, q.ID
