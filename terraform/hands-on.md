- Q: when creating module where to keep `provider {}` block ?
- Put the actual provider configuration block in the root module — i.e. the folder where you run terraform plan/apply and where you call your child modules. Do not put provider blocks inside reusable child module.
- Say child use terraform version 1.4 in your code you specificed 1.15 tf init me error
- Ideal structure:
```
terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
└── modules/
    └── storage/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

- Terraform modules are intentionally isolated. A variable defined in environments/dev/variables.tf is not automatically visible inside modules/app-service.
- Put validation in the variable block that defines the variable — normally the module's own variables.tf — rather than duplicating or moving that validation into the root module's variables.tf
- The validation block describes a requirement of the module. Just like API
- HashiCorp specifically says variable validation can enforce a module's standards and requirements and help module consumers understand how to use it. 
> For production environments, I'd generally prefer Terraform to provision the App Service and your CI/CD system to deploy the application. so code is build, test and deployed.
Microsoft's Functions documentation similarly describes external pipelines such as Azure Pipelines/GitHub Actions as appropriate for production deployments where validation and testing are part of the process
