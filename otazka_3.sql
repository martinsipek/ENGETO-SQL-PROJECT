-- Postup a finální SQL skript pro odpověď na výzkumnou otázku:
-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 


-- POMOCNÁ DATA:

SELECT *
FROM czechia_price;

-- POSTUP:

SELECT -- výpis roku, kódu kategorie, názvu potraviny a výpočet průměrné ceny
    EXTRACT(YEAR FROM cp.date_from) AS year,
    cp.category_code,
    cpc.name AS food_type,
    ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
FROM czechia_price cp
JOIN czechia_price_category cpc ON cp.category_code = cpc.code -- JOIN tabulky pro získání názvů potravin
GROUP BY 
	year, 
	cp.category_code, 
	cpc.name
ORDER BY 
	cp.category_code, 
	year;

--

WITH prices_year AS ( -- CTE pro průměrné ceny potravin podle roku
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        cp.category_code,
        cpc.name AS food_type,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    JOIN czechia_price_category cpc ON cp.category_code = cpc.code -- JOIN tabulky pro získání názvů potravin
    GROUP BY 
    	year, 
    	cp.category_code, 
    	cpc.name
)
SELECT
    py.year,
    py.category_code,
    py.food_type,
    py.average_price,
    LAG(py.average_price) OVER ( -- výpočet průměrné ceny z předchozího roku
        PARTITION BY py.category_code
        ORDER BY py.year
    ) AS previous_year_price,
    ROUND( -- výpočet rozdílu v procentech meziročních změn (100 * (aktuální rok - předchozí rok) / předchozí rok)
        CASE 
            WHEN LAG(py.average_price) OVER (
                PARTITION BY 
                	py.category_code
                ORDER BY 
                	py.year
            ) IS NULL THEN NULL
            ELSE 100.0 * (py.average_price - LAG(py.average_price) OVER (
                PARTITION BY 
                	py.category_code
                ORDER BY 
                	py.year
            )) / LAG(py.average_price) OVER ( 
                PARTITION BY 
                	py.category_code
                ORDER BY 
                	py.year
            )
        END, 2) AS percent_price_change
FROM prices_year py
ORDER BY 
	py.category_code, 
	py.year;


-- FINÁLNÍ SQL SKRIPT NAVAZUJÍCÍ NA KROKY VÝŠE:

WITH prices_year AS ( -- CTE pro výpočet průměrné ceny potravin podle roku
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        cp.category_code,
        cpc.name AS food_type,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    JOIN czechia_price_category cpc ON cp.category_code = cpc.code
    GROUP BY 
    	year, 
    	cp.category_code, 
    	cpc.name
),
price_changes AS ( -- CTE pro výpočet meziročních změn cen u jednotlivých potravin
    SELECT
        py.year,
        py.category_code,
        py.food_type,
        py.average_price,
        LAG(py.average_price) OVER ( -- cena potraviny pro předchozí rok
            PARTITION BY 
            	py.category_code -- pro každou potravinu samostatně
            ORDER BY 
            	py.year
        ) AS previous_year_price,
        ROUND( -- výpočet rozdílu v procentech meziročních změn (100 * (aktuální rok - předchozí rok) / předchozí rok)
            CASE 
                WHEN LAG(py.average_price) OVER (
                    PARTITION BY py.category_code
                    ORDER BY py.year
                ) IS NULL THEN NULL
                ELSE 100.0 * (py.average_price - LAG(py.average_price) OVER (
                    PARTITION BY py.category_code
                    ORDER BY py.year
                )) / LAG(py.average_price) OVER (
                    PARTITION BY py.category_code
                    ORDER BY py.year
                )
            END, 2
        ) AS price_changes_percent
    FROM prices_year py
)
SELECT -- výpočet průměrného meziročního růstu ceny pro jednotlivé potraviny
    category_code,
    food_type,
    ROUND(AVG(price_changes_percent)::NUMERIC, 2) AS average_annual_growth_percent
FROM price_changes ps
GROUP BY 
	ps.category_code, 
	ps.food_type
ORDER BY 
	average_annual_growth_percent ASC;
