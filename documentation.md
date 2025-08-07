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
Vytvořil jsem CTE pro výpočet průměrné mzdy dle let, kvartálů a jednotlivých odvětví. Data jsem čerpal z mé tabulky `t_martin_sipek_project_SQL_primary_final`, která už obsahuje pouze společné srovnatelné období. Výsledek jsem zaokrouhlil na dvě desetinná místa pro lepší přehlednost. Pomocí funkce `LAG` jsem spočítal **meziroční rozdíl** (nárůst/pokles) ve mzdách pro každé odvětví a kvartál. Pomocí `JOIN` jsem připojil **názvy odvětví** z tabulky `czechia_payroll_industry_branch`. Výsledkem je **procentuální změna** mezd mezi roky ve sloupci `difference_in_percentage`.

### Vyhodnocení:
Ne, ve všech odvětvích mzdy každý rok nerostou, **naopak**. Jsou odvětví, kdy se objevuje v určitých letech jejich pokles. Z výsledných dat je vidět, že ve většině pracovních odvětví v průběhu jednotlivých let mzdy rostly. V některých letech došlo ale i k poklesům. Např.: v odvětví **Administrativní a podpůrné činnosti** došlo v roce **2013** k meziročnímu poklesu o **-1,14 %** oproti roku **2012**. Podobné výkyvy lze pozorovat i u jiných odvětví.


---

## ❓ Výzkumná otázka č. 2  
**Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

### Postup:
Dle zadání jsem filtroval kategorie `Chléb` a `Mléko` _(které jsem pro lepší přehlednost přejmenoval z jejich `category_code`)_ a spočítal, kolik kusů těchto potravin lze v jednotlivých odvětvích zakoupit za **průměrnou měsíční mzdu**. Použil jsem svou předem vytvořenou tabulku t_martin_sipek_project_SQL_primary_final, která již obsahuje správně **očištěná a sloučená data** pouze za společné období a s aplikovanými filtry na typ mzdy, jednotky a výpočetní metodu.

### Vyhodnocení:
Konkrétní hodnoty jsou uvedeny ve sloupci `pieces_can_be_purchased` po spuštění SQL dotazu `otazka_2.sql`. 

**Avšak pro příklad můžu uvést, že:**

* Administrativní a podpůrné činnosti (Chléb): **Q1/2006** = 853 ks vs. **Q4/2018** = 874 ks
* Stavebnictví (Mléko): **Q1/2006** = 1 086 l vs. **Q4/2018** = 1 531 l
* Činnosti v oblasti nemovitostí (Chléb): **Q1/2006** = 1 134 ks vs. **Q4/2018** 1 186 ks

---

## ❓ Výzkumná otázka č. 3  
**Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

### Postup:
Z jednotlivých kategorií potravin jsem spočítal **roční průměrné ceny**, a protože tabulka `t_martin_sipek_project_SQL_primary_final` už obsahuje přefiltrované období dle zadání, nebylo potřeba další ořezávání. Pomocí funkce `JOIN` jsem doplnil **jednotlivé názvy potravin** z tabulky `czechia_price_category`. Funkcí `LAG` jsem spočítal **meziroční procentuální změnu** a tyto rozdíly jsem následně **zprůměroval** za všechna dostupná období. Výsledkem je **průměrný roční nárůst ceny pro každou sledovanou potravinu.**

### Vyhodnocení:
Z výsledků vyplývá, že nejpomaleji zdražující potravinou byly `Banány žluté`, které zdražují průměrně o **0,78 %**. 

**Avšak jsou zde i potraviny, které zlevňují:**

* Cukr krystalový: **-1,92 %**
* Rajská jablka červená kulatá: **-0,72 %**

---

## ❓ Výzkumná otázka č. 4  
**Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

### Postup:
V první části dotazu jsem vypočítal průměrné roční ceny všech potravin na základě tabulky `t_martin_sipek_project_SQL_primary_final`, která již obsahuje předzpracovaná data pouze za období, jež je **společné pro mzdové a cenové statistiky**. Pomocí funkce `LAG` jsem spočítal **meziroční změny** cen potravin v procentech. 

