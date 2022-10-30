\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;

DROP TABLE category, states, regions, isos;
DROP TABLE IF EXISTS category;

SELECT sequence_schema, sequence_name FROM information_schema.sequences;
DROP SEQUENCE IF EXISTS category_id_seq;
DROP SEQUENCE IF EXISTS regions_id_seq;
DROP SEQUENCE IF EXISTS states_id_seq;
DROP SEQUENCE IF EXISTS isos_id_seq;

CREATE TABLE category (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE state (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE region (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE iso (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE unesco(
  name TEXT, description TEXT, justification TEXT, year INTEGER,
  longitude FLOAT, latitude FLOAT, area_hectares FLOAT, category_id INTEGER,
  state_id INTEGER, region_id INTEGER, iso_id INTEGER
);

insert into category (name) select DISTINCT(unesco_raw.category) as name FROM unesco_raw;
insert into state (name) select DISTINCT(unesco_raw.state) as name FROM unesco_raw;
insert into region (name) select DISTINCT(unesco_raw.region) as name FROM unesco_raw;
insert into iso (name) select DISTINCT(unesco_raw.iso) as name FROM unesco_raw;

UPDATE unesco_raw SET category_id = (SELECT category.id FROM category WHERE category.name = unesco_raw.category);
UPDATE unesco_raw SET region_id = (SELECT region.id FROM region WHERE region.name = unesco_raw.region);
UPDATE unesco_raw SET state_id = (SELECT state.id FROM state WHERE state.name = unesco_raw.state);
UPDATE unesco_raw SET iso_id = (SELECT iso.id FROM iso WHERE iso.name = unesco_raw.iso);


insert into unesco(name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id) select name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id FROM unesco_raw;

SELECT unesco.name, year, category.name, state.name, region.name, iso.name
  FROM unesco
  JOIN category ON unesco.category_id = category.id
  JOIN iso ON unesco.iso_id = iso.id
  JOIN state ON unesco.state_id = state.id
  JOIN region ON unesco.region_id = region.id
  ORDER BY category.name, unesco.name
  LIMIT 3;
