# Technická dokumentace k SQL projektu Datové Akademie ENGETO
 
**Zadáním projektu** bylo odpovědět na 5 výzkumných otázek pomocí SQL dotazů vycházejících z dat z tabulek o mzdách, cenách potravin, HDP aj. Konkrétní použité tabulky jsou rozepsány níže.

V rámci projektu nebyly upravovány původní tabulky. Veškeré transformace probíhaly přes SQL dotazy.

_*V rámci dokumentace níže popisuji finální SQL dotaz. V jednotlivých *.sql souborech jsou poté uvedeny a okomentovány i postupy._

---

## 📊 Použité zdrojové tabulky/data

V průběhu projektu bylo čerpáno z následujících tabulek/dat:

- `czechia_payroll` – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- `czechia_price` – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
- `czechia_price_category` – Číselník kategorií potravin, které se vyskytují v našem přehledu.
- `czechia_payroll_industry_branch` – Číselník odvětví v tabulce mezd.
- `economies` – HDP, GINI, daňová zátěž, atd. pro daný stát a rok.
- `countries` – Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.

## 📋 Pomocí těchto dat byly vytvořeny dvě tabulky:

- `t_martin_sipek_project_SQL_primary_final` – Data ohledně průměrných cenách potravin a mezd dle let a kvartálů.
- `t_martin_sipek_project_SQL_secondary_final` – Data evropských států (HDP, GINI, populace aj.).

---

## ❓ Výzkumná otázka č. 1  
**Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

### Postup:
Vytvořil jsem CTE pro výpočet průměrné mzdy dle let, kvartálů a jednotlivých odvětví. Pro lepší přehlednost jsem zaokrouhlil výsledek na dvě desetinná místa. Pomocí funkce `LAG` jsem spočítal **meziroční rozdíl** (nárůst/pokles) ve mzdách pro každé odvětví a kvartál. Pro další přehlednost jsem pomocí funkce `JOIN` připojil tabulku s **konkrétními názvy pracovních odvětví.** Výsledkem je **procentuální změna** mezd mezi roky ve sloupci `difference_in_percentage`.

### Vyhodnocení:
Ne, ve všech odvětvích mzdy každý rok nerostou, **naopak**. Jsou odvětví, kdy se objevuje v určitých letech jejich pokles. Z výsledných dat je vidět, že ve většině pracovních odvětví v průběhu jednotlivých let mzdy rostly. V některých letech došlo ale i k poklesům. Např.: v odvětví **Administrativní a podpůrné činnosti** došlo v roce **2013** k meziročnímu poklesu o **-1,84 %** oproti roku **2012**. Podobné výkyvy lze pozorovat i u jiných odvětví.


---

## ❓ Výzkumná otázka č. 2  
**Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

### Postup:
Dle zadání jsem filtroval kategorie `Chléb` a `Mléko`, _(které jsem pro lepší přehlednost přejmenoval z jejich `category_code`)_ a spočítal jsem **průměrné ceny**. Následně jsem vypočítal **průměrné měsíční mzdy**. Filtroval jsem hodnoty **podle typu** _(`value_type_code = 5958` - průměrná hrubá mzda na zaměstnance)_, **jednotky** _(`unit_code = 200` - tisíce Kč)_ a **jednoho full time pracovníka**, nikoliv full FTE _(kombinované)_ _(`calculation_code = 100` - měsíční průměr)_. Pomocí dělení mzdy cenou jsem zjistil, kolik kusů dané potraviny by bylo možné zakoupit. Pracoval jsem pouze s prvním a posledním srovnatelným obdobím _(dle zadání)_, tedy s **Q1/2006 - Q4/2018**. Opět jsem také pomocí `JOIN` doplním tabulku s celými názvy odvětví. 

### Vyhodnocení:
Konkrétní hodnoty jsou uvedeny ve sloupci `pieces_can_be_purchased` po spuštění SQL dotazu `otazka_2.sql`. 

**Avšak pro příklad můžu uvést, že:**

* Administrativní a podpůrné činnosti (Chléb): **Q1/2006** = 853 ks vs. **Q4/2018** = 874 ks
* Stavebnictví (Mléko): **Q1/2006** = 1 086 l vs. **Q4/2018** = 1 530 l
* Činnosti v oblasti nemovitostí (Chléb): **Q1/2006** = 1 134 ks vs. **Q4/2018** 1 186 ks

---

## ❓ Výzkumná otázka č.3  
**Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

### Postup:
Z jednotlivých kategorií potravin jsem spočítal **roční průměrné ceny** a pomocí funkce `JOIN` doplnil **jednotlivé názvy**. Pomocí `LAG` jsem vypočítal **meziroční procentuální změnu** a následně **zprůměroval výsledky** za všechna dostupná období. Výsledkem je **průměrný roční nárůst ceny pro každou potravinu.**

### Vyhodnocení:
Z výsledků vyplývá, že nejpomaleji zdražující potravinou byly `Banány žluté`, které zdražují průměrně o **0,81 %**. 

**Avšak jsou zde i potraviny, které zlevňují:**

* Cukr krystalový: **-1,92 %**
* Rajská jablka červená kulatá: **-0,74 %**

---

## ❓ Výzkumná otázka č.4  
**Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

### Postup:
Vypočítal jsem **průměrné roční ceny** všech potravin i **průměrné roční mzdy**. Pomocí `LAG` jsem vypočítal jejich **meziroční změny**. Podobným způsobem jsem vypočítal i průměrné roční mzdy z tabulky a meziroční nárůsty těchto hodnot. Následně jsem vše spojil podle roku a vypočetl **rozdíl v procentech mezi růstem cen a růstem mezd**. Výsledek je vidět ve sloupci `difference_percent`. Poté jsem vy filtroval pouze roky, ve kterých byl rozdíl **větší než 10 %**.

### Vyhodnocení:
Meziroční náčůst cen potravin byl vyšší než 10 % ve dvou případech:

* 2013: **11,5 %**
* 2017: **11,24 %**

---

## ❓ Výzkumná otázka č.5  
**Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

### Postup:
Vyfiltroval jsem si základní data o ČR. Vypočítal jsem **meziroční změny HDP** pomocí `LAG` a tyto hodnoty posunul o 1 rok dopředu (year + 1), pro **zjištění vlivu HDP (GDP) v dalším roce**. Poté jsem vytvořil CTE pro výpočet **průměrné mzdy v ČR** podle let a CTE pro výpočet meziročního růstu mezd. To stejné jsem udělal **i pro potraviny**. Ve finálním SELECTu jsem vše spojil dohromady.


### Vyhodnocení:
Vyšší růst HDP **může, ale nemusí** mít přímý dopad na růst mezd a cen potravin. V některých letech toto platí, např.: v **roce 2007**, kdy byl **růst HDP 6,77 %**, **růst mezd 6,86 %** a **růst cen potravin 6,34 %**. Naopak např.: v **roce 2016** byl **růst HDP 5,39 %**, ale **růst mezd 3,69 %** a **růst, respektivě pokles** **cen potravin o 1,12 %**. Z toho lze vyvodit, že růst HDP **může mít** vliv na růst mezd a cen, **ale nelze toto považovat za pravidlo.**

---

## 👨🏽‍💻 Vypracoval
Martin Šípek pro Datová Akademie ENGETO, 2025
