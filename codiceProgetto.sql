-- Quali sono i Paesi meglio o peggio piazzati in termini di energia rinnovabile, sanità ed educazione, come queste metriche si sono mosse nel tempo 
-- e se esiste una correlazione tra alcune delle variabili. 


-- POSIZIONE DEI PAESI IN FATTO DI ENERGIA RINNOVABILE

-- guardo quali sono i paesi con la maggiore produzione di energia rinnovabile nel 2020

SELECT entity, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = '2020'
ORDER BY electricity_from_renewables_twh DESC;

-- guardo quali sono i paesi che non hanno prodotto energia rinnovabile nel 2020

SELECT entity, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = '2020' AND electricity_from_renewables_twh = 0
ORDER BY electricity_from_renewables_twh ASC;

-- controllo la produzione pro-capite di energia rinnovabile, 
-- così da avere un indicatore pesato sulla popolazione totale che rispecchi maggiormente la posizione dei paesi

CREATE MATERIALIZED VIEW renewable_energy_production_rank AS
SELECT s.entity, s.year, s.electricity_from_renewables_twh,  
	   ROUND((s.electricity_from_renewables_twh/w.population),10) AS renewable_electricity_pro_capite_twh
	FROM SustainableData s
JOIN worldData2023 w
	ON s.entity = w.Country
	WHERE s.year = '2020' AND s.electricity_from_renewables_twh != 0
ORDER BY renewable_electricity_pro_capite_twh DESC
LIMIT 10;

-- Creo due VIEW con l'energia prodotta dai vari stati nel 2020 e nel 2015

CREATE VIEW renewable_energy_2015 AS
SELECT entity, year, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = 2015;

SELECT * FROM renewable_energy_2015;

CREATE VIEW renewable_energy_2020 AS
SELECT entity, year, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = 2020;

SELECT * FROM renewable_energy_2020;

-- Unisco le due viste create per avere un unica vista che comprenda sia i valori del 2015 che quelli del 2020

CREATE VIEW renewable_energy_production_comparison AS
SELECT r.entity, r.electricity_from_renewables_twh AS production_2015, rr.electricity_from_renewables_twh AS production_2020	   
	FROM renewable_energy_2015 r
JOIN renewable_energy_2020 rr
	ON r.entity = rr.entity;

-- Creo una MATERIALIZED VIEW che comprende la differenza di produzione di energia rinnovabile tra il 2015 e il 2020, dividendola per la popolazione totale (dati del 2023)
-- così da avere dati più attendibili e non inflazionati dalla grandezza degli stati
	
CREATE MATERIALIZED VIEW renewable_energy_production_increment AS
SELECT p.entity, ROUND(((p.production_2020 - p.production_2015)/w.population), 10) AS production_increment_pro_capite
	FROM renewable_energy_production_comparison p
JOIN worlddata2023 w
	ON p.entity = w.Country	
ORDER BY production_increment_pro_capite DESC;

SELECT * FROM renewable_energy_production_increment
WHERE production_increment_pro_capite IS NOT NULL;

-- Creo una materialized view con all'interno gli stati con maggior aumento di produzione negli ultimi 5 anni di energia rinnovabile

CREATE MATERIALIZED VIEW renewable_energy_increment_5y AS



