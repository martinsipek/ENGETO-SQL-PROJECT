-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH prices_year AS ( -- CTE pro výpočet průměrné ceny všech potravin podle roků
    SELECT
        msp.year,
        ROUND(AVG(average_price)::NUMERIC, 2) AS average_price
    FROM t_martin_sipek_project_SQL_primary_final msp
    GROUP BY year
),
price_changes AS ( -- meziroční změna průměrné ceny potravin
    SELECT
        py.year,
        py.average_price,
        LAG(py.average_price) OVER (ORDER BY py.year) AS previous_price,
        ROUND(
            CASE 
                WHEN LAG(py.average_price) OVER (ORDER BY py.year) IS NULL THEN NULL
                ELSE 100.0 * (py.average_price - LAG(py.average_price) OVER (ORDER BY py.year)) / 
                           LAG(py.average_price) OVER (ORDER BY py.year)
            END, 2
        ) AS price_growth_percent
    FROM prices_year py
),
wages_year AS ( -- CTE pro výpočet průměrné mzdy dle let
    SELECT
        year,
        ROUND(AVG(average_monthly_wage)::NUMERIC, 2) AS average_wage
    FROM t_martin_sipek_project_SQL_primary_final
    GROUP BY year
),
wage_changes AS ( -- meziroční změna průměrné mzdy
    SELECT
        wy.year,
        wy.average_wage,
        LAG(wy.average_wage) OVER (ORDER BY wy.year) AS previous_wage,
        ROUND(
            CASE 
                WHEN LAG(wy.average_wage) OVER (ORDER BY wy.year) IS NULL THEN NULL
                ELSE 100.0 * (wy.average_wage - LAG(wy.average_wage) OVER (ORDER BY wy.year)) / 
                           LAG(wy.average_wage) OVER (ORDER BY wy.year)
            END, 2
        ) AS wage_growth_percent
    FROM wages_year wy
),
final AS ( -- porovnání růstu cen potravin vs mezd
    SELECT
        pc.year,
        pc.price_growth_percent,
        wc.wage_growth_percent,
        ROUND(pc.price_growth_percent - wc.wage_growth_percent, 2) AS difference_percent
    FROM price_changes pc
    JOIN wage_changes wc ON pc.year = wc.year
)
SELECT *
FROM final
WHERE difference_percent > 10
ORDER BY difference_percent DESC;

