# DB Migration from Neo4j to AgensGraph

## INTRODUCTION
Preprocesses the Cypher statements from Neo4j so that they can be used for AgensGraph. This can be useful for the migration.

## REQUIREMENT
* Neo4j as a source database server
* AgensGraph as a target database server
* Either one of the following: Perl 5 or Python 2 or Python 3
  - For Windows users: Recommended to install Git from https://git-scm.com/downloads and run Git Bash that gives some utilities such as perl, git, and tail by default. MinGW/MSYS and Cygwin are also good alternatives.

## SETUP
The following setup is required for the Neo4j server.

1. Install the APOC library ( https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases ).
Copy the library(e.g, apoc-3.4.0.2-all.jar) to the plugins directory.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ if [ ! -d plugins ]; then mkdir plugins; fi
  $ cd plugins
  $ wget https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.4.0.2/apoc-3.4.0.2-all.jar
```

2. Append "apoc.export.file.enabled=true" to the conf/neo4j.conf.
```sh
  $ cd /path/to/neo4j-community-3.4.5/conf
  $ echo "apoc.export.file.enabled=true">>neo4j.conf
```

3. Install 'neo4j-shell tools'.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ curl http://dist.neo4j.org/jexp/shell/neo4j-shell-tools_3.0.1.zip -o neo4j-shell-tools.zip
  $ unzip neo4j-shell-tools.zip -d lib
```

4. Download the preprocessor file for preprocessing the Cypher statements.
```sh
  $ git clone https://github.com/ykhwong/neo4j_to_agensgraph.git
  $ cd neo4j_to_agensgraph
  $ cp preprocecss.p* /path/to/neo4j-community-3.4.5/.
```

## EXPORT CYPHER
### FOR THE SMALL DATA SET
1. Run the neo4j-shell and type "export-cypher -o export.cypher".

```sh
  $ cd /path/to/neo4j-community-3.4.5/bin
  $ neo4j-shell
  neo4j-sh (?)$ export-cypher -o export.cypher
  Wrote Nodes xx. 100%: nodes = xx rels = xx properties = xx time xx ms total xx ms
  Wrote Relationships xx. 100%: nodes = xx rels = xx properties = xx time xx ms total xx ms
  Wrote to Cypher-file export.cypher xx. 100%: nodes = xx rels = xx properties = xx time 0 ms total xx ms
  neo4j-sh (?)$ exit
```

export.cypher will be created in the neo4j directory.
The contents of the file would be something like this:

```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ cat export.cypher
  BEGIN
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Billy", `UNIQUE IMPORT ID`:0});
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Jim", `UNIQUE IMPORT ID`:20});
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Mike", `UNIQUE IMPORT ID`:21});
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Anna", `UNIQUE IMPORT ID`:22});
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Sally", `UNIQUE IMPORT ID`:23});
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Bob", `UNIQUE IMPORT ID`:24});
  CREATE (:`person`:`UNIQUE IMPORT LABEL` {`name`:"Joe", `UNIQUE IMPORT ID`:25});
  COMMIT
  BEGIN
  CREATE CONSTRAINT ON (node:`UNIQUE IMPORT LABEL`) ASSERT node.`UNIQUE IMPORT ID` IS UNIQUE;
  COMMIT
  SCHEMA AWAIT
  BEGIN
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:20}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:0}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:20}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:21}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:22}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:20}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:22}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:21}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:23}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:22}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:25}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:23}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:25}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:24}) CREATE (n1)-[r:`KNOWS`]->(n2);
  MATCH (n1:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:24}), (n2:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`:23}) CREATE (n1)-[r:`KNOWS`]->(n2);
  COMMIT
  BEGIN
  MATCH (n:`UNIQUE IMPORT LABEL`)  WITH n LIMIT 20000 REMOVE n:`UNIQUE IMPORT LABEL` REMOVE n.`UNIQUE IMPORT ID`;
  COMMIT
  BEGIN
  DROP CONSTRAINT ON (node:`UNIQUE IMPORT LABEL`) ASSERT node.`UNIQUE IMPORT ID` IS UNIQUE;
  COMMIT
