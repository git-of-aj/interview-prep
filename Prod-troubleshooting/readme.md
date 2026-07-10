My Knowledge

```sh
# To list All Service Connections using Secrets in App Registration
> o.txt

while IFS= read -r project; do
    echo "===== $project =====" >> o.txt

    az devops service-endpoint list \
        --project "$project" \
        --query "[?type=='azurerm'].{
            serviceprincipalid: authorization.parameters.serviceprincipalid,
            tenantid: authorization.parameters.tenantid,
            DevOps_Sc_Name: name,
            projectName: serviceEndpointProjectReferences[0].projectReference.name
        }" \
        -o table >> o.txt

    echo >> o.txt
done < <(az devops project list --query "value[].name" -o tsv)
```
