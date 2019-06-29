                                                     
# eggnog.tsv file in /data/data2services

docker run -it --rm -v /data/emonet/ncats:/data data2services-download --download-datasets eggnog

docker run -dit --rm -p 8047:8047 -p 31010:31010 --name drill -v /data:/data:ro apache-drill

docker run -it --rm --link drill:drill -v /data:/data autor2rml \
        -j "jdbc:drill:drillbit=drill:31010" -r \
        -o "/data/emonet/ncats/eggnog/mapping.trig" \
        -d "/data/emonet/ncats/eggnog" \
        -b "https://w3id.org/data2services/" \
        -g "https://w3id.org/data2services/graph/autor2rml/eggnog"

docker run -it --rm --link drill:drill \
  -v /data/emonet/ncats/eggnog:/data \
  r2rml /data/config.properties

# Load RDF file in GraphDB ncats-test repository

# Split ProteinsIds: http://graphdb.dumontierlab.com/resource?uri=https:%2F%2Fw3id.org%2Fdata2services%2Fdata%2Femonet%2Fncats%2Feggnog%2FNOG.members.tsv%2F100700
docker run -d --name split-eggnog --link graphdb:graphdb \
  vemonet/data2services-sparql-operations -op split \
  --split-property "https://w3id.org/data2services/model/Proteinids" \
  --split-class "https://w3id.org/data2services/data/emonet/ncats/eggnog/NOG.members.tsv" \
  --split-delimiter "," \
  --split-delete \
  -ep "http://graphdb:7200" \
  -uep "bio2vec-test" \
  -un emonet -pw PASSWORD

docker run -d --name convert_eggnog --link graphdb:graphdb data2services-sparql-operations -f "https://github.com/MaastrichtU-IDS/data2services-transform-repository/tree/master/sparql/insert-biolink/eggnog" -ep "http://graphdb:7200/repositories/bio2vec/statements" -un emonet -pw $PASSWORD -var serviceUrl:http://localhost:7200/repositories/bio2vec-test inputGraph:https://w3id.org/data2services/graph/autor2rml/eggnog outputGraph:https://w3id.org/data2services/graph/biolink/eggnog
# Running time

docker run -d --link graphdb:graphdb data2services-sparql-operations -f "https://github.com/MaastrichtU-IDS/data2services-transform-repository/tree/master/sparql/compute-hcls-stats" -ep "http://graphdb:7200/repositories/bio2vec/statements" -un emonet -pw $PASSWORD -var inputGraph:https://w3id.org/data2services/graph/biolink/eggnog
