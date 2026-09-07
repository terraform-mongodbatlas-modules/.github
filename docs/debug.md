# Debug guide

Use this guide to reproduce a customer configuration, narrow provider vs module vs caller issues, and choose where to report problems.

## Reproduce a customer configuration

Collect the following before sharing configs externally:

- **Terraform version:** `terraform version`
- **Provider and module versions:** `terraform providers` (or the lock file)
- **Pinned module sources:** `version` constraints and Registry module addresses in the root module
- **Redacted HCL:** Remove API keys, connection strings, and secrets from shared snippets

Ask the customer for the smallest root module that still shows the behavior. Compare against [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) when the issue involves a full stack.

## Logging

- **Terraform core:** `TF_LOG=DEBUG terraform plan` (or `apply`). Use `TF_LOG_PATH` to write logs to a file.
- **Provider:** `TF_LOG_PROVIDER=DEBUG` limits verbose output to the MongoDB Atlas provider. See [Terraform logging](https://developer.hashicorp.com/terraform/internals/debugging).
- **Plan output:** Save `terraform plan -out=plan.out` and `terraform show -json plan.out` when you need structured plan details for an issue.

Attach relevant log excerpts to GitHub issues; redact credentials and internal hostnames if needed.

## Provider vs module vs caller

| Symptom | Likely layer | Where to report |
|---------|--------------|-----------------|
| Atlas API error on a provider resource, wrong attribute on `mongodbatlas_*` resource, provider crash | [terraform-provider-mongodbatlas](https://github.com/mongodb/terraform-provider-mongodbatlas) | Provider repository |
| Module default, variable validation, submodule wiring, or documented module behavior | Module repo in the [org profile repository table](../profile/README.md#repositories) | That module's GitHub issues |
| How the customer's root module calls modules, backend, or workspace layout | Caller's repository | Customer or internal team |
| Wrong link, template, or hub doc in this org defaults repo | This repository | Issues in `.github` |

When unsure, reproduce with the module's minimal example from its README. If the example fails the same way, suspect the module or provider; if only the customer's root module fails, suspect caller wiring.

## Upgrade and plan surprises

- Read the **upgrade guide** in the module repo for the target version before bumping `version` in your root module.
- **Unexpected plan changes** after a module upgrade often come from new defaults or renamed resources; check the changelog and upgrade guide.
- **State moves** between module major versions may require `moved` blocks or a documented migration path; follow the module upgrade guide rather than tainting resources without a plan.

Run `terraform plan` in a non-production workspace first when testing upgrades.

## Where to file issues

- **Module bug or docs in a specific repo:** Open an issue in that module repository.
- **Provider bug:** [terraform-provider-mongodbatlas issues](https://github.com/mongodb/terraform-provider-mongodbatlas/issues).
- **Org hub** (profile, `docs/`, inherited templates): Open an issue in this repository.
- **Production Atlas or contracted support:** [MongoDB Atlas Support](https://support.mongodb.com/) per [SUPPORT.md](../SUPPORT.md).

GitHub issues are for community reporting; they do not replace Atlas Support for customers with a support contract.

## Further reading

- [Getting started](./getting-started.md)
- [Org profile repository table](../profile/README.md#repositories)
- [MongoDB Atlas provider documentation](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs)
- [Get started with Terraform and the MongoDB Atlas provider](https://www.mongodb.com/docs/atlas/terraform/)
- [Deploy MongoDB Atlas with Terraform Modules](https://www.mongodb.com/docs/atlas/terraform-modules-landing-zone/)
- [Atlas Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/)
- [Guidance for automated infrastructure provisioning](https://www.mongodb.com/docs/atlas/architecture/current/automation/)
- [Atlas API reference](https://www.mongodb.com/docs/api/doc/atlas-admin-api-v2/) (when correlating provider errors with Admin API behavior)
