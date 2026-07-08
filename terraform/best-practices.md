
### Terraform Best Practices
- `moved blocks` let you safely `reorganize Terraform code` by telling Terraform where an existing resource moved, preventing unnecessary destroy-and-create operations.
```tf
resource "aws_instance" "server" {}

moved {
  from = aws_instance.web # old resource block
  to   = aws_instance.server #new resource
}
```
- Configuration validation = check if something important is true before using it. If not, show a clear error.
- Instead of one giant module, break everything into building blocks.
```tf
module "network" {
  source = "./modules/network"
}

module "compute" {
  source = "./modules/compute"          

  vpc_id = module.network.vpc_id           # Now Module B cannot work without Network Module They are tightly coupled.
                                         # AKA Dependency Inversion
}

module "database" {
  source = "./modules/database"

  subnet_ids = module.network.private_subnet_ids
}
```
- The root module is responsible for composing those blocks by passing outputs from one module into another, rather than having modules create or discover all of their own dependencies. This approach solves problems of tight coupling, poor reusability, duplicated infrastructure,
```tf
$ tree minimal-module/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
```
- Use the terraform taint command when objects become degraded or damaged. Terraform prompts you to replace the tainted objects in the next plan you create. This command is deprecated
- We recommend the `-replace option` because the change will be reflected in the Terraform plan, letting you understand how it will affect your infrastructure before you take any externally-visible action. When you use terraform taint, other users could create a new plan against your tainted object before you can review the effects.
- The standard pattern is to run `terraform plan on pull requests` so reviewers can inspect the infrastructure diff before anything changes, then `terraform apply on merge to the target branch.`
- . Doing so can corrupt your state file and cause permanent infrastructure damage. Only use this command if a previous process crashed or hung without releasing its lock.
```tf
# Look closely at the error message printed in your terminal.Locate the string labeled ID (e.g., b9b39211-7365-d6aa-a82f-22a4b868673d)
terraform force-unlock <LOCK_ID>

OR
AWS (S3 + DynamoDB): Go to your AWS DynamoDB console. Find your Terraform lock table and manually delete the row matching the Lock ID.

Azure Blob Storage: Open the Azure Portal. Go to your storage account container and look for a file ending in .tflock. Break the blob lease or delete this lock file.
```
- Use the -lock-timeout flag during runs to gracefully wait for existing locks to clear (e.g., `terraform apply -lock-timeout=3m`).
