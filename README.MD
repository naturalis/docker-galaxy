# Galaxy for Naturalis

## Global overview

Galaxy for Naturalis is packaged as a *Docker* image. This makes it very easy to reproduce and to run anywhere. The configuration of the images is mostly done by Puppet. The image is based on the rocker/verse version of the r-base docker image, this uses debian stable versions instead of testing.
A docker-compose.yml is add for easy configuration / running. 

## Running

The easy way, use docker-compose with the included docker-compose.yml. Traefik is included in the compose file to allow for the site being accessable using port 80 on galaxy.naturalis.nl (adjust hosts file for easy testing):

```shell
docker-compose up
```

### Troubleshooting
1. If you get the following error:
   ```shell
   ERROR: Network web declared as external, but could not be found. Please create the network manually using `docker network    create web` and try again.
   ```
   First do:
   ```shell
   docker network create web
   ```
2. If you get:
   ```shell
   Cannot start service galaxy-database: Mounts denied [...]
   ```
   (Encountered on Mac OSX): make sure that the path that docker is trying to mount actually exists, and that the 
   folder (or one of its ancestors) is shared through the docker interface: Docker > Preferences > File Sharing, and
   add the folder.
3. The `traefik` reverse proxy is listening for galaxy.naturalis.nl to redirect traffic. Hence, when running locally
   you will need to update the `/etc/hosts` file, for example by changing the entry: 
   ```127.0.0.1	localhost```
   To:
   ```127.0.0.1	localhost galaxy.naturalis.nl```

Docker binary is available from within galaxy container this makes it possible to use docker and connect to the host docker daemon from within the container. 
For integration options see: https://galaxyproject.org/admin/tools/docker/

### Requirements

Before running make sure you have `docker-engine` installed. Check the [official installation manual](https://docs.docker.com/engine/installation/). Galaxy is configured to run against a Postgress database. You can run a postgres container like this:
```shell
docker run -d --name galaxy-database \
  -v /postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD="98dkk398910askks_all" \
  postgres:9.6-alpine
```
### Running galaxy

When staring a Galaxy container you need to set a few settings. The following settings are important:

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
  -e URL_USEARCH="http://drive5.com/cgi-bin/upload3.py?license=<your license key>" \
  -e URL_UNITE="https://unite.ut.ee/sh_files/sh_general_release_20.11.2016.zip" \
  -e URL_SILVA="https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_LSURef_tax_silva.fasta.gz" \
  -e UPDATE_GENBANK=yes \
  -e UPDATE_TAXA=yes \
  --link galaxy-database:db \
  -v /disk/docker-vols/galaxy/GenBank/:/home/galaxy/GenBank  \
  -v /disk/docker-vols/galaxy/ExtraRef/:/home/galaxy/ExtraRef \
  naturalis/galaxy:0.0.1
```

## Modifying Galaxy

### Required files

First clone this repository:
```SHELL
git clone https://github.com/naturalis/docker-galaxy
```
Then go into the puppet directory
```SHELL
cd docker-galaxy/puppet
```
Then clone the Puppet repositories
```SHELL
git clone https://github.com/naturalis/puppet-bioinformatics bioinformatics
git clone https://github.com/naturalis/puppet-galaxy galaxy
```

### Adding Software packages

All software packages are installed with Puppet code. The Puppet repository is `bioinformatics`. For each package that needs to be installed we make a `manifest` (a `.pp` file). Take a look a the current `.pp` files to check out how use Puppet.
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
docker build -t naturalis/galaxy:<tag name>
```
Where `<tag name>` can be a tag to link to this specific docker image, for example `testing` or `1.2.6`

The puppet code repository [can be found here](https://github.com/naturalis/puppet-bioinformatics).

### Updating / Changing galaxy

Galaxy is installed with Puppet code. This is done in two phases, first galaxy is installed and then some modifications are applied.
In the Dockerfile you can see there are two parts. First installing galaxy:

```Dockerfile
RUN echo "include ::galaxy::install \
         " > /tmp/galaxy.pp

RUN puppet-apply-wrapper /tmp/galaxy.pp
```
Here galaxy is installed. You can change stuff like the version of Galaxy. 

In the second part some patches are installed. Like a different welcome page etc. 
```Dockerfile
RUN echo "include ::galaxy::naturalis_config \
         " > /tmp/naturalis_galaxy.pp

RUN puppet-apply-wrapper /tmp/naturalis_galaxy.pp
```

The Puppet code repository [can be found here](https://github.com/naturalis/puppet-galaxy).

### Adding tools

The general approach for adding tools to Dockerized galaxy is as follows:

1. Dockerize the tool. Any convoluted, Galaxy-specific logic (e.g. collecting output files into archives) should be
   isolated inside the container.
2. Write a wrapper.xml that invokes the tool via `docker run`
3. Contribute this wrapper.xml to the github repo for dockerized galaxy tools
4. Update the tools.xml inside the github repo for dockerized galaxy tools
