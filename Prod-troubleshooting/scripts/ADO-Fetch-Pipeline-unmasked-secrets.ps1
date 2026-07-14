# =====================================================
# Azure DevOps Variable Inventory Report
# Authentication via Azure CLI
# =====================================================

# Azure DevOps Organization Name
$orgName = "isdb-devops"

# -----------------------------------------------------
# Get Azure DevOps Access Token
# -----------------------------------------------------
$accessToken = az account get-access-token `
    --resource 499b84ac-1321-427f-aa17-267ca6975798 `
    --query accessToken -o tsv

if (-not $accessToken) {
    Write-Error "Failed to obtain Azure DevOps access token."
    exit
}

$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUri = "https://dev.azure.com/$orgName"

# -----------------------------------------------------
# Main Results Collection
# -----------------------------------------------------
$allVariablesReport = @()

# -----------------------------------------------------
# Get All Projects
# -----------------------------------------------------
try {
    $projectsUrl = "$baseUri/_apis/projects?api-version=7.1-preview.4"
    $projects = (Invoke-RestMethod -Uri $projectsUrl -Method Get -Headers $headers).value
}
catch {
    Write-Error "Unable to retrieve projects."
    Write-Error $_.Exception.Message
    exit
}

foreach ($project in $projects) {

    $projectName = $project.name

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Processing Project: $projectName"
    Write-Host "==================================================" -ForegroundColor Cyan

    # =====================================================
    # BUILD PIPELINES (YAML + CLASSIC)
    # =====================================================

    try {

        $buildsUrl = "$baseUri/$projectName/_apis/build/definitions?api-version=7.1"

        $buildDefs = (Invoke-RestMethod `
                -Uri $buildsUrl `
                -Method Get `
                -Headers $headers).value

        foreach ($bDef in $buildDefs) {

            try {

                $defDetailsUrl = "$baseUri/$projectName/_apis/build/definitions/$($bDef.id)?api-version=7.1"

                $details = Invoke-RestMethod `
                    -Uri $defDetailsUrl `
                    -Method Get `
                    -Headers $headers

                $pipelineType = if ($details.process.type -eq 2) {
                    "YAML"
                }
                else {
                    "Classic Build"
                }

                if ($details.variables) {

                    foreach ($varName in $details.variables.PSObject.Properties.Name) {

                        $varObj = $details.variables.$varName

                        $allVariablesReport += [PSCustomObject]@{
                            Project      = $projectName
                            PipelineName = $details.name
                            PipelineType = $pipelineType
                            Scope        = "Pipeline Root"
                            VariableName = $varName
                            IsSecret     = $varObj.isSecret
                            Value        = if ($varObj.isSecret) {
                                "[SECRET]"
                            }
                            else {
                                $varObj.value
                            }
                        }
                    }
                }

            }
            catch {
                Write-Warning "Failed build definition [$($bDef.name)]"
            }
        }

    }
    catch {
        Write-Warning "Failed to retrieve build pipelines for $projectName"
    }

    # =====================================================
    # RELEASE PIPELINES
    # =====================================================

    try {

        $releasesUrl = "https://vsrm.dev.azure.com/$orgName/$projectName/_apis/release/definitions?api-version=7.1"

        $releaseDefs = (Invoke-RestMethod `
                -Uri $releasesUrl `
                -Method Get `
                -Headers $headers).value

        foreach ($rDef in $releaseDefs) {

            try {

                $rDefDetailsUrl = "https://vsrm.dev.azure.com/$orgName/$projectName/_apis/release/definitions/$($rDef.id)?api-version=7.1"

                $rDetails = Invoke-RestMethod `
                    -Uri $rDefDetailsUrl `
                    -Method Get `
                    -Headers $headers

                # -------------------------
                # Release Root Variables
                # -------------------------

                if ($rDetails.variables) {

                    foreach ($varName in $rDetails.variables.PSObject.Properties.Name) {

                        $varObj = $rDetails.variables.$varName

                        $allVariablesReport += [PSCustomObject]@{
                            Project      = $projectName
                            PipelineName = $rDetails.name
                            PipelineType = "Classic Release"
                            Scope        = "Release Root"
                            VariableName = $varName
                            IsSecret     = $varObj.isSecret
                            Value        = if ($varObj.isSecret) {
                                "[SECRET]"
                            }
                            else {
                                $varObj.value
                            }
                        }
                    }
                }

                # -------------------------
                # Environment Variables
                # -------------------------

                foreach ($env in $rDetails.environments) {

                    if ($env.variables) {

                        foreach ($varName in $env.variables.PSObject.Properties.Name) {

                            $varObj = $env.variables.$varName

                            $allVariablesReport += [PSCustomObject]@{
                                Project      = $projectName
                                PipelineName = $rDetails.name
                                PipelineType = "Classic Release"
                                Scope        = "Stage: $($env.name)"
                                VariableName = $varName
                                IsSecret     = $varObj.isSecret
                                Value        = if ($varObj.isSecret) {
                                    "[SECRET]"
                                }
                                else {
                                    $varObj.value
                                }
                            }
                        }
                    }
                }

            }
            catch {
                Write-Warning "Failed release pipeline [$($rDef.name)]"
            }
        }

    }
    catch {
        Write-Host "No release pipelines found in $projectName" -ForegroundColor Yellow
    }

    # =====================================================
    # VARIABLE GROUPS
    # =====================================================

    try {

        $vgUrl = "$baseUri/$projectName/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"

        $vGroups = (Invoke-RestMethod `
                -Uri $vgUrl `
                -Method Get `
                -Headers $headers).value

        foreach ($vg in $vGroups) {

            foreach ($varName in $vg.variables.PSObject.Properties.Name) {

                $varObj = $vg.variables.$varName

                $allVariablesReport += [PSCustomObject]@{
                    Project      = $projectName
                    PipelineName = $vg.name
                    PipelineType = "Variable Group"
                    Scope        = "Shared Library"
                    VariableName = $varName
                    IsSecret     = $varObj.isSecret
                    Value        = if ($varObj.isSecret) {
                        "[SECRET]"
                    }
                    else {
                        $varObj.value
                    }
                }
            }
        }

    }
    catch {
        Write-Warning "Failed to retrieve Variable Groups for $projectName"
    }
}

# =====================================================
# EXPORT RESULTS
# =====================================================

if ($allVariablesReport.Count -gt 0) {

    $csvFile = ".\ado_variables_inventory.csv"

    $allVariablesReport |
        Sort-Object Project, PipelineType, PipelineName |
        Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "Inventory extraction complete."
    Write-Host "Records : $($allVariablesReport.Count)"
    Write-Host "CSV     : $csvFile"
    Write-Host "==================================================" -ForegroundColor Green
}
else {

    Write-Warning "No variables were found. CSV file not generated."
}
