# Install Helm CLI

## Introduction

[Helm](https://helm.sh/) is a package manager and application management tool for Kubernetes that packages multiple Kubernetes resources into a single logical deployment unit called a Chart.

* Helm helps you to:
  - Achieve a simple (one command) and repeatable deployment
  - Manage application dependency, using specific versions of other application and services
  - Manage multiple deployment configurations: test, staging, production and others
  - Execute post/pre deployment jobs during application deployment
  - Update/rollback and test application deployments


## Installing Helm

Before we can get started configuring Helm, we'll need to first install the command line tools.

```bash
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

We can verify the installation by

```bash
helm version --short
```

Let’s configure our first Chart repository. Chart repositories are similar to APT or yum repositories that you might be familiar with on Linux, or Taps for Homebrew on macOS.

Download the `stable` repository so we have something to start with:

```bash
helm repo add stable https://charts.helm.sh/stable
```

Once this is installed, we will be able to list the charts you can install:

```bash
helm search repo stable
```