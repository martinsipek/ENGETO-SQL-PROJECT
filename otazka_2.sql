-- Postup a finální SQL skript pro odpověď na výzkumnou otázku:
-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


-- POMOCNÁ DATA:

SELECT *
FROM czechia_price;

SELECT *
FROM czechia_payroll;

SELECT *
FROM czechia_price_category;

-- Chléb = 111,301
-- Mléko = 114,201

-- value_type_code = 5958      	= průměrná hrubá mzda na jednoho zaměstnance
-- unit_code = 200 = tis. Kč 	= násobit x 1000
-- calculation_code = 100 		= fyzická osoba, nikoliv FTE

-- POSTUP:

SELECT * -- výpis všech dat pro chléb a mléko
FROM czechia_price cp
WHERE 
	cp.category_code IN ('111301', '114201')
LIMIT 20;

--

SELECT -- výpis "category_code" podle roku a kvartálu vč. průměrných cen u chleba a mléka
	EXTRACT (YEAR FROM cp.date_from) AS year,
	EXTRACT (QUARTER FROM cp.date_from) AS quarter,
	cp.category_code,
	ROUND(AVG(cp.value)::NUMERIC, 2) AS average_prize
FROM czechia_price cp
WHERE
	cp.category_code IN ('111301', '114201')
GROUP BY
	cp.category_code,	
	year,
	quarter
ORDER BY
	year,
	quarter;

--

SELECT -- výpočet průměrné měsíční mzdy u jednotlivých odvětví po letech a kvartálech
	cp.payroll_year,
	cp.payroll_quarter,
	cp.industry_branch_code,
	ROUND(AVG(cp.value)::NUMERIC, 2) AS average_monthly_wage
FROM czechia_payroll cp
GROUP BY
	cp.payroll_year,
	cp.payroll_quarter,
	cp.industry_branch_code
ORDER BY
	cp.payroll_year,
	cp.payroll_quarter;

--

-- value_type_code = 5958      	= průměrná hrubá mzda na jednoho zaměstnance
-- unit_code = 200 = tis. Kč 	= násobit x 1000
-- calculation_code = 100 		= fyzická osoba, nikoliv FTE

SELECT * -- kontrola dat dle podmínky WHERE
FROM czechia_payroll cp
WHERE 
    cp.value_type_code = 5958 
    AND cp.unit_code = 200   
    AND cp.calculation_code = 100    
LIMIT 20;

--

SELECT -- výpis jednotlivých let, kvartálů a jednotlivých odvětvích vč. jejich průměrných mezd u konkrétních dat dle podmínky WHERE
    cp.payroll_year,
    cp.payroll_quarter,
    cp.industry_branch_code,
    ROUND(AVG(cp.value)::NUMERIC, 2) AS average_monthly_wage 
FROM czechia_payroll cp
WHERE 
    cp.value_type_code = 5958
    AND cp.unit_code = 200           
    AND cp.calculation_code = 100    
GROUP BY 
	cp.payroll_year, 
	cp.payroll_quarter,
	cp.industry_branch_code
ORDER BY
	cp.payroll_year, 
	cp.payroll_quarter,
	cp.industry_branch_code;

--

SELECT -- JOIN tabulky "czechia_payroll_industry_branch" pro získání názvů odvětví
    cp.payroll_year,
    cp.payroll_quarter,
    cp.industry_branch_code,
    cpib.name,
    ROUND(AVG(cp.value)::NUMERIC, 2) AS average_monthly_wage 
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
WHERE 
    cp.value_type_code = 5958
    AND cp.unit_code = 200           
    AND cp.calculation_code = 100    
GROUP BY 
	cp.payroll_year, 
	cp.payroll_quarter,
	cp.industry_branch_code,
	cpib.name
ORDER BY
	cp.payroll_year, 
	cp.payroll_quarter,
	cp.industry_branch_code
	
-- 

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
JOIN czechia_payroll_industry_branch cpib ON amw.industry_branch_code = cpib.code -- JOIN pro doplnění názvu odvětví
ORDER BY 
	amw.year, 
	amw.quarter, 
	cpib.name, 
	food_type;

--

SELECT -- zjištění prvního a posledního období v tabulce "czechia_payroll"
    MIN(cp.payroll_year) AS first_year,
    MIN(cp.payroll_quarter) AS first_quarter,
    MAX(cp.payroll_year) AS last_year,
    MAX(cp.payroll_quarter) AS last_quarter
FROM czechia_payroll cp
WHERE 
    cp.value_type_code = 5958
    AND cp.unit_code = 200
    AND cp.calculation_code = 100;	

-- first_year = 2000
-- first_quarter = 1
-- last_year = 2021
-- last_quarter = 4

--

SELECT -- zjištění prvního a posledního období v tabulce "czechia_price"
    MIN(EXTRACT (YEAR FROM cp.date_from)) AS first_year,
    MIN(EXTRACT (quarter FROM cp.date_from)) AS first_quarter,
    MAX(EXTRACT (YEAR FROM cp.date_from)) AS last_year,
    MAX(EXTRACT (quarter FROM cp.date_from)) AS last_quarter
FROM czechia_price cp
WHERE 
	cp.category_code IN ('111301', '114201');	

-- first_year = 2006
-- first_quarter = 1
-- last_year = 2018
-- last_quarter = 4

-- Je třeba pracovat jen se společným obdobím = Q1/2006 - Q4/2018


-- FINÁLNÍ SQL SKRIPT NAVAZUJÍCÍ NA KROKY VÝŠE:

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
