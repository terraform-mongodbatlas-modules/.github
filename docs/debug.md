# Debug guide

Use this guide to:

- Narrow down problems in your Terraform setup.
- Tell provider issues from module issues from your own root-module wiring.
- Identify when to report a bug.

## Narrow down your configuration

Before opening an issue or a support ticket, capture the following about **your** deployment:

- **Terraform version:** `terraform version`
- **Provider and module versions:** `terraform providers` (or the lock file)
- **Pinned module sources:** `version` constraints and Registry module addresses in your root module
- **Redacted HCL:** Remove API keys, connection strings, and secrets from anything you paste publicly

Try to reproduce the problem with the **smallest root module** that still shows the behavior. Compare against [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) when the issue involves a full stack.

## Logging

Use the following logging options to get more visibility into Terraform and the provider's behavior.

- **Terraform core:** `TF_LOG=DEBUG terraform plan` (or `apply`). Use `TF_LOG_PATH` to write logs to a file.
- **Provider:** `TF_LOG_PROVIDER=DEBUG` limits verbose output to the MongoDB Atlas provider. See [Terraform logging](https://developer.hashicorp.com/terraform/internals/debugging).
- **Plan output:** Save `terraform plan -out=plan.out` and `terraform show -json plan.out` when you need structured plan details for an issue.

Attach relevant log excerpts to GitHub issues; redact credentials and internal hostnames.

## Provider vs module vs your root module

Before you open an issue, use the following table to figure out which layer the problem actually lives in (the provider, a module, or your own configuration) so you report it in the right place.

| Symptom | Likely layer | Where to report |
|---------|--------------|-----------------|
| Atlas API error on a provider resource, wrong attribute on `mongodbatlas_*` resource, provider crash | [terraform-provider-mongodbatlas](https://github.com/mongodb/terraform-provider-mongodbatlas) | Provider repository |
| Module default, variable validation, submodule wiring, or documented module behavior | Module repo in the [org profile repository table](../profile/README.md#repositories) | That module's GitHub issues |
| How your root module calls modules, backend choice, or workspace layout | Your Terraform project | Your team; compare with module README examples |
| Wrong link, template, or hub doc in this org defaults repo | This repository | Issues in `.github` |

When unsure, run the module's minimal example from its README. If the example fails the same way, the issue is likely in the module or provider. If only your root module fails, check how you wire inputs, outputs, and dependencies.

## Upgrade and plan surprises

Module upgrades might introduce new defaults, renamed resources, or state changes that surprise your `terraform plan`. Consider the following before and after bumping a module version.

- Read the **upgrade guide** in the module repo for the target version before bumping `version` in your root module.
- **Unexpected plan changes** after a module upgrade often come from new defaults or renamed resources; check the changelog and upgrade guide.
- **New features via `default_feature_set`:** modules follow semantic versioning, so minor and patch upgrades do not break your configuration, but with the default `default_feature_set = "RECOMMENDED"` new recommended features are enabled automatically and can show up as plan changes after a minor upgrade. Set `default_feature_set = "STANDARD"` to opt out; see your module's README for details.
- **State moves** between module major versions may require `moved` blocks or a documented migration path; follow the module's upgrade guide rather than tainting resources without a plan.

Run `terraform plan` in a non-production workspace first when testing upgrades.

## Where to file issues

Report each issue in the channel that matches its nature.

- **Module bug or docs in a specific repo:** Open an issue in that module repository.
- **Provider bug:** [terraform-provider-mongodbatlas issues](https://github.com/mongodb/terraform-provider-mongodbatlas/issues).
- **Org hub** (profile, `docs/`, inherited templates): Open an issue in this repository.
- **Production Atlas or contracted support:** [MongoDB Atlas Support](https://support.mongodb.com/) per [SUPPORT.md](../SUPPORT.md).

GitHub issues are for community reporting; they do not replace Atlas Support if you have a support contract.

## Further reading

- [Getting started](./getting-started.md)
- [Org profile repository table](../profile/README.md#repositories)
- [MongoDB Atlas provider documentation](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs)
- [Get started with Terraform and the MongoDB Atlas provider](https://www.mongodb.com/docs/atlas/terraform/)
- [Deploy MongoDB Atlas with Terraform Modules](https://www.mongodb.com/docs/atlas/terraform-modules-landing-zone/)
- [Atlas Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/)
- [Guidance for automated infrastructure provisioning](https://www.mongodb.com/docs/atlas/architecture/current/automation/)
- [Atlas API reference](https://www.mongodb.com/docs/api/doc/atlas-admin-api-v2/) (when correlating provider errors with Admin API behavior)
