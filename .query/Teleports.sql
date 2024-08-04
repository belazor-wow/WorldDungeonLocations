SELECT DISTINCT result AS result
FROM (
    SELECT -- dungeon teleports
        ji.ID,
        CONCAT('    [', ji.ID, '] = ', s.ID, ', -- ', s.NameSubtext_lang) AS result
    FROM
        Spell s
        JOIN Achievement a ON (
            a.Title_lang LIKE CONCAT('keystone hero: %', s.NameSubtext_lang, '%')
            OR a.Title_lang LIKE CONCAT('%', s.NameSubtext_lang, '%: Gold')
        )
        LEFT JOIN JournalInstance ji ON s.NameSubtext_lang LIKE CONCAT('%', ji.Name_lang, '%')
    WHERE
        s.Description_lang LIKE 'Teleport to the entrance to %'

UNION ALL
    SELECT -- raid teleports
        ji.ID,
        CONCAT('    [', ji.ID, '] = ', s.ID, ', -- ', s.NameSubtext_lang) AS result
    FROM
        Spell s
        LEFT JOIN JournalInstance ji ON s.NameSubtext_lang LIKE CONCAT('%', ji.Name_lang, '%')
    WHERE
        s.NameSubtext_lang IS NOT NULL AND s.Description_lang LIKE 'Teleport to the entrance of %'
) q
ORDER BY q.ID
