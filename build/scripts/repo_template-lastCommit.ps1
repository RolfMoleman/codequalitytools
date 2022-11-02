$webClient = New-Object Net.WebClient
$token = "Bearer $env:SYSTEM_ACCESSTOKEN"
$headers = @{ Authorization = $token }

$baseUrl = 'https://dev.azure.com/bcagroup>/BCA.Operations.Utilities/_apis/git/repositories/3f795ff4-4328-4347-80b1-3348dd374401/commits'
$request = "$baseUrl/$env:RELEASE_ARTIFACTS_repo_template_SOURCEVERSION"
Write-Output "Request: $request"

$response = Invoke-WebRequest -Uri $request -Headers $headers
$json = ($response | ConvertFrom-Json)
$comment = $json.comment
Write-Output "Response: $comment"

Write-Output "##vso[task.setvariable variable=commitComment;]$comment"