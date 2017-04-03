FROM r-base:3.3.1
MAINTAINER atze.devries@naturalis.nl
# clone release on 16.10
ENV GALAXY_ADMIN_USERS=None \
    GMAIL_USERNAME=mail \
    GMAIL_PASSWORD=pass \
    GALAXY_WHEELS_INDEX_URL=https://wheels.galaxyproject.org/simple \
    PATH="/usr/lib/abyss/":$PATH \
    PUPPET_AGENT_VERSION="1.6.1" \
    CODENAME="xenial" \
    PUPPET_BIN="/opt/puppetlabs/bin/puppet" \
    MODULE_DIR="/etc/puppetlabs/code/environments/production/modules"

RUN apt-get update && \
    apt-get install --no-install-recommends -y lsb-release wget ca-certificates && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-"$CODENAME".deb && \
    dpkg -i puppetlabs-release-pc1-"$CODENAME".deb && \
    rm puppetlabs-release-pc1-"$CODENAME".deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y git puppet-agent="$PUPPET_AGENT_VERSION"-1"$CODENAME" && \
    apt-get install -y unzip zip python-pip

RUN $PUPPET_BIN module install puppetlabs/stdlib ; \
    $PUPPET_BIN module install puppet/archive ; \
    $PUPPET_BIN module install puppetlabs/vcsrepo

ADD puppet-apply-wrapper /usr/local/bin/puppet-apply-wrapper
RUN chown root:root /usr/local/bin/puppet-apply-wrapper \
    && chmod 755 /usr/local/bin/puppet-apply-wrapper

ADD puppet/bioinformatics $MODULE_DIR/bioinformatics
ADD puppet/galaxy $MODULE_DIR/galaxy

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

RUN echo "include ::galaxy::install \
         " > /tmp/galaxy.pp

RUN puppet-apply-wrapper /tmp/galaxy.pp

RUN echo "include ::galaxy::naturalis_config \
          " > /tmp/naturalis_galaxy.pp

RUN puppet-apply-wrapper /tmp/naturalis_galaxy.pp

RUN mkdir -p /home/galaxy/GenBank && \
    mkdir -p /home/galaxy/Tools && \
    mkdir -p /home/galaxy/shed_tools && \
    mkdir -p /home/galaxy/Log && \
    mkdir -p /home/galaxy/ExtraRef && \
    ln -s /opt/galaxy-naturalis/Data_Scripts /home/galaxy/Tools/GetUpdate && \
    ln -s /opt/galaxy-naturalis/Galaxy_Configuration/ncbirc /root/.ncbirc

ENV URL_USEARCH='' \
    URL_UNITE='' \
    URL_SILVA='' \
    UPDATE_GENBANK='no' \
    UPDATE_TAXA='no'

WORKDIR /opt/galaxy

#RUN apt-get remove --purge -y lsb-release ca-certificates && \
#    apt-get autoremove -y && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* 

ADD bootstrap.sh /bootstrap.sh
CMD sh /bootstrap.sh
