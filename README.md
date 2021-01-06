# KIND
Kubernetes in Docker helper.


## Preparation
### macOS
Install Docker Desktop for Mac
```
brew install homebrew/cask/docker
```

Install `kubectl` command line and overwrite the symlinks created by Docker Desktop for Mac by running:
```
brew install kubernetes-cli
brew link --overwrite kubernetes-cli
```

Validate the installation finished successfully from the command line
```
docker --version
kubectl version
```

## Installation
```
git clone git@github.com:humansriot/kind.git
ln -s $PWD/kind/kind_create.sh /usr/local/bin/kind_create
```

## Usage
`kind_create` script creates kubernetes cluster with local registry and NGINX ingress controller.

Create cluster with default configuration
```
kind_create
```

Create cluster with given configuration
```
kind_create config.yaml
```

Create cluster with given configuration and change name
```
kind_create config.yaml name
```
