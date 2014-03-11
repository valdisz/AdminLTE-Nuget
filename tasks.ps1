properties {
    $sources = 'src'
    $adminLte = 'lib/AdminLTE'
	$output = 'results'
	$nugetFeed = 'https://www.nuget.org/api/v2/'
	$nugetApiKey = $null
}

task default -depends Clean, Pack

task Clean -requiredVariables output {
	if (-not (Test-Path $output)) {
		return
	}
	
	rm (Join-Path $output \) -Recurse -Force
}

task Pack `
    -requiredVariables sources, output, adminLte {

    $nuspecFiles = @(ls (Join-Path $sources *.nuspec))
    
    assert ($nuspecFiles.Count -gt 0) "There are no nuspec files to pack"

    if (-not (Test-Path $output)) {
        mkdir $output
    }
    
    $nuspecFiles | %{ exec { .\NuGet pack $_ -BasePath $adminLte -OutputDirectory $output } }
}

task Push `
    -depends Pack `
    -requiredVariables nugetFeed, nugetApiKey, output {

    assert (Test-Path $output) "Output path should exists"

    $packages = @(ls (Join-Path $output *.nupkg))

    assert ($packages.Count -gt 0) "There are no packages to push to NuGet feed"

    $packages | %{ exec { .\NuGet push $_ -Source $nugetFeed -ApiKey $nugetApiKey } }
}

task Update {
    git submodule foreach git pull
}
