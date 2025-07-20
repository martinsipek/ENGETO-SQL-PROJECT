-- Postup a finální SQL skript pro odpověď na výzkumnou otázku:
-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?


-- POMOCNÁ DATA:

SELECT *
FROM economies;

SELECT *
FROM czechia_price;

SELECT *
FROM czechia_payroll;

-- POSTUP:

WITH gdp_cz AS ( -- meziroční změny HDP (GDP) pro CZ v rámci let
    SELECT
        e.country,
    	e.year,
        e.gdp
    FROM economies e
    WHERE 
    	e.country = 'Czech Republic'
),
gdp_changes AS ( -- meziroční změna HDP (GDP) v procentech
    SELECT
        gcz.country,
    	gcz.year,
        gcz.gdp,
        LAG(gcz.gdp) OVER (
        	ORDER BY 
        		gcz.year) AS previous_gdp,
    	  ROUND((
   			CASE
        		WHEN LAG(gcz.gdp) OVER (
        			ORDER BY 
        				year) 
        			IS NULL THEN NULL
        		ELSE 100.0 * (gcz.gdp - LAG(gcz.gdp) OVER (
        			ORDER BY 
        				year)
        				) 
        			/ LAG(gcz.gdp) OVER (
        			ORDER BY 
        				year)
    		END
				)::NUMERIC, 2) AS gdp_percent_growth
    FROM gdp_cz gcz
)
SELECT *
FROM gdp_changes gdpch
ORDER BY 
	gdpch.year;

--

WITH wages_year AS ( -- CTE pro výpočet meziroční změny mezd v ČR
    SELECT
        cp.payroll_year AS year,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_wage
    FROM czechia_payroll cp
    WHERE 
    	cp.value_type_code = 5958
    GROUP BY 
    	cp.payroll_year
),
wage_changes AS ( -- CTE pro výpočet meziroční změny mezd v procentech
    SELECT
        wy.year,
        wy.average_wage,
        LAG(wy.average_wage) OVER (
        	ORDER BY 
        		wy.year) AS previous_wage,
        ROUND((
            CASE 
                WHEN LAG(wy.average_wage) OVER (
                	ORDER BY 
                		wy.year) 
                	IS NULL THEN NULL
                ELSE 100.0 * (wy.average_wage - LAG(wy.average_wage) OVER (
                	ORDER BY 
                		wy.year)
                		)
                     / LAG(wy.average_wage) OVER (
                     ORDER BY 
                     	wy.year)
            END
        )::NUMERIC, 2) AS wage_growth_percent
    FROM wages_year wy
)
SELECT *
FROM wage_changes wch
ORDER BY 
	wch.year;

--

WITH prices_year AS ( -- CTE pro výpočet průměrné ceny všech potravin za každý rok 
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    GROUP BY 
    	year
),
price_changes AS ( -- CTE pro výpočet meziroční změna v procentech
    SELECT
        py.year,
        py.average_price,
        LAG(py.average_price) OVER (ORDER BY py.year) AS previous_price,
        ROUND((
            CASE 
                WHEN LAG(py.average_price) OVER (
                	ORDER BY 
                		py.year) 
                	IS NULL THEN NULL
                ELSE 100.0 * (py.average_price - LAG(py.average_price) OVER (
                	ORDER BY 
                		py.year))
                     / LAG(py.average_price) OVER (
                     ORDER BY 
                     	py.year)
            END)::NUMERIC, 2) AS price_growth_percent
    FROM prices_year py
)
SELECT *
FROM price_changes pch
ORDER BY 
	pch.year;


-- FINÁLNÍ SQL SKRIPT NAVAZUJÍCÍ NA KROKY VÝŠE:

WITH gdp_cz AS ( -- CTE pro získání dat z ČR
    SELECT
        e.country,
        e.year,
        e.gdp
    FROM economies e
    WHERE 
    	e.country = 'Czech Republic'
),
gdp_changes AS ( -- CTE pro výpočet meziročních změn HDP (GDP) + připočtení jednoho roku dopředu pro zjištění vlivu HDP (GDP) v dalším roce
    SELECT
        gcz.year + 1 AS shifted_year,
        gcz.gdp,
        LAG(gcz.gdp) OVER (ORDER BY gcz.year) AS previous_gdp,
        ROUND((
            CASE
                WHEN LAG(gcz.gdp) OVER (
                	ORDER BY 
                		gcz.year) 
                	IS NULL THEN NULL
                ELSE 100.0 * (gcz.gdp - LAG(gcz.gdp) OVER (
                	ORDER BY 
                		gcz.year)) 
                	/ LAG(gcz.gdp) OVER (
                	ORDER BY 
                		gcz.year)
            END)::NUMERIC, 2) AS gdp_growth_percent
    FROM gdp_cz gcz
),
wages_year AS ( -- CTE pro výpočet průměrné mzdy v ČR podle let
    SELECT
        cp.payroll_year AS year,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_wage
    FROM czechia_payroll cp
    WHERE 
    	cp.value_type_code = 5958
    GROUP BY 
    	cp.payroll_year
),
wage_changes AS ( -- CTE pro výpočet meziročního růstu mezd
    SELECT
        wy.year,
        wy.average_wage,
        LAG(wy.average_wage) OVER (ORDER BY wy.year) AS previous_wage,
        ROUND((
            CASE 
                WHEN LAG(wy.average_wage) OVER (
                	ORDER BY 
                		wy.year) 
                	IS NULL THEN NULL
                ELSE 100.0 * (wy.average_wage - LAG(wy.average_wage) OVER (
                	ORDER BY 
                		wy.year)) 
                	/ LAG(wy.average_wage) OVER (
                	ORDER BY 
                		wy.year)
            END)::NUMERIC, 2) AS wage_growth_percent
    FROM wages_year wy
),
prices_year AS ( -- CTE pro výpočet průměrné cen potravin podle let
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    GROUP BY 
    	year
),
price_changes AS ( -- CTE pro výpočet meziroční změny cen potravin
    SELECT
        py.year,
        py.average_price,
        LAG(py.average_price) OVER (
        	ORDER BY 
        		py.year) AS previous_price,
        ROUND((
            CASE 
                WHEN LAG(py.average_price) OVER (
                	ORDER BY 
                		py.year) 
                	IS NULL THEN NULL
                ELSE 100.0 * (py.average_price - LAG(py.average_price) OVER (
                	ORDER BY 
                		py.year)) 
                	/ LAG(py.average_price) OVER (
                	ORDER BY 
                		py.year)
            END
        )::NUMERIC, 2) AS price_growth_percent
    FROM prices_year py
),
combined_growth AS ( -- kompinace dat HDP (z předchozího roku), mzdy a ceny potravin (ze stejného roku)
    SELECT
        w.year,
        g.gdp_growth_percent,
        w.wage_growth_percent,
        p.price_growth_percent
    FROM gdp_changes g
    JOIN wage_changes w ON g.shifted_year = w.year
    JOIN price_changes p ON g.shifted_year = p.year
)
SELECT *
FROM combined_growth cgr
ORDER BY 
	year;
