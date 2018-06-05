FROM python:2

RUN mkdir /galaxy
WORKDIR /galaxy
COPY galaxy-repo/requirements.txt ./

RUN pip install \
    --no-cache-dir \
		--index-url https://wheels.galaxyproject.org/simple \
		--extra-index-url https://pypi.python.org/simple \
		-r requirements.txt
COPY galaxy-repo /galaxy
RUN pip install \
    psycopg2==2.6.1 \
		watchdog #for postgres connection and watchdog service

ENV DOCKER_CLIENT_VERSION=18.03.1
RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLIENT_VERSION-ce.tgz \
    && tar -zxvf docker-$DOCKER_CLIENT_VERSION-ce.tgz docker/docker \
		&& mv docker/docker /usr/bin/docker \
		&& rm -fr docker docker-$DOCKER_CLIENT_VERSION-ce.tgz

CMD sh run.sh --no-create-venv --skip-venv --skip-wheels
