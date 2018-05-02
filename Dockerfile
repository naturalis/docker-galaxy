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
RUN pip install psycopg2==2.6.1 #for postgres connection
#COPY galaxy.yml /galaxy/config/galaxy.yml
CMD sh run.sh --no-create-venv --skip-venv --skip-wheels
