# DB Migration from Neo4j to AgensGraph
- Author: Taewoong Yoo

## INTRODUCTION
Preprocesses the Cypher statements from Neo4j so that they can be used for AgensGraph. This can be useful for the migration.

## SETUP
The following setup is required on the Neo4j server.

1. Install the APOC library ( https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases ).
Copy the library(e.g, apoc-3.4.0.2-all.jar) to the plugins directory.

2. Add the following line to the conf/neo4j.conf.
```
apoc.export.file.enabled=true
```

3. Install ‘neo4j-shell tools’.
```sh
$ cd /path/to/neo4j-community-3.0.1
$ curl http://dist.neo4j.org/jexp/shell/neo4j-shell-tools_3.0.1.zip -o neo4j-shell-tools.zip
$ unzip neo4j-shell-tools.zip -d lib
```

4. Download the preprocess.pl for preprocessing the Cypher statements.
```sh
$ git clone https://github.com/ykhwong/neo4j_to_agensgraph.git
$ ls neo4j_to_agensgraph/preprocess.pl
```

## EXPORT CYPHER

1. Run the cypher-shell and type the following.

```
export-cypher -o export.cypher
```

export.cypher will be created on the neo4j directory.
The contents of the file would be something like this:

```
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

2. Run the below command.
```sh
$ cat export.cypher | perl preprocess.pl
```

You’ll see the preprocessed output which can be used for AgensGraph.
```
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
MATCH (n1:person {'name':'Jim'}), (n2:person{'name':'Billy'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Jim'}), (n2:person{'name':'Mike'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Anna'}), (n2:person{'name':'Jim'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Anna'}), (n2:person{'name':'Mike'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Sally'}), (n2:person{'name':'Anna'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Joe'}), (n2:person{'name':'Sally'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Joe'}), (n2:person{'name':'Bob'}) CREATE (n1)-[r:KNOWS]->(n2);
MATCH (n1:person {'name':'Bob'}), (n2:person{'name':'Sally'}) CREATE (n1)-[r:KNOWS]->(n2);
COMMIT;
BEGIN;
COMMIT;
BEGIN;
COMMIT;
```

If you want to import the preprocessed result to AgensGraph, please type the following.
```sh
(echo "DROP GRAPH IF EXISTS TEMP CASCADE; CREATE GRAPH TEMP; SET GRAPH_PATH=TEMP;"&&cat export.cypher | perl preprocess.pl) | agens
```

Here, please note that the GRAPH_PATH will be set to TEMP. You can change the path depending on preference.

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

## SEE ALSO
* https://neo4j.com/developer/kb/export-sub-graph-to-cypher-and-import/
