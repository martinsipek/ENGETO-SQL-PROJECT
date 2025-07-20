# ENGETO - PostgreSQL PROJEKT DATOVÉ AKADEMIE


## 📝 Zadání projektu

Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. 

Tabulky pojmenujte **t_{jmeno}_{prijmeni}_project_SQL_primary_final** _(pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky)_ a **t_{jmeno}_{prijmeni}_project_SQL_secondary_final** _(pro dodatečná data o dalších evropských státech)_.

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky. Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data. a svém GitHub účtu vytvořte veřejný repozitář, kam uložíte všechny informace k projektu – hlavně SQL skript generující výslednou tabulku, popis mezivýsledků (průvodní listinu) ve formátu markdown (.md) a informace o výstupních datech (například kde chybí hodnoty apod.).


## 🎯 Cíl projektu

Cílem projektu je analyzovat data pomocí SQL dotazů, odpovědět na 5 výzkumných otázek a vytvořit dvě tabulky obsahující potřebná data.


## ❓ Výzkumné otázky
* **Otázka č.1:** Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
* **Otázka č.2:** Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
* **Otázka č.3:** Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
* **Otázka č.4:** Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
* **Otázka č.5:** Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?


## 📊 Použité zdroje dat

* `czechia_price`
* `czechia_payroll`
* `czechia_price_category`
* `czechia_payroll_industry_branch`
* `countries`
* `economies`


## 📋 Vytvořené datové tabulky

* `t_martin_sipek_project_SQL_primary_final` – sjednocená tabulka obsahující data o o mzdách a cenách potravin v ČR (2006–2018)
* `t_martin_sipek_project_SQL_secondary_final` – tabulka dat evropských zemí o HDP, GINI indexu a populaci (2006–2018)


## 📂 Obsah repozitáře

* `tabulka_primary.sql` – Vytvoření primární tabulky
* `tabulka_secondary.sql` – Vytvoření sekundární tabulky
* `otazka_1.sql` – SQL skript pro zodpovězení otázky č.1
* `otazka_2.sql` – SQL skript pro zodpovězení otázky č.2
* `otazka_3.sql` – SQL skript pro zodpovězení otázky č.3
* `otazka_4.sql` – SQL skript pro zodpovězení otázky č.4
* `otazka_5.sql` – SQL skript pro zodpovězení otázky č.5
* `documentation.md` - Průvodní listina projektu 
* `README.md` – Rozcestník a technické informace 


## 👨🏽‍💻 Vypracoval

Martin Šípek pro Datová Akademie ENGETO, 2025
