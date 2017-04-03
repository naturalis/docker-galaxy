# Galaxy for Naturalis

### Global overview

Galaxy for Naturalis is packages as a *Docker* image. This makes is very easy to reproduce and to run anywhere. The configuratioin of the images is mostly done by puppet. The image is based on the official r-base docker image.

## Running

#### Requirements

Before running make sure you have `docker-engine` installed. Check https://docs.docker.com/engine/installation/. Galaxy is configured to run against a Postgress database. You can run a postgres container like
```shell
docker run -d --name galaxy-database \
  -v /postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD="98dkk398910askks_all" \
  postgres:9.6-alpine
```
#### Running galaxy

When staring a Galaxy container you need to set a few settings. The following settings are important

`GALAXY_ADMIN_USERS` - list of admin users for galaxy at deployment

`GMAIL_USERNAME` - username for galaxy mail

`GMAIL_PASSWORD` - password for galaxy mail

`URL_USEARCH` - default empty, should contain download url of USEARCH. You can request a license at http://www.drive5.com/usearch/download.html

`URL_UNITE` - default empty, should contain the url to Unite database.

`URL_SILVA` - default empty, should contain the url to Silva database.

`UPDATE_GENBANK` - default `no`, set to `yes` if you want to install or update the GenBank database.

`UPDATE_TAXA` - default `no`, set to `yes` if you want to install or update the Taxa database.



```SHELL
docker run -d --name galaxy \
  -e URL_USEARCH=http://drive5.com/cgi-bin/upload3.py?license=<your license key>
  -e URL_UNITE=https://unite.ut.ee/sh_files/sh_general_release_20.11.2016.zip
  -e URL_SILVA=https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_LSURef_tax_silva.fasta.gz
  -e UPDATE_GENBANK=yes
  -e UPDATE_TAXA=yes
  --link galaxy-database:db \
  -v /disk/docker-vols/galaxy/GenBank/:/home/galaxy/GenBank  \
  -v /disk/docker-vols/galaxy/ExtraRef/:/home/galaxy/ExtraRef \
  atzedevries/naturalis_galaxy:17_01
```



## Modifying Galaxy

#### Adding Software packages

All software packages are installed with puppet code. The puppet repository is `bioinformatics`. For each package to install we make a `manifest` (a `.pp` file). Take a look a the current `.pp` files to check out how use puppet.
If you have created a new `.pp` file, you need to add it to the `Dockerfile`. Find the line with
```Dockerfile
RUN echo "include ::bioinformatics::cd_hit \
	  include ::bioinformatics::ncbi_blast \
          include ::bioinformatics::soap \
          include ::bioinformatics::transabyss \
          include ::bioinformatics::phyloseq \
          include ::bioinformatics::kronatools \
          include ::bioinformatics::prinseq \
          include ::bioinformatics::biopython \
          " > /tmp/bioinformatics.pp

RUN puppet-apply-wrapper /tmp/bioinformatics.pp
```
And insert after `include ::bioinformatics::biopython \` a new line with `include ::bioinformatics::your_manifest_name \`

The you need to build a new docker image. You can do this with the following command
```Shell
docker build -t atzedevries/naturalis_galaxy:<tag name>
```
Where `<tag name>` can be a tag to link to this specific docker image, for example `testing` or `1.2.6`

The puppet code repository can be found here: https://github.com/naturalis/puppet-bioinformatics
#### Updating / Chaning galaxy

Galaxy is installed with puppet code. This is done in two phases, first galaxy is installed and then some modifications are applied.
In the Dockerfile you can see there are two parts. First installing galaxy:
```Dockerfile
RUN echo "include ::galaxy::install \
         " > /tmp/galaxy.pp

RUN puppet-apply-wrapper /tmp/galaxy.pp
```
Here galaxy is installed. You can change stuff like the version of Galaxy. 

In the second pard some patches are installed. Like a different welcome page etc. 
```Dockerfile
RUN echo "include ::galaxy::naturalis_config \
         " > /tmp/naturalis_galaxy.pp

RUN puppet-apply-wrapper /tmp/naturalis_galaxy.pp
```

The puppet code repository can be found here: https://github.com/naturalis/puppet-galaxy
