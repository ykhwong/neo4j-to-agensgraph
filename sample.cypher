//================================CYPHER SAMPLE FOR TESTING================================
//THIS IS JUST A SAMPLE FOR TESTING. PLEASE RUN THE FOLLOWING STATEMENTS IN NEO4J.
//TESTED WITH NEO4J COMMUNITY VERSION 3.4.5 AND AGENSGRAPH 1.4 DEDVEL(535c4e8b04952f14f0c1bd78749d3b33ffb759dd)


//Delete all nodes and edges
MATCH (n) DETACH DELETE n;
MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n, r;
DROP CONSTRAINT ON ( v_pro1:V_PRO1 ) ASSERT v_pro1.test_svr IS UNIQUE;
DROP CONSTRAINT ON ( v_pro3:V_PRO3 ) ASSERT v_pro3.target IS UNIQUE;
DROP INDEX ON :V_PRO4(category, name);

//Vertex with property (single key-val)
CREATE (:V_PRO1 { id: 763 });
CREATE (:V_PRO1 { id: 552 });
CREATE (:V_PRO1 { test_str: 'love' });

//Vertex with property (two key-val)
CREATE (:V_PRO2 { id: 456, name: 'Ted' });
CREATE (:V_PRO2 { target: 'apple', color: 'red' });

//Vertex with property (three key-val)
CREATE (:V_PRO3 { id: 789, name: 'Kim', hobby: 'Badminton' });
CREATE (:V_PRO3 { target: 'banana', color: 'yellow', price: 5 });

//Vertex with more sophisticated property
CREATE (:V_PRO4 { category: 'video_game', name: 'rayman', released: [1995, 1996, 2000, 2001, 2009, 2016], publisher: 'Ubisoft', genre: 'Platform' });
CREATE (:V_PRO4 { category: 'video_game', name: 'prehistorik2', released: 1993, publisher: 'Titus France', genre: 'Platform', platform: ['Amstrad CPC', 'MS-DOS'] });

//Vertex without property
CREATE (:V_NO_PRO);

//Multiple label vertex with property
CREATE (:V_MULTI_PRO1:V_MULTI_PRO2 { id: 224 });
CREATE (:V_MULTI_PRO3:V_MULTI_PRO4 { id: 578 , name: 'Harry' });
CREATE (:V_MULTI_PRO5:V_MULTI_PRO6 { item: 'chocolate', taste: 'sweet', price: 1 });
CREATE (:V_MULTI_PRO7:V_MULTI_PRO8:V_MULTI_PRO9 { type: 'typhoon', name: 'Soulik', id: 19, date: '2018-08-16', affected: ['South Korea', 'Japan'], submitted_by: 'Micronesia', origin: 'about 260km northwest from Guam' });

//Multiple label vertex without property
CREATE (:V_MULTI_NO_PRO1:V_MULTI_NO_PRO2);
CREATE (:V_MULTI_NO_PRO3:V_MULTI_NO_PRO4:V_MULTI_NO_PRO5);

// Edge without property
MATCH (n1:V_PRO1 { id: 763 }), (n2:V_PRO1 { id: 552 }) CREATE (n1)-[:E_NO_PRO]->(n2);
// Edge with property (single key-val)
MATCH (n1:V_PRO2 { name: 'Ted' }), (n2:V_PRO3 { target: 'banana' }) CREATE (n1)-[:E_PRO1 { type: 'purchased' }]->(n2);
// Edge with property (two key-val)
MATCH (n1:V_PRO2 { name: 'Ted' }), (n2:V_PRO3 { name: 'Kim' }) CREATE (n1)-[:E_PRO2 { relation: 'Friend', common_interest: 'Badminton' }]->(n2);
// Edge with property (three key-val)
MATCH (n1:V_PRO3 { name: 'Kim' }), (n2:V_PRO4 { name: 'rayman' }) CREATE (n1)-[:E_PRO3 { type: 'purchased', place: 'France', platform: 'PC' }]->(n2);
// Edge with more sophisticated property
MATCH (n1:V_PRO2 { name: 'Ted' }), (n2:V_PRO4 { name: 'prehistorik2' }) CREATE (n1)-[:E_PRO3 { type: 'purchased', place: 'United States', finished_level:['spring', 'summer', 'fall', 'winter'] }]->(n2);
MATCH (n1:V_PRO1 { id: 552 }), (n2:V_MULTI_PRO8 { name: 'Soulik' }) CREATE (n1)-[:E_PRO4 { test1: 'something', test2: [100, 33, 21, 33], test3: 'something2' }]->(n2);


