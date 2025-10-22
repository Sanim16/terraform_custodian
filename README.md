
# Terraform Cloud Custodian deployment

[![Github Actions](https://github.com/Sanim16/terraform_custodian/actions/workflows/deploy.yml/badge.svg)](https://github.com/Sanim16/terraform_custodian/actions/workflows/deploy.yml)

>This is a Terraform project that deploys a `cloudcustodian` using lambda.

## Resources:
- Terraform


## Cleanup
Remember to delete all AWS components afterwards to avoid unforseen bills.
```terraform
terraform destroy -auto-approve
```
