-- Vytvoření tabulky t_martin_šípek_project_SQL_secondary_final 
-- (pro dodatečná data o dalších evropských státech).


-- POMOCNÁ DATA:

SELECT *
FROM economies;

SELECT *
FROM countries;

-- ZOBRAZENÍ DAT Z TABULKY:

SELECT * 
FROM t_martin_sipek_project_SQL_secondary_final;


-- VYTVOŘENÍ TABULKY:

CREATE TABLE t_martin_sipek_project_SQL_secondary_final AS
SELECT
    eco.year,
	eco.country,
	eco.population,
	eco.gini,
    eco.gdp
FROM economies eco
JOIN countries cou ON eco.country = cou.country
WHERE 
    cou.continent = 'Europe'
    AND eco.year BETWEEN 2006 AND 2018
    AND eco.gdp IS NOT NULL
    AND eco.gini IS NOT NULL
    AND eco.population IS NOT NULL;


-- DALŠÍ MOŽNÝ ZPŮSOB VYTVOŘENÍ A NAPLNĚNÍ TABULKY DLE POZNÁMKY/DOPORUČENÍ V RÁMCI HODNOCENÍ OD LEKTORA:

-- ZOBRAZENÍ DAT Z TABULKY:

SELECT * 
FROM t_martin_sipek_project_SQL_secondary_final_2;

-- 1) Vytvoření tabulky a definice sloupců.

CREATE TABLE t_martin_sipek_project_SQL_secondary_final_2 ( -- tabulka pojmenována "2", kvůli druhé možné verzi vytvoření
    year INTEGER,
    country VARCHAR,
    population NUMERIC,
    gini NUMERIC,
    gdp NUMERIC
);

-- 2) Naplnění tabulky daty.

INSERT INTO t_martin_sipek_project_SQL_secondary_final_2
SELECT
    e.year,
    e.country,
    e.population,
    e.gini,
    e.gdp
FROM economies e
JOIN countries c ON e.country = c.country
WHERE 
    c.continent = 'Europe'
    AND e.year BETWEEN 2006 AND 2018
    AND e.gdp IS NOT NULL
    AND e.gini IS NOT NULL
    AND e.population IS NOT NULL;