// Create Index
CREATE INDEX ON :V_PRO4(category, name);

// Create UNIQUE Constraint
CREATE CONSTRAINT ON (n1:V_PRO1) ASSERT n1.test_svr IS UNIQUE;
CREATE CONSTRAINT ON (n1:V_PRO3) ASSERT n1.target IS UNIQUE;


//================================INTERMEDIATE RESULT================================
//begin
//CREATE (:`V_PRO1` {`id`:763});
//CREATE (:`V_PRO1` {`id`:552});
//CREATE (:`V_PRO1` {`test_str`:"love"});
//CREATE (:`V_PRO2`:`UNIQUE IMPORT LABEL` {`id`:456, `name`:"Ted", `UNIQUE IMPORT ID`:12839});
//CREATE (:`V_PRO2`:`UNIQUE IMPORT LABEL` {`target`:"apple", `color`:"red", `UNIQUE IMPORT ID`:12840});
//CREATE (:`V_PRO3` {`hobby`:"Badminton", `id`:789, `name`:"Kim"});
//CREATE (:`V_PRO3` {`target`:"banana", `color`:"yellow", `price`:5});
//CREATE (:`V_PRO4`:`UNIQUE IMPORT LABEL` {`category`:"video_game", `genre`:"Platform", `name`:"rayman", `publisher`:"Ubisoft", `released`:[1995, 1996, 2000, 2001, 2009, 2016], `UNIQUE IMPORT ID`:12843});
//CREATE (:`V_PRO4`:`UNIQUE IMPORT LABEL` {`category`:"video_game", `genre`:"Platform", `name`:"prehistorik2", `platform`:["Amstrad CPC", "MS-DOS"], `publisher`:"Titus France", `released`:1993, `UNIQUE IMPORT ID`:12844});
//CREATE (:`V_NO_PRO`:`UNIQUE IMPORT LABEL` {`UNIQUE IMPORT ID`:12845});
//CREATE (:`V_MULTI_PRO1`:`V_MULTI_PRO2`:`UNIQUE IMPORT LABEL` {`id`:224, `UNIQUE IMPORT ID`:12846});
//CREATE (:`V_MULTI_PRO3`:`V_MULTI_PRO4`:`UNIQUE IMPORT LABEL` {`id`:578, `name`:"Harry", `UNIQUE IMPORT ID`:12847});
//CREATE (:`V_MULTI_PRO5`:`V_MULTI_PRO6`:`UNIQUE IMPORT LABEL` {`item`:"chocolate", `price`:1, `taste`:"sweet", `UNIQUE IMPORT ID`:12848});
//CREATE (:`V_MULTI_PRO7`:`V_MULTI_PRO8`:`V_MULTI_PRO9`:`UNIQUE IMPORT LABEL` {`affected`:["South Korea", "Japan"], `date`:"2018-08-16", `id`:19, `name`:"Soulik", `origin`:"about 260km northwest from Guam", `submitted_by`:"Micronesia", `type`:"typhoon", `UNIQUE IMPORT ID`:18870});
//CREATE (:`V_MULTI_NO_PRO1`:`V_MULTI_NO_PRO2`:`UNIQUE IMPORT LABEL` {`UNIQUE IMPORT ID`:18871});
//CREATE (:`V_MULTI_NO_PRO3`:`V_MULTI_NO_PRO4`:`V_MULTI_NO_PRO5`:`UNIQUE IMPORT LABEL` {`UNIQUE IMPORT ID`:18872});
//commit


