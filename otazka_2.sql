-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT
    msp.year, 
    msp.quarter, 
    cpib.name, 
   		CASE -- přejmenování kódů kategorie na názvy pro lepší přehlednost 
        	WHEN msp.category_code = '111301' THEN 'Chléb'
        	WHEN msp.category_code = '114201' THEN 'Mléko'
        	ELSE 'Neznámé' 
    	END AS food_type,
    ROUND(msp.average_monthly_wage::NUMERIC, 2) AS average_monthly_wage, -- výpočet průměrné měsíční mzdy
    ROUND(msp.average_price::NUMERIC, 2) AS average_price, -- výpočet průměrné ceny potravin
    ROUND( 
        msp.average_monthly_wage::NUMERIC / NULLIF(msp.average_price::NUMERIC, 0), -- kolik kusů dané potraviny je možné koupit za průměrnou mzdu
        2
    ) AS pieces_can_be_purchased
FROM t_martin_sipek_project_SQL_primary_final msp -- čerpání z finální tabulky obsahující mzdy a ceny
JOIN czechia_payroll_industry_branch cpib ON msp.industry_code = cpib.code -- JOIN tabulky pro oplnění názvů odvětví z tabulky
WHERE 
    msp.category_code IN ('111301', '114201') 
    AND (
        (msp.year = 2006 AND msp.quarter = 1) OR 
        (msp.year = 2018 AND msp.quarter = 4)    
    )
ORDER BY 
    msp.year, 
    msp.quarter, 
    cpib.name, 
    food_type; 
