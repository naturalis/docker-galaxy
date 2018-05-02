docker run -d --name galaxy-database \
  -v /postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD="98dkk398910askks_all" \
  postgres:9.6-alpine

docker run -d --name galaxy \
  -e URL_USEARCH="http://drive5.com/cgi-bin/upload3.py?license=<your license key>" \
  -e URL_UNITE="https://unite.ut.ee/sh_files/sh_general_release_20.11.2016.zip" \
  -e URL_SILVA="https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_LSURef_tax_silva.fasta.gz" \
  -e UPDATE_GENBANK=no \
  -e UPDATE_TAXA=no \
  --link galaxy-database:db \
  -v /disk/docker-vols/galaxy/GenBank/:/home/galaxy/GenBank  \
  -v /disk/docker-vols/galaxy/ExtraRef/:/home/galaxy/ExtraRef \
  naturalis/galaxy:0.0.1
