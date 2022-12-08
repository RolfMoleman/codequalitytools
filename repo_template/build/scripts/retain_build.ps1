# Set variables
$organizationUri = $env:SYSTEM_COLLECTION_URI
$accessToken = $env:SYSTEM_ACCESS_TOKEN
$projectName = $env:SYSTEM_TEAM_PROJECT
$buildId = $env:SYSTEM_BUILD_ID
$definitionId = $env:SYSTEM_DEFINITION_ID
$ownerId = $env:SYSTEM_REQUESTED_FOR
$daysValid = $env:DAYS_VALID
$apiVersion = "6.0"

# Build Request
$requestUrl = "${organizationUri}${projectName}/_apis/build/retention/leases?api-version=${apiVersion}"
$requestHeaders = @{
    "content-type"  = "application/json";
    "Authorization" = "Bearer ${accessToken}";
}
$requestBody =  
@(
    @{
        "daysValid"       = $daysValid;
        "definitionId"    = $definitionId;
        "runId"           = $buildId;
        "ownerId"         = $ownerId;
        "protectPipeline" = $true;
    }
)

$requestBodyAsString = ConvertTo-Json $requestBody

# Retain the build
Invoke-WebRequest -Method "POST" -Body $requestBodyAsString -Uri $requestUrl -Headers $requestHeaders

Write-Output "Pipeline run retained successfully."