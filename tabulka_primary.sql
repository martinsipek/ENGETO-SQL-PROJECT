-- Vytvoření tabulky t_martin_šípek_project_SQL_primary_final 
-- (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) 

-- Na konec dokumentu byl doplněn další způsob vytvoření tabulky a následné naplnění daty dle doporučení od lektora.

-- ZOBRAZENÍ DAT Z TABULKY:

SELECT *
FROM t_martin_sipek_project_SQL_primary_final;


-- VYTVOŘENÍ TABULKY:

CREATE TABLE t_martin_sipek_project_SQL_primary_final AS
WITH wages AS ( -- CTE pro výpočet průměrné měsíční mzdy dle roku, kvartálu a odvětví
    SELECT
        cp.payroll_year AS year,
        cp.payroll_quarter AS quarter,
        cp.industry_branch_code AS industry_code,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_monthly_wage
    FROM czechia_payroll cp
    WHERE 
        cp.value_type_code = 5958 AND
        cp.unit_code = 200 AND
        cp.calculation_code = 100
    GROUP BY
        cp.payroll_year,
        cp.payroll_quarter,
        cp.industry_branch_code
),
prices AS ( -- CTE pro výpočet průměrné ceny potravin dle roku, kvartálu a kategorie
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        EXTRACT(QUARTER FROM cp.date_from) AS quarter,
        cp.category_code,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    GROUP BY
        year, 
        quarter, 
        cp.category_code
),
common_years AS ( -- CTE pro zjištění společného časového období (rok + kvartál) stejného v obou tabulkách
    SELECT DISTINCT
        w.year, 
        w.quarter
    FROM wages w
    INNER JOIN prices p ON w.year = p.year AND w.quarter = p.quarter
)
SELECT -- sjednocení mezd a cen pouze za období, které je dostupné ve wages a prices
    w.year,
    w.quarter,
    w.industry_code,
    w.average_monthly_wage,
    p.category_code,
    p.average_price
FROM wages w
JOIN prices p ON w.year = p.year AND w.quarter = p.quarter
JOIN common_years cy ON w.year = cy.year AND w.quarter = cy.quarter;



-- DALŠÍ MOŽNÝ ZPŮSOB VYTVOŘENÍ A NAPLNĚNÍ TABULKY DLE POZNÁMKY/DOPORUČENÍ V RÁMCI HODNOCENÍ OD LEKTORA:

-- ZOBRAZENÍ DAT Z TABULKY:

SELECT *
FROM t_martin_sipek_project_SQL_primary_final_2;


-- 1) Vytvoření tabulky a definice sloupců.

CREATE TABLE t_martin_sipek_project_SQL_primary_final_2 ( -- tabulka pojmenována "2", kvůli druhé možné verzi vytvoření
    year INTEGER,
    quarter INTEGER,
    industry_code VARCHAR,
    average_monthly_wage NUMERIC,
    category_code VARCHAR,
    average_price NUMERIC
);

-- 2) Naplnění tabulky daty.

INSERT INTO t_martin_sipek_project_SQL_primary_final_2
WITH wages AS (
    SELECT
        cp.payroll_year AS year,
        cp.payroll_quarter AS quarter,
        cp.industry_branch_code AS industry_code,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_monthly_wage
    FROM czechia_payroll cp
    WHERE 
        cp.value_type_code = 5958 AND
        cp.unit_code = 200 AND
        cp.calculation_code = 100
    GROUP BY
        cp.payroll_year,
        cp.payroll_quarter,
        cp.industry_branch_code
),
prices AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS year,
        EXTRACT(QUARTER FROM cp.date_from) AS quarter,
        cp.category_code,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_price
    FROM czechia_price cp
    GROUP BY
        year, 
        quarter, 
        cp.category_code
),
common_years AS (
    SELECT DISTINCT
        w.year, 
        w.quarter
    FROM wages w
    INNER JOIN prices p ON w.year = p.year AND w.quarter = p.quarter
)
SELECT
    w.year,
    w.quarter,
    w.industry_code,
    w.average_monthly_wage,
    p.category_code,
    p.average_price
FROM wages w
JOIN prices p ON w.year = p.year AND w.quarter = p.quarter
JOIN common_years cy ON w.year = cy.year AND w.quarter = cy.quarter;
