-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH average_salaries AS ( -- CTE výpočet průměrné měsíční mzdy podle roku, kvartálu a odvětví zaokrouhlené na 2 desetinná místa
    SELECT
        year AS payroll_year,
        quarter AS payroll_quarter,
        industry_code AS industry_branch_code,
        ROUND(AVG(average_monthly_wage), 2) AS average_salary
    FROM t_martin_sipek_project_SQL_primary_final
    WHERE average_monthly_wage IS NOT NULL
    GROUP BY 
        year, 
        quarter, 
        industry_code
)
SELECT
    asa.payroll_year,
    asa.payroll_quarter,
    asa.industry_branch_code,
    cpib.name,
    asa.average_salary,
    LAG(asa.average_salary) OVER (
        PARTITION BY 
        	asa.industry_branch_code, 
        	asa.payroll_quarter
        ORDER BY 
        	asa.payroll_year
    ) AS previous_year_salary,
    ROUND( -- výpočet meziroční změny mezd v procentech
        CASE
            WHEN LAG(asa.average_salary) OVER (
                PARTITION BY 
                	asa.industry_branch_code, 
                	asa.payroll_quarter
                ORDER BY 
                	asa.payroll_year
            ) IS NULL THEN NULL
            ELSE 100 * (asa.average_salary - LAG(asa.average_salary) OVER (
                PARTITION BY 
                	asa.industry_branch_code, 
                	asa.payroll_quarter
                ORDER BY 
                	asa.payroll_year
            )) / LAG(asa.average_salary) OVER ( -- výpočet rozdílu v procentech oproti předchozímu roku
                PARTITION BY 
                	asa.industry_branch_code, 
                	asa.payroll_quarter
                ORDER BY 
                	asa.payroll_year
            )
        END, 2
    ) AS difference_in_percentage
FROM average_salaries asa
JOIN czechia_payroll_industry_branch cpib ON asa.industry_branch_code = cpib.code -- JOIN tabulky pro doplnění názvů odvětví pro větší přehlednost
ORDER BY 
    cpib.name, 
    asa.payroll_quarter, 
    asa.payroll_year;

