# KIND
Kubernetes in Docker helper.


## Preparation
### macOS
Install Docker Desktop for Mac
```
brew install homebrew/cask/docker
```

Install `kubectl` command line and overwrite the symlinks created by Docker Desktop for Mac.
```
brew install kubernetes-cli
brew link --overwrite kubernetes-cli
```

Validate the installation finished successfully.
```
docker --version
kubectl version
```

## Installation
### macOS/Linux
```
curl -fsSL https://raw.githubusercontent.com/humansriot/kind/master/install.sh | bash
```
### Windows
TODO
## Update


## Usage
`kind_create` script creates kubernetes cluster with local registry and NGINX ingress controller.

Create cluster with default configuration.
```
kind_helper create
```

Create cluster with given configuration.
```
kind_helper create config.yaml
```

Create cluster with given configuration and change name.
```
kind_helper create config.yaml name
```

Test cluster
```
kind_helper test
```
