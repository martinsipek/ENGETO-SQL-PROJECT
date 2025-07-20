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
