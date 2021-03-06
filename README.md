# DB Migration from Neo4j to AgensGraph

## INTRODUCTION
Preprocesses the Cypher statements from Neo4j so that they can be used for AgensGraph. This can be useful for the migration. There are couple of export options. Please refer to the EXPORT CYPHER and DUMP OPTION sections.

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
Besides the export-cypher method above, Neo4j's dump also can be used for the export to AgensGraph. However, you may have to drop the existing constraints because Neo4j complains about them.

### DROP ALL CONSTRAINTS
1. Check the existing indexes and constraints.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ ./bin/neo4j-shell
  neo4j-sh (?)$ CALL db.indexes();
  neo4j-sh (?)$ CALL db.constraints();
```

2. Drop the listed constraints manually. For details, please refer to:
* DROP INDEX: https://neo4j.com/docs/developer-manual/current/cypher/schema/index/
* DROP CONSTRAINT: https://neo4j.com/docs/developer-manual/current/cypher/schema/constraints/#constraints-drop-unique-constraint

### FOR THE SMALL DATA SET
1. Create a file that includes "dump" and run it with neo4j-shell. "neo4j-shell -c dump" also can be used but may not work properly in some systems.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ echo dump>dump.txt
  $ ./bin/neo4j-shell -file dump.txt>export.cypher
```

2. export.cypher file will be created. The contents of the file would be something like this:
```
begin
commit
begin
create (_18779:`service` {`name`:"Database VM"})
create (_18780:`service` {`name`:"Server 1"})
create (_18781:`service` {`name`:"Server 2"})
create (_18782:`service` {`name`:"SAN"})
create (_18783:`service` {`name`:"Public Website"})
create (_18784:`service` {`name`:"Webserver VM"})
create (_18822:`service` {`name`:"CRM"})
create (_18779)-[:`DEPENDS_ON`]->(_18781)
create (_18780)-[:`DEPENDS_ON`]->(_18782)
create (_18781)-[:`DEPENDS_ON`]->(_18782)
create (_18783)-[:`DEPENDS_ON`]->(_18784)
create (_18783)-[:`DEPENDS_ON`]->(_18779)
create (_18784)-[:`DEPENDS_ON`]->(_18780)
create (_18822)-[:`DEPENDS_ON`]->(_18779)
;
commit
```

3. Run the below command to begin the preprocess. Don't forget to use "--use-dump" option.
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
CREATE (:service {'name':'Database VM'});
CREATE (:service {'name':'Server 1'});
CREATE (:service {'name':'Server 2'});
CREATE (:service {'name':'SAN'});
CREATE (:service {'name':'Public Website'});
CREATE (:service {'name':'Webserver VM'});
CREATE (:service {'name':'CRM'});
MATCH (n1:service {'name':'Database VM'}), (n2:service {'name':'Server 2'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
MATCH (n1:service {'name':'Server 1'}), (n2:service {'name':'SAN'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
MATCH (n1:service {'name':'Server 2'}), (n2:service {'name':'SAN'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
MATCH (n1:service {'name':'Public Website'}), (n2:service {'name':'Webserver VM'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
MATCH (n1:service {'name':'Public Website'}), (n2:service {'name':'Database VM'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
MATCH (n1:service {'name':'Webserver VM'}), (n2:service {'name':'Server 1'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
MATCH (n1:service {'name':'CRM'}), (n2:service {'name':'Database VM'}) CREATE (n1)-[:DEPENDS_ON]->(n2);
COMMIT;
```

4. If you want to import the preprocessed result to AgensGraph, please type the following. Don't forget to use "--use-dump" option.
```sh
  $ perl preprocess.pl export.cypher --graph=TEMP --import-to-agens --use-dump
```

Or you can use the python interpreter instead.
```sh
  $ python preprocess.py export.cypher --graph=TEMP --import-to-agens --use-dump
```

Please note that the existing graph repository named TEMP will be removed and initialized. You can freely change the graph name above.

### FOR THE BIG DATA SET

1. If it takes too long time for the dump, then you can use this command during the export. Don't forget to use "--use-dump" option.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ echo dump>dump.txt
  $ ./bin/neo4j-shell -file dump.txt | perl preprocess.pl --graph=TEMP --import-to-agens --use-dump
```

Or you can use the python interpreter instead.
```sh
  $ cd /path/to/neo4j-community-3.4.5
  $ echo dump>dump.txt
  $ ./bin/neo4j-shell -file dump.txt | python preprocess.py --graph=TEMP --import-to-agens --use-dump
```

Please note that the existing graph repository named TEMP will be removed and initialized. You can freely change the graph name above.

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
* https://github.com/ykhwong/agensgraph_cypher_exporter
