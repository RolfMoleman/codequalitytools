# Set variables
$organizationUri = $env:SYSTEM_COLLECTION_URI
$accessToken = $env:SYSTEM_ACCESS_TOKEN
$pullRequestId = $env:SYSTEM_PULL_REQUEST_ID
$projectName = $env:SYSTEM_TEAM_PROJECT
$repositoryId = $env:SYSTEM_BUILD_REPOSITORY_ID
$buildId = $env:SYSTEM_BUILD_ID
$apiVersion = "6.0"

# Build Request
$requestUrl = "${organizationUri}${projectName}/_apis/git/repositories/${repositoryId}/pullRequests/${pullRequestId}/threads?api-version=${apiVersion}"
$requestHeaders = @{
    "content-type"  = "application/json";
    "Authorization" = "Bearer ${accessToken}";
}

$buildUrl = "${organizationUri}${projectName}/_build/results?buildId=${buildId}" 
$comment = "${env:COMMENT} ${buildUrl}"

$requestBody = @{
    "comments" = @(
        @{
            "parrentCommentId" = 0;
            "content"          = $comment;
            "commentType"      = 1;
        }
    );
    "status"   = 1;
}

$requestBodyAsString = ConvertTo-Json $requestBody

# Create the comment
Invoke-WebRequest -Method "POST" -Body $requestBodyAsString -Uri $requestUrl -Headers $requestHeaders

Write-Output "Comment added successfully."