properties {
    $nuget = '../tools/nuget/nuget.exe'
    $git = 'git.exe'
    $srcDir = '..'
	$outDir = '../results'
	$nugetFeed = $null
	$nugetApiKey = $null
}

task default -depends Pack
task Rebuild -depends Clean, Update, Pack

task Clean -requiredVariables outDir {
	if (-not (Test-Path $outDir)) {
		return
	}
	
	rm (Join-Path $outDir \) -Recurse -Force
}

task Pack `
    -requiredVariables srcDir, outDir {

    $nuspecFiles = @(ls (Join-Path $srcDir *.nuspec))
    
    assert ($nuspecFiles.Count -gt 0) "There are no nuspec files to pack"

    if (-not (Test-Path $outDir)) {
        mkdir $outDir
    }
    
    $nuspecFiles | %{ &$nuget pack $_ -BasePath $srcDir -OutputDirectory $outDir }
}

task Push `
    -depends Pack `
    -requiredVariables nugetFeed, nugetApiKey, outDir {

    assert (Test-Path outDir) "Output path should exists"

    $packages = @(ls (Join-Path $out *.nupkg))

    assert ($packages.Count -gt 0) "There are no packages to push to NuGet feed"

    $packages | %{ &$nuget push $_ -Source $nugetFeed -ApiKey $nugetApiKey }
}

task Update {
    &$git submodule foreach git pull
}
