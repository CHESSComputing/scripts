# CHESSComputing scripts
Set of scripts to manage CHESSComputing services

```
# run git commit for all services with specific message
./scripts/git-commit.sh "my commit"

# push changes to upstream server
./scripts/git-push.sh

# retag all services
./scripts/git-retag.sh v0.0.1-dev7

# push changes to upstream server
./scripts/git-push-tags.sh

./scripts/git-tag.sh v0.0.1-dev8
./scripts/git-push-tags.sh

# show all tags
./scripts/git-all-tags.sh

# show last tag
./scripts/git-last-tag.sh

# pull out from upstream server
./scripts/git-pull.sh

# show git status for all services
./scripts/git-status.sh

# perform go mod init and go mod tidy for all services, i.e. update all depdencies
./scripts/git-update.sh

# list existing releases
./scripts/rel.sh

# list all GitHub actions for (default) go action
./scripts/wflow-status.sh

# list all GitHub actions for release action
./scripts/wflow-status.sh release

# build all services
./scripts/make.sh

# rebuild all services, i.e. go get -u && make
./scripts/rebuild.sh

# run make test for all services
./scripts/test.sh

# manage script for all services
./scripts/manage <start|restart|stop|status>

# run minio server
./scripts/minio.sh
```
