-- This CTE extracts only resolved chats
WITH chats_resolved AS (

    SELECT
        id,
        is_customer_initiated,
        chat_category_id,
        created_at_aedt,
        resolved_at_aedt,
        strftime(resolved_at_aedt, '%Y-%m-%d') AS resolution_date,
        extract(DOW FROM created_at_aedt) AS day_of_week,
        extract(HOUR FROM created_at_aedt) AS hour_of_day
    FROM {{ ref('stg__chats') }}
),

categories AS (
    -- Reference the categories table
    SELECT
        id AS category_id,
        parent_id,
        disabled
    FROM {{ ref('stg__categories') }}
),


-- 1. The date that saw the lowest number of chats resolved
lowest_resolved_chats AS (

    SELECT
        'Lowest Resolved Chats Date' AS stat,
        resolution_date,
        count(id) AS num_chats_resolved
    FROM chats_resolved
    WHERE resolved_at_aedt IS NOT null
    GROUP BY resolution_date
    ORDER BY count(id) ASC
    LIMIT 1

),

-- 2. The date that saw the highest number of chats resolved
highest_resolved_chats AS (

    SELECT
        'Highest Resolved Chats Date' AS stat,
        resolution_date,
        count(id) AS num_chats_resolved
    FROM chats_resolved
    WHERE resolved_at_aedt IS NOT null
    GROUP BY resolution_date
    ORDER BY count(id) DESC
    LIMIT 1
),


-- 3. The median number of customer-initiated chats resolved per day
median_chats AS (

    WITH customer_initiated_chats AS (
        SELECT
            resolution_date,
            count(id) AS num_customer_initiated_chats
        FROM chats_resolved
        WHERE
            resolved_at_aedt IS NOT null
            AND is_customer_initiated IS true
        GROUP BY resolution_date
    )

    SELECT
        'Median Customer-Initiated Chats Resolved per Day' AS stat,
        '', -- No date for this stat
        percentile_cont(0.5) WITHIN GROUP (
            ORDER BY num_customer_initiated_chats
        ) AS stat_value
    FROM customer_initiated_chats
),

-- 4. The ten most populous categories for chats created by customers
most_populous_categories AS (

    SELECT
        'Ten most Populous Categories for Chats created by Customers',
        coalesce(c.parent_id, c.category_id) AS parent_or_category_id,
        count(ch.chat_category_id) AS num_chats
    FROM chats_resolved AS ch
    INNER JOIN categories AS c
        ON ch.chat_category_id = c.category_id
    WHERE
        ch.is_customer_initiated = true
        AND c.disabled IS false
    GROUP BY parent_or_category_id
    ORDER BY num_chats DESC
    LIMIT 10
),

-- 5. The ten categories with the lowest resolution rate
lowest_resolution_rate AS (

    WITH resolution_rate AS (
        SELECT
            -- Use parent_id if it's not null, otherwise use category_id
            coalesce(c.parent_id, c.category_id) AS parent_or_category_id,
            count(ch.id) AS total_chats,
            sum(
                CASE WHEN ch.resolved_at_aedt IS NOT null THEN 1 ELSE 0 END
            ) AS resolved_chats
        FROM chats_resolved AS ch
        INNER JOIN categories AS c ON ch.chat_category_id = c.category_id
        GROUP BY parent_or_category_id
    )

    SELECT
        'Ten Categories with the Lowest Resolution Rate',
        parent_or_category_id AS category_id_or_parent,
        round(
            (resolved_chats::DECIMAL / total_chats) * 100, 2
        ) AS resolution_rate_percentage
    FROM resolution_rate
    ORDER BY resolution_rate_percentage ASC
    LIMIT 10
),


-- 6. The ten categories with the fastest resolution time
fastest_resolution_time AS (

    WITH resolution_times AS (
        SELECT
            coalesce(c.parent_id, c.category_id) AS parent_or_category_id,
            avg(
                extract(EPOCH FROM (ch.resolved_at_aedt - ch.created_at_aedt))
            ) AS avg_resolution_time_seconds
        FROM chats_resolved AS ch
        INNER JOIN categories AS c
            ON ch.chat_category_id = c.category_id
        WHERE ch.resolved_at_aedt IS NOT null
        GROUP BY parent_or_category_id
    )

    SELECT
        'Ten Categories with the Fastest Resolution Time',
        parent_or_category_id,
        round(
            avg_resolution_time_seconds / 3600, 2
        ) AS avg_resolution_time_hours
    FROM resolution_times
    ORDER BY avg_resolution_time_seconds ASC
    LIMIT 10
),

-- 7. The hourly distribution of chats by time-of-day and day-of-week
hourly_distribution AS (

    SELECT
        'Hourly Distribution',
        concat(day_of_week, '-', hour_of_day) AS resolution_date,
        count(*) AS num_chats
    FROM chats_resolved
    GROUP BY day_of_week, hour_of_day
    ORDER BY day_of_week, hour_of_day
)

SELECT * FROM lowest_resolved_chats
UNION ALL
SELECT * FROM highest_resolved_chats
UNION ALL
SELECT * FROM median_chats
UNION ALL
SELECT * FROM most_populous_categories
UNION ALL
SELECT * FROM lowest_resolution_rate
UNION ALL
SELECT * FROM fastest_resolution_time
UNION ALL
SELECT * FROM hourly_distribution