//================================PREPROCESSED RESULT================================
//DROP GRAPH IF EXISTS TEMP CASCADE;
//CREATE GRAPH TEMP;
//SET GRAPH_PATH=TEMP;
//BEGIN;
//CREATE (:V_PRO1 {'id':763});
//CREATE (:V_PRO1 {'id':552});
//CREATE (:V_PRO1 {'test_str':'love'});
//CREATE (:V_PRO2 {'id':456, 'name':'Ted'});
//CREATE (:V_PRO2 {'target':'apple', 'color':'red'});
//CREATE (:V_PRO3 {'hobby':'Badminton', 'id':789, 'name':'Kim'});
//CREATE (:V_PRO3 {'target':'banana', 'color':'yellow', 'price':5});
//CREATE (:V_PRO4 {'category':'video_game', 'genre':'Platform', 'name':'rayman', 'publisher':'Ubisoft', 'released':[1995, 1996, 2000, 2001, 2009, 2016]});
//CREATE (:V_PRO4 {'category':'video_game', 'genre':'Platform', 'name':'prehistorik2', 'platform':['Amstrad CPC', 'MS-DOS'], 'publisher':'Titus France', 'released':1993});
//CREATE (:V_NO_PRO);
//COMMIT;
//BEGIN;
//CREATE VLABEL V_MULTI_NO_PRO1;
//CREATE VLABEL V_MULTI_NO_PRO2;
//CREATE VLABEL AG_MULV_5 INHERITS (V_MULTI_NO_PRO1, V_MULTI_NO_PRO2);
//CREATE VLABEL V_MULTI_NO_PRO3;
//CREATE VLABEL V_MULTI_NO_PRO4;
//CREATE VLABEL V_MULTI_NO_PRO5;
//CREATE VLABEL AG_MULV_6 INHERITS (V_MULTI_NO_PRO3, V_MULTI_NO_PRO4, V_MULTI_NO_PRO5);
//CREATE (:V_MULTI_PRO1 { 'id':224 });
//CREATE (:V_MULTI_PRO2 { 'id':224 });
//CREATE VLABEL AG_MULV_1 INHERITS (V_MULTI_PRO1, V_MULTI_PRO2);
//CREATE (:V_MULTI_PRO3 { 'id':578, 'name':'Harry' });
//CREATE (:V_MULTI_PRO4 { 'id':578, 'name':'Harry' });
//CREATE VLABEL AG_MULV_2 INHERITS (V_MULTI_PRO3, V_MULTI_PRO4);
//CREATE (:V_MULTI_PRO5 { 'item':'chocolate', 'price':1, 'taste':'sweet' });
//CREATE (:V_MULTI_PRO6 { 'item':'chocolate', 'price':1, 'taste':'sweet' });
//CREATE VLABEL AG_MULV_3 INHERITS (V_MULTI_PRO5, V_MULTI_PRO6);
//CREATE (:V_MULTI_PRO7 { 'affected':['South Korea', 'Japan'], 'date':'2018-08-16', 'id':19, 'name':'Soulik', 'origin':'about 260km northwest from Guam', 'submitted_by':'Micronesia', 'type':'typhoon' });
//CREATE (:V_MULTI_PRO8 { 'affected':['South Korea', 'Japan'], 'date':'2018-08-16', 'id':19, 'name':'Soulik', 'origin':'about 260km northwest from Guam', 'submitted_by':'Micronesia', 'type':'typhoon' });
//CREATE (:V_MULTI_PRO9 { 'affected':['South Korea', 'Japan'], 'date':'2018-08-16', 'id':19, 'name':'Soulik', 'origin':'about 260km northwest from Guam', 'submitted_by':'Micronesia', 'type':'typhoon' });
//CREATE VLABEL AG_MULV_4 INHERITS (V_MULTI_PRO7, V_MULTI_PRO8, V_MULTI_PRO9);
//COMMIT;
