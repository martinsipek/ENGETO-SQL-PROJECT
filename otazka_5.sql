-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH gdp_cz AS ( -- výběr dat z t_martin_sipek_project_SQL_secondary_final
    SELECT
        mss.year, 
        mss.gdp 
    FROM t_martin_sipek_project_SQL_secondary_final mss
    WHERE country = 'Czech Republic' 
),
gdp_changes AS ( -- výpočet meziročních změn HDP + posunutí o 1 rok dopředu (pro navazující srovnání s mzdami a cenami)
    SELECT
        year + 1 AS shifted_year, -- posun o 1 rok dopředu
        gdp, 
        LAG(gdp) OVER (ORDER BY year) AS previous_gdp, 
        CASE 
            WHEN LAG(gdp) OVER (ORDER BY year) IS NULL THEN NULL 
            ELSE ROUND( -- výpočet změny v procentech
                ((gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year))::numeric * 100, 2
            )
        END AS gdp_growth_percent -- meziroční změna HDP v procentech
    FROM gdp_cz
),
wages_year AS ( -- výpočet průměrné mzdy podle jednotlivých let
    SELECT
        msp.year,
        ROUND(AVG(average_monthly_wage)::numeric, 2) AS average_wage 
    FROM t_martin_sipek_project_SQL_primary_final msp
    GROUP BY year
),
wage_changes AS ( -- výpočet meziročního růstu mezd
    SELECT
        year,
        average_wage,
        LAG(average_wage) OVER (ORDER BY year) AS previous_wage,
        CASE 
            WHEN LAG(average_wage) OVER (ORDER BY year) IS NULL THEN NULL
            ELSE ROUND(
                ((average_wage - LAG(average_wage) OVER (ORDER BY year)) / LAG(average_wage) OVER (ORDER BY year))::numeric * 100, 2
            )
        END AS wage_growth_percent -- meziroční změna mezd v procentech
    FROM wages_year
),
prices_year AS ( -- výpočet průměrné ceny potravin podle jednotlivých let
    SELECT
        msp.year,
        ROUND(AVG(average_price)::numeric, 2) AS average_price 
    FROM t_martin_sipek_project_SQL_primary_final msp
    GROUP BY year
),
price_changes AS ( -- výpočet meziročního růstu cen potravin
    SELECT
        year,
        average_price,
        LAG(average_price) OVER (ORDER BY year) AS previous_price,
        CASE 
            WHEN LAG(average_price) OVER (ORDER BY year) IS NULL THEN NULL
            ELSE ROUND(
                ((average_price - LAG(average_price) OVER (ORDER BY year)) / LAG(average_price) OVER (ORDER BY year))::numeric * 100, 2
            )
        END AS price_growth_percent -- meziroční změna cen potravin v procentech
    FROM prices_year
),
combined_growth AS ( -- spojení všech výpočtů dohromady
    SELECT
        w.year, 
        g.gdp_growth_percent, -- meziroční růst HDP 
        w.wage_growth_percent, -- meziroční růst mezd
        p.price_growth_percent -- meziroční růst cen potravin
    FROM gdp_changes g
    JOIN wage_changes w ON g.shifted_year = w.year 
    JOIN price_changes p ON g.shifted_year = p.year
)
SELECT *
FROM combined_growth
ORDER BY year; 
