# Convert uppercased Terraform environment variables to their original casing expected by Terraform
foreach ($tfvar in $(Get-ChildItem -Path Env: -Recurse -Include TF_VAR_*))
{
    $upperCaseName = $tfvar.Name + "_UC"
    $properCaseName = $tfvar.Name.Substring(0, 7) + $tfvar.Name.Substring(7).ToLowerInvariant()
    $null = New-Item -Path env:$upperCaseName -Value $tfVar.Value
    Remove-Item -Path env:$($tfvar.Name)
    $null = New-Item -Path env:$properCaseName -Value $tfVar.Value
    Set-Item -Path env:$upperCaseName -Value $null
} 
# List environment variables
Get-ChildItem -Path Env: -Recurse -Include ARM_*, AZURE_*, TF_* | Sort-Object -Property Name