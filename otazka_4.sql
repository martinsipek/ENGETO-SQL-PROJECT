-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?


-- POMOCNÁ DATA:

SELECT *
FROM czechia_price;

-- FINÁLNÍ SQL SKRIPT NAVAZUJÍCÍ NA KROKY VÝŠE:

WITH prices_year AS ( -- CTE pro výpis průměrné ceny všech potravin podle roků
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    GROUP BY 
    	year
),
price_changes AS ( -- CTE pro meziroční nárůst cen, porovnává cenu roku ku roku předchozímu a vrací %
    SELECT
        py.year,
        py.average_price,
        LAG(average_price) OVER (ORDER BY year) AS previous_price, 
        ROUND (
            CASE 
                WHEN LAG(average_price) OVER (
                	ORDER BY 
                		py.year) 
                	IS NULL THEN NULL -- podmínka, aby nedošlo k dělení nulou v případě, že jsou nějaké hodnoty NULL
                ELSE 100.0 * (py.average_price - LAG(py.average_price) OVER ( -- výpočet procentuální změny
                	ORDER BY 
                		py.year)
                	) 
                     / LAG(py.average_price) OVER (
                     ORDER BY 
                     	py.year)
            END, 2
        ) AS price_growth_percent -- nárůst/pokles cen v procentech
    FROM prices_year py
),
wages_year AS ( -- CTE pro výpočet průměrné mzdy 
    SELECT
        cp.payroll_year AS year,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_wage
    FROM czechia_payroll cp
    GROUP BY 
    	cp.payroll_year
),
wage_changes AS ( -- CTE pro výpočet změn v rámci mezd
    SELECT
        wy.year,
        wy.average_wage,
        LAG(wy.average_wage) OVER (ORDER BY wy.year) AS previous_wage,
        ROUND(
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
            END, 2
        ) AS wage_growth_percent -- růst mezd v procentech
    FROM wages_year wy
),
final AS ( -- propojení změn u mezd a u cen potravin dle let a výpočet rozdílu v procentech
    SELECT
        pc.year,
        pc.price_growth_percent,
        wc.wage_growth_percent,
        ROUND(pc.price_growth_percent - wc.wage_growth_percent, 2) AS difference_percent
    FROM price_changes pc
    JOIN wage_changes wc ON pc.year = wc.year
)
SELECT *
FROM final fin
WHERE 
	fin.difference_percent > 10
ORDER BY 
	fin.difference_percent DESC;