Ve druhé části jsem obdobným způsobem vypočítal **průměrné roční mzdy** a jejich **meziroční procentuální změny**.

V poslední části jsem obě hodnoty spojil podle roku a vypočítal **rozdíl mezi meziročním růstem cen potravin** a **meziročním růstem mezd**. Výsledkem je sloupec `difference_percent`, který ukazuje, o kolik procent rostly ceny potravin více než mzdy. Nakonec jsem vyfiltroval pouze ty roky, kdy byl tento **rozdíl větší než 10 %**.

### Vyhodnocení:
Tabulka `t_martin_sipek_project_SQL_primary_final` zahrnuje pouze roky a čtvrtletí, která jsou dostupná **zároveň v datech o mzdách i cenách potravin**. Tím pádem je časové období omezené a nezahrnuje všechny roky, které by mohly obsahovat výjimečné výkyvy.

Výsledná tabulka nevrací žádný řádek/data, protože v rámci tohoto společného časového rozsahu **nedošlo k žádnému roku**, kdy by ceny potravin **rostly o více než 10 % rychleji než mzdy**.

Jinými slovy – v dostupném období byly meziroční rozdíly mezi cenami potravin a mzdami menší než 10 % a žádný z nich nepřekročil stanovený limit.

### Poznámka:
Je ale **důležité** zmínit, že tabulka `t_martin_sipek_project_SQL_primary_final` obsahuje **pouze společné časové období**, tj. pouze taková data, která jsou dostupná současně pro **mzdy i pro ceny potravin**. Tím pádem je **datový rozsah omezený** a některé roky s potenciálně vyššími rozdíly mezi růstem cen a růstem mezd do výběru vůbec nevstupují.

Pokud bychom pracovali s širším rozsahem dat mimo tabulku `t_martin_sipek_project_SQL_primary_final`, je možné, že bychom zachytili roky, kdy byl rozdíl mezi růstem cen a růstem mezd vyšší než 10 %. Takový postup by ale odporoval zadání projektu, které požaduje zpracování dat pouze ze společného období.

---

## ❓ Výzkumná otázka č. 5  
**Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

### Postup:
Vyfiltroval jsem si základní data o ČR z tabulky `t_martin_sipek_project_SQL_secondary_final`. Vypočítal jsem **meziroční změny HDP** pomocí `LAG` a tyto hodnoty jsem **posunul o 1 rok dopředu** (year + 1), pro zjištění **vlivu HDP v dalším roce**. Poté jsem vytvořil `CTE` pro výpočet **průměrné mzdy** v ČR podle let a `CTE` pro výpočet **meziročního růstu mezd**. Stejným způsobem jsem vypočítal meziroční změny **cen potravin**, obojí z tabulky `t_martin_sipek_project_SQL_primary_final`. Ve finálním SELECTu jsem vše spojil dohromady podle roku.

### Vyhodnocení:
Vyšší růst HDP **může, ale nemusí** mít přímý dopad na růst mezd a cen potravin. V některých letech to platí – např. v **roce 2008** kdy byl **růst HDP 5,57 %**, **růst mezd 8,06 %** a **růst cen potravin 6,06 %**. Naopak např.: v **roce 2016** byl **růst HDP 5,39 %**, ale **růst mezd 3,7 %** a **růst, respektivě pokles** **cen potravin o 1,14 %**. Z toho lze vyvodit, že růst HDP **může mít** vliv na růst mezd a cen, **ale nelze toto považovat za pravidlo.**

Výsledky vycházejí pouze z období, která jsou společná pro všechna data v tabulkách `t_martin_sipek_project_SQL_primary_final` a `t_martin_sipek_project_SQL_secondary_final`. 

---

## 👨🏽‍💻 Vypracoval
Martin Šípek pro Datová Akademie ENGETO, 2025
