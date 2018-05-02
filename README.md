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
git clone  git clone -b release_18.01 https://github.com/galaxyproject/galaxy.git galaxy-repo
2. docker build -t naturalis/galaxy:<version number> .
```


