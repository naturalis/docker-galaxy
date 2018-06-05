# Docker setup for Galaxy

### How to use
```
docker-compose up -d
```
then add to your `hosts` file
```
127.0.0.1 galaxy.naturalis.nl
```

### How to build te container

```
1. Clone galaxy repo
git clone  git clone -b release_18.05 https://github.com/galaxyproject/galaxy.git galaxy-repo
2. docker build -t naturalis/galaxy:relase_18.05-1 .
```

Tags of the containers should be
```
<galaxy-repo-tag>-<build number>
```
So for example
```
release_18.05-1
release_18.05-2
release_18.07-1
```

### How to upgrade to a newer version of Galaxy
First pull the latest data in the `galaxy-repo` directory. Then set to the new tag (for example release_18.05)

```
docker run --rm -v $(pwd)/galaxy.yml:/galaxy/config/galaxy.yml --link dockergalaxy_database_1:database --network dockergalaxy_default naturalis/galaxy:<new_tag> sh manage_db.sh upgrade
```
Then set the new version in the `docker-compose.yml` and run `docker-compose up -d`	
