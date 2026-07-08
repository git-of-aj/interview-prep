- Blocks are containers for other content and usually represent the configuration of some kind of object
## Workflow
- recommended to use VCS (git) even for individual
- TF plan is good sanity check but multiple team members To avoid the burden and the security risk of each team member arranging all sensitive inputs locally, just to run tf plan is `bad idea`... so use `CI tools.`
- The natural place for these `tf plan output` reviews to occur is alongside pull requests within version control--the point at which an individual proposes a merge from their working branch to the shared team branch.
- In addition to reviewing the plan for the proper expression of its author's intent, the team can also make an evaluation whether they want this change to happen now. For example, if a team notices that a certain change could result in service disruption, they may decide to delay merging its pull request until they can schedule a maintenance window.
### Terraform
*   **`terraform` block** = top‑level parent block that configures Terraform’s own behavior.
*   Only **constant (literal) values** are allowed inside this block.
*   Cannot reference **named objects** like resources, data sources, locals, or input variables.
*   Cannot use **Terraform functions** (e.g., `lookup`, `format`, `concat`, etc.) inside this block.
*   Used primarily for settings such as **required\_providers**, **required\_version**, and **backend** configuration.
#### Backend
* The cloud block is used when you're using Terraform Cloud or Terraform Enterprise for state storage and runs.
* The backend block is used for all other state backends, like S3, AzureRM, GCS, local, etc.
* Terraform only allows one mechanism for managing state.
* Using both would create a conflict.

### Providers
- `Providers` = Resource_types + Data Source || Every resource type is implemented by a provider; without providers, Terraform can't manage any kind of infrastructure.
- In provider you cannot reference computed resource attributes, such as `google.web.public_ip.`
>Note: The name = { source, version } syntax for required_providers was added in Terraform v0.13. Previous versions of Terraform used a version constraint string instead of an object (like mycloud = "~> 1.0"),
- `terraform registry`: list of all providers
- each provider has its own release cadence and version numbers.
- Define the provider's source, local name, and version in the required_providers block inside your top-level terraform block.
> In production we recommend constraining the acceptable provider versions in the configuration's provider requirements block, to make sure that terraform init does not install newer versions of the provider that are incompatible with the configuration.
```tf
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}

<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```
- When you define a provider in your root module, Terraform implicitly passes that provider configuration to any child modules to ensure all modules use the same configuration.
```tf
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

module "web-server" {
  source = "./modules/web-server"
  providers = {
    aws.west = aws.west
  }
}
```
## TF State
Terraform uses state to determine which changes to make to your infrastructure. Prior to any operation, Terraform does a refresh to update the state with the real infrastructure.
- [why state is important](https://developer.hashicorp.com/terraform/language/state/purpose)
