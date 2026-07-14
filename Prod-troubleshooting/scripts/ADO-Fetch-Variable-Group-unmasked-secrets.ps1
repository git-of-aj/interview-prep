# Azure DevOps Organization
$org = "isdb-devops"

# Initialize results collection
$results = @()

# Get Azure DevOps access token
$accessToken = az account get-access-token `
    --resource 499b84ac-1321-427f-aa17-267ca6975798 `
    --query accessToken -o tsv

if (-not $accessToken) {
    Write-Error "Failed to obtain Azure DevOps access token."
    exit
}

# Create authentication header
$headers = @{
    Authorization = "Bearer $accessToken"
}

# Get all projects
$projectsUrl = "https://dev.azure.com/$org/_apis/projects?api-version=7.1-preview.4"

try {
    $projectsResponse = Invoke-RestMethod -Uri $projectsUrl -Method Get -Headers $headers
}
catch {
    Write-Error "Failed to retrieve projects. $_"
    exit
}

foreach ($project in $projectsResponse.value) {

    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Yellow
    Write-Host "Project: $($project.name)" -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Yellow

    $vgUrl = "https://dev.azure.com/$org/$($project.name)/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"

    try {

        $vgResponse = Invoke-RestMethod -Uri $vgUrl -Method Get -Headers $headers

        if (-not $vgResponse.value) {
            Write-Host "No Variable Groups found." -ForegroundColor DarkYellow
            continue
        }

        foreach ($group in $vgResponse.value) {

            $vgDetailUrl = "https://dev.azure.com/$org/$($project.name)/_apis/distributedtask/variablegroups/$($group.id)?api-version=7.1-preview.2"

            try {

                $groupDetail = Invoke-RestMethod -Uri $vgDetailUrl -Method Get -Headers $headers

                $creatorName = if ($groupDetail.createdBy.displayName) {
                    $groupDetail.createdBy.displayName
                }
                else {
                    "Unknown"
                }

                Write-Host ""
                Write-Host "Group Name : $($group.name)" -ForegroundColor Cyan
                Write-Host "Group ID   : $($group.id)"
                Write-Host "Created By : $creatorName" -ForegroundColor Magenta
                Write-Host "Created On : $($groupDetail.createdOn)"

                foreach ($varName in $group.variables.PSObject.Properties.Name) {

                    $varObject = $group.variables.$varName

                    $varValue = $varObject.value
                    $isSecret = $varObject.isSecret

                    if ($isSecret) {
                        $displayValue = "[SECRET]"
                        Write-Host "  -> $varName = [SECRET]" -ForegroundColor Red
                    }
                    else {
                        $displayValue = $varValue
                        Write-Host "  -> $varName = $varValue" -ForegroundColor Green
                    }

                    # Add row to results
                    $results += [PSCustomObject]@{
                        ProjectName       = $project.name
                        VariableGroupName = $group.name
                        VariableGroupId   = $group.id
                        VariableName      = $varName
                        VariableValue     = $displayValue
                        IsSecret          = $isSecret
                        CreatedBy         = $creatorName
                        CreatedOn         = $groupDetail.createdOn
                    }
                }

                Write-Host "----------------------------------------------------"
            }
            catch {
                Write-Warning "Failed to retrieve details for Variable Group '$($group.name)'"
                Write-Warning $_.Exception.Message
            }
        }
    }
    catch {
        Write-Warning "Failed to retrieve variable groups for project '$($project.name)'"
        Write-Warning $_.Exception.Message
    }
}

# Export CSV only if data exists
if ($results.Count -gt 0) {

    $csvPath = ".\AzureDevOps_VariableGroups.csv"

    $results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

    Write-Host ""
    Write-Host "CSV exported successfully:" -ForegroundColor Green
    Write-Host $csvPath -ForegroundColor Green
    Write-Host "Records exported: $($results.Count)" -ForegroundColor Green
}
else {

    Write-Warning "No variable groups or variables were found. CSV was not created."
}
