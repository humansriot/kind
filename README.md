# KIND
Kubernetes in Docker helper.
`kind_helper` command creates kubernetes cluster with local registry and NGINX ingress controller.

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

Install `kind` command line.
```
brew install kind
```
### Linux
Install `docker` by following [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian) documentation.

Install `kubectl` by following [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl) documentation.

Install `kind` by following [Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) documentation.

### Windows
TODO

## Installation
### macOS/Linux
```
curl -fsSL https://raw.githubusercontent.com/humansriot/kind/master/install.sh | bash
```
### Windows
TODO

Validate the installation finished successfully.
```
kind_helper doctor
```

## Update
In order to update `kind_helper` command.
```
kind_helper update
```

## Usage
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