```

2. Run the below command to begin the preprocess.
```sh
  $ perl preprocess.pl export.cypher --graph=TEMP
```

Or you can use the python interpreter instead.
```sh
  $ python preprocess.py export.cypher --graph=TEMP
```

You’ll see the preprocessed output which can be used for AgensGraph.
```
  DROP GRAPH IF EXISTS TEMP CASCADE;
  CREATE GRAPH TEMP;
  SET GRAPH_PATH=TEMP;
  BEGIN;
  CREATE (:person {'name':'Billy'});
  CREATE (:person {'name':'Jim'});
  CREATE (:person {'name':'Mike'});
  CREATE (:person {'name':'Anna'});
  CREATE (:person {'name':'Sally'});
  CREATE (:person {'name':'Bob'});
  CREATE (:person {'name':'Joe'});
  COMMIT;
  BEGIN;
  COMMIT;
  BEGIN;
  MATCH (n1:person {'name':'Jim'}), (n2:person {'name':'Billy'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Jim'}), (n2:person {'name':'Mike'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Anna'}), (n2:person {'name':'Jim'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Anna'}), (n2:person {'name':'Mike'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Sally'}), (n2:person {'name':'Anna'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Joe'}), (n2:person {'name':'Sally'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Joe'}), (n2:person {'name':'Bob'}) CREATE (n1)-[r:KNOWS]->(n2);
  MATCH (n1:person {'name':'Bob'}), (n2:person {'name':'Sally'}) CREATE (n1)-[r:KNOWS]->(n2);
  COMMIT;
  BEGIN;
  COMMIT;
  BEGIN;
  COMMIT;
```

If you want to import the preprocessed result to AgensGraph, please type the following.
```sh
  $ perl preprocess.pl export.cypher --graph=TEMP --import-to-agens
```

Or you can use the python interpreter instead.
```sh
  $ python preprocess.py export.cypher --graph=TEMP --import-to-agens
```

Please note that the existing graph repository named TEMP will be removed and initialized. You can freely change the graph name above.

The following message will be displayed on success.
```
  DROP GRAPH
  CREATE GRAPH
  SET
  BEGIN
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  GRAPH WRITE (INSERT VERTEX 1, INSERT EDGE 0)
  COMMIT
  BEGIN
  COMMIT
  BEGIN
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 1)
  COMMIT
  BEGIN
  COMMIT
  BEGIN
  COMMIT
```

### FOR THE BIG DATA SET
1. Run the neo4j-shell and type "export-cypher -o export.cypher".

```sh
  $ cd /path/to/neo4j-community-3.4.5/bin
  $ neo4j-shell
  neo4j-sh (?)$ export-cypher -o export.cypher
  ...
```

It may take long time to generate the export.cypher depending on the data size.

2. During the export, open a new terminal session and type the following to import the the data to AgensGraph.

```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ tail -f -n +1 export.cypher | perl preprocess.pl --graph=TEMP --import-to-agens
```

Or you can use the python interpreter instead.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ tail -f -n +1 export.cypher | python preprocess.py --graph=TEMP --import-to-agens
```

Please note that the existing graph repository named TEMP will be removed and initialized. You can freely change the graph name above.

3. Please keep watching the export status from Neo4j.

## DUMP OPTION
NOTE: This is optional, therefore you don't have to follow this method. Also, it does not currently support the multi-labels.

Besides the export-cypher method above, Neo4j's dump also can be used for the export to AgensGraph. However, you may have to drop the existing constraints because Neo4j complains about them.

1. Check the existing indexes and constraints.
```sh
  $ neo4j-shell
  neo4j-sh (?)$ CALL db.indexes();
  neo4j-sh (?)$ CALL db.constraints();
```

2. Drop the listed constraints manually. For details, please refer to:
* DROP INDEX: https://neo4j.com/docs/developer-manual/current/cypher/schema/index/
* DROP CONSTRAINT: https://neo4j.com/docs/developer-manual/current/cypher/schema/constraints/#constraints-drop-unique-constraint

