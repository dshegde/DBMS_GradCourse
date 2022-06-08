CREATE TABLE Pokemon
(
	Poke_id   INT,
Name   TEXT NOT NULL,
Height   DECIMAL,
Weight   DECIMAL,
Capture_rate         INT,
HP   INT,
Attack   INT,
Defense   INT,
Special   INT,
Speed   INT,
Evolutions  INT,
isLegendary  INT,
PRIMARY KEY(Poke_id)
);

-------------------------------------------------------------------------------------

CREATE TABLE Type
(
	Type_id      SERIAL PRIMARY KEY,
Type_name  VARCHAR(20)
);

--------------------------------------------------------------------------------------

CREATE TABLE Pokemon_Type_Rel
(
pokemon_id   INT,
type_id    INT,
CONSTRAINT fk_pokemon FOREIGN KEY(pokemon_id) REFERENCES Pokemon(poke_id),
CONSTRAINT fk_type FOREIGN KEY(type_id) REFERENCES Type(Type_id)
);

---------------------------------------------------------------------------------------

CREATE TABLE Location
(
	Location_id   SERIAL PRIMARY KEY,
location_name  VARCHAR(100),
description   TEXT
);

----------------------------------------------------------------------------------------

CREATE TABLE Pokemon_Location_Rel
(
	Pokemon_id     INT,
	location_id        INT,
CONSTRAINT fk_pokemon FOREIGN KEY(pokemon_id) REFERENCES pokemon(poke_id),
CONSTRAINT fk_location FOREIGN KEY(location_id) REFERENCES location(location_id)
);

-----------------------------------------------------------------------------------------

CREATE TABLE Moves
(
	move_id      SERIAL PRIMARY KEY,
	name          VARCHAR(50),
	type           INT,
	base_dmg    INT,
	power_pts    INT,
	description   TEXT,
	CONSTRAINT fk_move_type FOREIGN KEY(type) REFERENCES type(type_id)
);

------------------------------------------------------------------------------------------

CREATE TABLE Pokemon_Moves_Rel
(
	pokemon_id        INT,
move_id            INT,
CONSTRAINT fk_pokemon FOREIGN KEY(pokemon_id) REFERENCES pokemon(poke_id),
CONSTRAINT fk_move FOREIGN KEY(move_id) REFERENCES moves(move_id)
);

------------------------------------------------------------------------------------------

CREATE TABLE Pokemon_Evolutions
(
	pokemon_id        INT,
pre_evolution_id    INT,
isFinalEvolution     BOOL,
CONSTRAINT fk_poke_pre_evol FOREIGN KEY(pre_evolution_id) REFERENCES Pokemon(Poke_id),
CONSTRAINT fk_poke_id FOREIGN KEY(pokemon_id) REFERENCES Pokemon(Poke_id)
);

------------------------------------------------------------------------------------------

CREATE TABLE Trainer_Class
(
	class_id        INT   NOT NULL,
class_name       VARCHAR(100),
CONSTRAINT    trainer_class_pkey  PRIMARY KEY(class_id)
);

------------------------------------------------------------------------------------------

CREATE TABLE Trainer_Class_Type_Rel
(
	trainer_id       INT,
	type_id        INT,
CONSTRAINT  fk_trainer FOREIGN KEY(trainer_id) REFERENCES trainer_class(class_id),
CONSTRAINT   fk_type FOREIGN KEY(type_id) REFERENCES type(type_id)
);

------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE populate_pokemon_location_rel(poke_name  varchar(100), loc_name varchar(100))
LANGUAGE SQL
AS $$
INSERT INTO pokemon_location_rel (pokemon_id, location_id) VALUES ((SELECT poke_id FROM pokemon WHERE name=poke_name), (SELECT location_id FROM location WHERE location_name=loc_name));
$$;

------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE populate_pokemon_evolutions(pokename  varchar(100), preevolpokename varchar(100), isfinalform bool)
LANGUAGE SQL
AS $$
INSERT INTO pokemon_evolutions (pokemon_id, pre_evolution_id, isFinalEvolution) VALUES ((SELECT poke_id FROM pokemon WHERE name=pokename), (SELECT poke_id FROM pokemon WHERE name=preevolpokename), isfinalform);
$$;

------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE populate_pokemon_type_rel(pokename  varchar(100), typename varchar(100))
LANGUAGE SQL
AS $$
INSERT INTO pokemon_type_rel (pokemon_id, type_id) VALUES ((SELECT poke_id FROM pokemon WHERE name=pokename), (SELECT type_id FROM type WHERE type_name=typename));
$$;

------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE populate_pokemon_moves_rel(pokeName text, type1Name text, type2Name text)
LANGUAGE plpgsql
AS $$
DECLARE
type1_id INTEGER;
type2_id INTEGER;
type1_MoveCount	INTEGER := 3;
type2_MoveCount INTEGER := 2;
pokeId	INTEGER;
moveId	INTEGER;

BEGIN
-- IF Pokemon has only 1 type then load all 5 moves of that type
IF (type2Name IS NULL) THEN
	type1_MoveCount := type1_MoveCount + type2_MoveCount;
	type2_MoveCount := 0;
END IF;

SELECT poke_id INTO pokeId FROM Pokemon WHERE name = pokeName;

SELECT type_id INTO type1_id FROM Type WHERE UPPER(type_name) = UPPER(type1Name);
 
SELECT type_id INTO type2_id FROM Type WHERE UPPER(type_name) = UPPER(type2Name);

FOR val IN 1..type1_MoveCount
LOOP
	SELECT move_id INTO moveId FROM Moves WHERE type = type1_id ORDER BY RANDOM() LIMIT 1;
	
	INSERT INTO Pokemon_moves_rel(pokemon_id, move_id) VALUES(pokeId, moveId);
END LOOP;

IF (type2_MoveCount != 0) THEN

	FOR val IN 1..type2_MoveCount
	LOOP
		SELECT move_id INTO moveId FROM Moves WHERE type = type2_id ORDER BY RANDOM() LIMIT 1;
		
		INSERT INTO Pokemon_moves_Rel(pokemon_id, move_id) VALUES(pokeId, moveId);
	END LOOP;
END IF;

END;
$$;


