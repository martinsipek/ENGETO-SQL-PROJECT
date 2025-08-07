-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 

WITH prices_year AS ( -- výpočet průměrné roční ceny potravin
    SELECT
        msp.year,
        msp.category_code, 
        ROUND(AVG(average_price)::NUMERIC, 2) AS average_price -- průměrná roční cena
    FROM t_martin_sipek_project_SQL_primary_final msp
    GROUP BY 
        year, 
        category_code
),
price_changes AS ( -- výpočet meziroční změny cen u jednotlivých potravin
    SELECT
        py.year, 
        py.category_code, 
        py.average_price, 
        LAG(py.average_price) OVER ( -- cena potraviny v předchozím roce
            PARTITION BY py.category_code -- pro každou potravinu 
            ORDER BY py.year
        ) AS previous_year_price,
        ROUND( -- výpočet meziročních změn v procentech
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
        ) AS price_changes_percent -- procentuální změna cen mezi jednotlivými roky
    FROM prices_year py
)
SELECT
    pc.category_code, 
    cpc.name AS food_type, 
    ROUND(AVG(pc.price_changes_percent)::NUMERIC, 2) AS average_annual_growth_percent -- průměrný roční růst ceny
FROM price_changes pc
JOIN czechia_price_category cpc ON pc.category_code = cpc.code -- JOIN tabulky pro zobrazení názvů potravin
GROUP BY 
    pc.category_code, 
    cpc.name
ORDER BY 
    average_annual_growth_percent ASC; 