3. Create a file that includes "dump" and run it with neo4j-shell. "neo4j-shell -c dump" also can be used but may not work properly in some systems.
```sh
  $ echo dump>dump.txt
  $ neo4j-shell -file dump.txt>export.cypher
```

4. export.cypher file will be created. The contents of the file would be something like this:
```
begin
commit
begin
create (_12836:`V_PRO1` {`id`:763})
create (_12837:`V_PRO1` {`id`:552})
create (_12838:`V_PRO1` {`test_str`:"love"})
create (_12839:`V_PRO2` {`id`:456, `name`:"Ted"})
create (_12840:`V_PRO2` {`color`:"red", `target`:"apple"})
create (_12841:`V_PRO3` {`hobby`:"Badminton", `id`:789, `name`:"Kim"})
create (_12842:`V_PRO3` {`color`:"yellow", `price`:5, `target`:"banana"})
create (_12843:`V_PRO4` {`category`:"video_game", `genre`:"Platform", `name`:"rayman", `publisher`:"Ubisoft", `released`:[1995, 1996, 2000, 2001, 2009, 2016]})
create (_12844:`V_PRO4` {`category`:"video_game", `genre`:"Platform", `name`:"prehistorik2", `platform`:["Amstrad CPC", "MS-DOS"], `publisher`:"Titus France", `released`:1993})
create (_12845:`V_NO_PRO`)
create (_12846:`V_MULTI_PRO1`:`V_MULTI_PRO2` {`id`:224})
create (_12847:`V_MULTI_PRO3`:`V_MULTI_PRO4` {`id`:578, `name`:"Harry"})
create (_12848:`V_MULTI_PRO5`:`V_MULTI_PRO6` {`item`:"chocolate", `price`:1, `taste`:"sweet"})
create (_18870:`V_MULTI_PRO7`:`V_MULTI_PRO8`:`V_MULTI_PRO9` {`affected`:["South Korea", "Japan"], `date`:"2018-08-16", `id`:19, `name`:"Soulik", `origin`:"about 260km northwest from Guam", `submitted_by`:"Micronesia", `type`:"typhoon"})
create (_18871:`V_MULTI_NO_PRO1`:`V_MULTI_NO_PRO2`)
create (_18872:`V_MULTI_NO_PRO3`:`V_MULTI_NO_PRO4`:`V_MULTI_NO_PRO5`)
create (_12836)-[:`E_NO_PRO`]->(_12837)
create (_12837)-[:`E_PRO4` {`test1`:"something", `test2`:[100, 33, 21, 33], `test3`:"something2"}]->(_18870)
create (_12839)-[:`E_PRO3` {`finished_level`:["spring", "summer", "fall", "winter"], `place`:"United States", `type`:"purchased"}]->(_12844)
create (_12839)-[:`E_PRO2` {`common_interest`:"Badminton", `relation`:"Friend"}]->(_12841)
create (_12839)-[:`E_PRO1` {`type`:"purchased"}]->(_12842)
create (_12841)-[:`E_PRO3` {`place`:"France", `platform`:"PC", `type`:"purchased"}]->(_12843)
;
commit
```

5. Run the below command to begin the preprocess. Don't forget to use "--use-dump" option.
```sh
  $ perl preprocess.pl export.cypher --graph=TEMP --use-dump
```

Or you can use the python interpreter instead.
```sh
  $ python preprocess.py export.cypher --graph=TEMP --use-dump
```

Please note that the existing graph repository named TEMP will be removed and initialized. You can freely change the graph name above.

