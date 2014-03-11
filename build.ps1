param (
    [string]$target,
    [string]$apiKey,
    [string]$nuget
)

Import-Module ./tools/psake/psake.psm1


if ($target -eq $null ) {
    invoke-psake tasks.ps1
}
else {
    invoke-psake tasks.ps1 $target -properties @{ nugetFeed = $nuget; nugetApiKey = $apiKey }
}

