#!/bin/bash

# Will download some libs
# Can download extra databases and usearch
#
# URL_USEARCH='' \
#     URL_UNITE='' \
#     URL_SILVA=''

CURDIR=$(pwd)

cd /home/galaxy/Tools/GetUpdate

if [ "$URL_USEARCH" ]
then
  echo "Downloading USEARCH"
  curl -L -s $URL_USEARCH > /usr/bin/usearch
  chmod +x /usr/bin/usearch
  usearch
else
  echo "No USEARCH URL given"  #statements
fi

if [ "$URL_UNITE" ]
then
  echo "Downloading UNITE Database"
  TMP_DIR=$(mktemp -d -p /home/galaxy/ExtraRef)
  curl -k -L $URL_UNITE > $TMP_DIR/fasta.zip
  (cd $TMP_DIR ; unzip fasta.zip)
  (cd $TMP_DIR ; for f in *.fasta ; do  /opt/galaxy-naturalis/Data_Scripts/Clean_FASTA.py -f $f  > /home/galaxy/ExtraRef/unite.fasta; done)
  (cd /home/galaxy/ExtraRef ; makeblastdb -in unite.fasta -dbtype nucl)
  rm -fr $TMP_DIR
else
  echo "No UNITE URL given"  #statements
fi

if [ "$URL_SILVA" ]
then
  echo "Downloading SILVA Database"
  TMP_DIR=$(mktemp -d -p /home/galaxy/ExtraRef)
  (cd $TMP_DIR ; curl -L -k $URL_SILVA | gunzip - > silva.fasta )
  (cd $TMP_DIR ; for f in *.fasta ; do  /opt/galaxy-naturalis/Data_Scripts/Clean_FASTA.py -f $f  > /home/galaxy/ExtraRef/silva.fasta; done)
  (cd /home/galaxy/ExtraRef ; makeblastdb -in silva.fasta -dbtype nucl)
  rm -fr $TMP_DIR
else
  echo "No SILVA URL given"  #statements
fi

if [ "$UPDATE_GENBANK"  = "yes" ]
then
  echo "Will now download BLAST GenBank Database"
  /bin/bash GetNt.sh
else
  echo "BLAST Genbank database will not be updated"
fi

if [ "$UPDATE_TAXA"  = "yes" ]
then
  echo "Will now download BLAST Taxa Database"
  /bin/bash GetTax.sh
else
  echo "BLAST Taxa database will not be updated"
fi

cd $CURDIR

export GALAXY_DB='postgres://postgres:'$DB_ENV_POSTGRES_PASSWORD'@db:5432/postgres'
python /opt/env_to_ini.py /opt/galaxy.ini.template /opt/galaxy/config/galaxy.ini
sh run.sh --no-create-venv --skip-venv