The following message will be displayed on success.
```
DROP GRAPH IF EXISTS TEMP CASCADE;
CREATE GRAPH TEMP;
SET GRAPH_PATH=TEMP;
BEGIN;
COMMIT;
BEGIN;
CREATE (:V_PRO1 {'id':763});
CREATE (:V_PRO1 {'id':552});
CREATE (:V_PRO1 {'test_str':'love'});
CREATE (:V_PRO2 {'id':456, 'name':'Ted'});
CREATE (:V_PRO2 {'color':'red', 'target':'apple'});
CREATE (:V_PRO3 {'hobby':'Badminton', 'id':789, 'name':'Kim'});
CREATE (:V_PRO3 {'color':'yellow', 'price':5, 'target':'banana'});
CREATE (:V_PRO4 {'category':'video_game', 'genre':'Platform', 'name':'rayman', 'publisher':'Ubisoft', 'released':[1995, 1996, 2000, 2001, 2009, 2016]});
CREATE (:V_PRO4 {'category':'video_game', 'genre':'Platform', 'name':'prehistorik2', 'platform':['Amstrad CPC', 'MS-DOS'], 'publisher':'Titus France', 'released':1993});
CREATE (:V_NO_PRO);
--Multiple labels not supported
CREATE (:V_MULTI_PRO1':'V_MULTI_PRO2 {'id':224});
CREATE (:V_MULTI_PRO3':'V_MULTI_PRO4 {'id':578, 'name':'Harry'});
CREATE (:V_MULTI_PRO5':'V_MULTI_PRO6 {'item':'chocolate', 'price':1, 'taste':'sweet'});
CREATE (:V_MULTI_PRO7':'V_MULTI_PRO8':'V_MULTI_PRO9 {'affected':['South Korea', 'Japan'], 'date':'2018-08-16', 'id':19, 'name':'Soulik', 'origin':'about 260km northwest from Guam', 'submitted_by':'Micronesia', 'type':'typhoon'});
--Multiple labels not supported
CREATE (:V_MULTI_NO_PRO1':'V_MULTI_NO_PRO2);
--Multiple labels not supported
CREATE (:V_MULTI_NO_PRO3':'V_MULTI_NO_PRO4':'V_MULTI_NO_PRO5);
MATCH (n1:V_PRO1 {'id':763}), (n2:V_PRO1 {'id':552}) CREATE (n1)-[:'E_NO_PRO']->(n2);
MATCH (n1:V_PRO1 {'id':552}), (n2: {}) CREATE (n1)-[:'E_PRO4' {'test1':'something', 'test2':[100, 33, 21, 33], 'test3':'something2'}]->(n2);
MATCH (n1:V_PRO2 {'id':456, 'name':'Ted'}), (n2: {}) CREATE (n1)-[:'E_PRO3' {'finished_level':['spring', 'summer', 'fall', 'winter'], 'place':'United States', 'type':'purchased'}]->(n2);
MATCH (n1:V_PRO2 {'id':456, 'name':'Ted'}), (n2: {}) CREATE (n1)-[:'E_PRO2' {'common_interest':'Badminton', 'relation':'Friend'}]->(n2);
MATCH (n1:V_PRO2 {'id':456, 'name':'Ted'}), (n2: {}) CREATE (n1)-[:'E_PRO1' {'type':'purchased'}]->(n2);
MATCH (n1:V_PRO3 {'hobby':'Badminton', 'id':789, 'name':'Kim'}), (n2: {}) CREATE (n1)-[:'E_PRO3' {'place':'France', 'platform':'PC', 'type':'purchased'}]->(n2);
COMMIT;
```

Currently, above result used the multi-labels which are not processed by the preprocessor with the dump option. So, please exclude any multi-labels.

6. If you want to import the preprocessed result to AgensGraph, please type the following. Don't forget to use "--use-dump" option.
```sh
  $ perl preprocess.pl export.cypher --graph=TEMP --import-to-agens --use-dump
```

Or you can use the python interpreter instead.
```sh
  $ python preprocess.py export.cypher --graph=TEMP --import-to-agens --use-dump
```

Please note that the existing graph repository named TEMP will be removed and initialized. You can freely change the graph name above.

7. If it takes too long time for the dump, then you can use this command during the export. Don't forget to use "--use-dump" option.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ tail -f -n +1 export.cypher | perl preprocess.pl --graph=TEMP --import-to-agens --use-dump
```

Or you can use the python interpreter instead.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ tail -f -n +1 export.cypher | python preprocess.py --graph=TEMP --import-to-agens --use-dump
```


