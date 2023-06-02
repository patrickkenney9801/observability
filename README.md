# Observability

Observability is a git repo for `flux` to watch and sync common
observability tools for logging, tracing, metrics, and code coverage
on a Kubernetes cluster.

## Authors

Patrick Kenney

## Tools

### [asdf](https://asdf-vm.com)

Provides a declarative set of tools pinned to
specific versions for environmental consistency.

These tools are defined in `.tool-versions`.
Run `make dependencies` to initialize a new environment.

### [pre-commit](https://pre-commit.com)

A left shifting tool to consistently run a set of checks on the code repo.
Our checks enforce syntax validations and formatting.
We encourage contributors to use pre-commit hooks.

```shell
# install all pre-commit hooks
make hooks

# run pre-commit on repo once
make pre-commit
```

### [flux2](https://fluxcd.io/)

A set of continuous delivery solutions for Kubernetes.

### [terraform](https://www.terraform.io/)

Tool for infrastructure as code.

## Usage

To deploy `flux` on a cluster create the file `flux/overrides.tf`
and add the following defaults:

To get a github token see
<https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens>.

```shell
  variable "github_token" { default = "ghp_XXX" }
  variable "kube_context" { default = "observability" }
```

Then run:

```shell
  make apply
```
