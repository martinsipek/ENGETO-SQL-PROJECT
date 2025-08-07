-- Finální SQL skript pro odpověď na výzkumnou otázku:
-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH average_salaries AS ( -- CTE pro výpočet průměrné mzdy zaokrouhlené na 2 desetinná místa dle let, kvartálů a odvětví
    SELECT
        cp.payroll_year,
        cp.payroll_quarter,
        cp.industry_branch_code,
        ROUND(AVG(cp.value), 2) AS average_salary
    FROM czechia_payroll cp
    GROUP BY 
        cp.payroll_year, 
        cp.payroll_quarter, 
        cp.industry_branch_code
)
SELECT
    asa.payroll_year,
    asa.payroll_quarter,
    asa.industry_branch_code,
    cpib.name,
    asa.average_salary,
    LAG(asa.average_salary) OVER ( -- LAG bere průměrnou mzdu z předchozího roku ("average_salary")
        PARTITION BY -- data podle odvětví (kódu) a kvartálu
        	asa.industry_branch_code, 
        	asa.payroll_quarter
        ORDER BY 
        	asa.payroll_year
    ) AS previous_year_salary,
    ROUND( -- výpočet nárůstu/poklesu mezd v procentech
        CASE
            WHEN LAG(asa.average_salary) OVER ( -- bere průměrnou hodnotu z předchozího roku pro stejné odvětví a kvartál 
                PARTITION BY -- data podle odvětví (kódu) a kvartálu
                	asa.industry_branch_code, 
                	asa.payroll_quarter
                ORDER BY
                	asa.payroll_year
            ) IS NULL THEN NULL -- pokud je předchozí hodnota NULL, vypíše NULL
            ELSE 100 * (asa.average_salary - LAG(asa.average_salary) OVER ( -- výpočet nárůstu/poklesu v procentech ((100 * aktuální prům. mzda - předchozí prům. mzda) / předchozí prům. mzda)
                PARTITION BY 
                	asa.industry_branch_code, 
                	asa.payroll_quarter
                ORDER BY 
                	asa.payroll_year
            )) / LAG(asa.average_salary) OVER ( 
                PARTITION BY 
                	asa.industry_branch_code, 
                	asa.payroll_quarter
                ORDER BY 
                	asa.payroll_year
            )
        END, 2 -- zaokrouhlení výsledku na 2 desetinná místa
    ) AS difference_in_percentage
FROM average_salaries asa
JOIN czechia_payroll_industry_branch cpib ON asa.industry_branch_code = cpib.code
ORDER BY 
    cpib.name, 
    asa.payroll_quarter, 
    asa.payroll_year;