## GET SCHEMA INFO
### NEO4J
Lists all label constraints and indices on Neo4j:
```sh
  $ neo4j-shell
  neo4j-sh (?)$ schema
```

More recent version of Neo4j supports these calls (Check the row number):
```sh
  $ neo4j-shell
  neo4j-sh (?)$ CALL db.indexes();
  neo4j-sh (?)$ CALL db.constraints();
```

Counting total nodes:
```sh
  $ neo4j-shell
  neo4j-sh (?)$ MATCH (n) RETURN COUNT(*);
```

Counting total edges:
```sh
  $ neo4j-shell
  neo4j-sh (?)$ MATCH (n)-[r]->() RETURN COUNT(r);
```

### AGENSGRAPH
Lists all indices on AgensGraph  (Check the row number):
```sh
  $ agens
  agens=# \dGi+ [GRAPH_NAME].*
```

Lists all unique constraints on AgensGraph:
```sh
  $ agens
  agens=# \dGv [GRAPH_NAME].*
  agens=# \dGe [GRAPH_NAME].*
```

Counts the unique constraints only:
```sh
  $ echo "\dGv [GRAPH_NAME].*; \dGe [GRAPH_NAME].*;" | agens | grep -c "_unique_constraint"
```

Counting total nodes:
```sh
  $ agens
  agens=# SET GRAPH_PATH=[GRAPH_NAME];
  agens=# MATCH (n) RETURN COUNT(*);
```

Counting total edges:
```sh
  $ agens
  agens=# SET GRAPH_PATH=[GRAPH_NAME];
  agens=# MATCH (n)-[r]->() RETURN COUNT(r);
```

### NOTE
The count of edges/vertices may not match if there are multiple vertex-labels on Neo4j.
Please run this Cypher query statement. If the returned value is bigger than 1, then the source database has the multiple labels.
```sh
  $ neo4j-shell
  neo4j-sh (?)$ MATCH (n) RETURN max(length(labels(n)));
```

## TECHNIAL DETAILS
* Originally written in Perl, and subsequently ported to Python.
* '--graph=GRAPH_NAME' option cannot be omitted because every graph-related elements including vertices and edges must be stored in the repository.
* '--import-to-agens' option depends on the AgensGraph command line interface tool(agens). Connection-related options will be all forwarded to the interface.
* Multiple labels from Neo4j are automatically converted to the label inheritances in AgensGraph due to the architectural differences between the two databases. The parent vertex labels that start with "AG_MULV_(number)" will be created in the target side.
* Do not use '--use-dump' option for the multiple labels. For details, please refer to the DUMP OPTION section.

### USAGE
```
USAGE: perl preprocess.pl [--import-to-agens] [--graph=GRAPH_NAME] [--use-dump] [--help] [filename (optional if STDIN is provided)]
   Additional optional parameters for the AgensGraph integration:
      [--dbname=DBNAME] : Database name
      [--host=HOST]     : Hostname or IP
      [--port=PORT]     : Port
      [--username=USER] : Username
      [--no-password]   : No password
      [--password]      : Ask password (should happen automatically)
```

### APPLICATION INTEGRATION
Several interfaces are provided for the integration with applications. Direct methods are as below:
* Python: https://github.com/bitnine-oss/agensgraph-python
* NodeJS: https://github.com/bitnine-oss/agensgraph-nodejs
* Golang: https://github.com/bitnine-oss/agensgraph-golang
* JDBC: https://github.com/bitnine-oss/agensgraph-jdbc
* RestAPI via AgensBrowser

Other languages or implementations are also supported via JDBC. For example:
* Perl: https://metacpan.org/pod/JDBC
* R: http://rforge.net/RJDBC/

## SEE ALSO
* https://neo4j.com/developer/kb/export-sub-graph-to-cypher-and-import/
* https://bitnine.net/documentation/
