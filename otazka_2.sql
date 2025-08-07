-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT
    amw.year,
    amw.quarter,
    cpib.name,
    CASE -- přejmenování kódů kategorií na srozumitelné a přehledné názvy
        WHEN aps.category_code = '111301' THEN 'Chléb'
        WHEN aps.category_code = '114201' THEN 'Mléko'
        ELSE 'Neznámé'
    END AS food_type,
    ROUND(amw.average_monthly_wage::NUMERIC, 2) AS average_monthly_wage, -- zaokrouhlení průměrné měsíční mzdy na 2 desetinná místa
    ROUND(aps.average_price::NUMERIC, 2) AS average_price, -- zaokrouhlení průměrné ceny na 2 desetinná místa
    ROUND(amw.average_monthly_wage::NUMERIC / NULLIF(aps.average_price::NUMERIC, 0), 2) AS pieces_can_be_purchased -- výpočet, kolik kusů potravin lze zakoupit (NULLIF pro případ, aby nedošlo k dělení nulou)
FROM ( -- vnořený SELECT pro výpočet průměrné ceny pro chleba a mléko
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        EXTRACT(QUARTER FROM cp.date_from) AS quarter,
        cp.category_code,
        AVG(cp.value) AS average_price
    FROM czechia_price cp
    WHERE cp.category_code IN ('111301', '114201')
    GROUP BY 
    	year, 
    	quarter, 
    	cp.category_code
) aps
JOIN ( -- vnořený SELECT pro výpočet průměrné mesíční mzdy
    SELECT
        cp2.payroll_year AS year,
        cp2.payroll_quarter AS quarter,
        cp2.industry_branch_code,
        AVG(cp2.value) AS average_monthly_wage
    FROM czechia_payroll cp2
    WHERE 
        cp2.value_type_code = 5958
        AND cp2.unit_code = 200           
        AND cp2.calculation_code = 100    
    GROUP BY 
    	year, 
    	quarter, 
    	cp2.industry_branch_code
) amw ON amw.year = aps.year AND amw.quarter = aps.quarter
JOIN czechia_payroll_industry_branch cpib ON amw.industry_branch_code = cpib.code -- JOIN tabulku pro doplnění názvů odvětví
WHERE -- doplnění srovnatelného období 
    (amw.year = 2006 AND amw.quarter = 1)
    OR
    (amw.year = 2018 AND amw.quarter = 4)
ORDER BY 
	amw.year, 
	amw.quarter, 
	cpib.name, 
	food_type;
