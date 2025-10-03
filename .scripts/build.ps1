#Requires -Version 7.0

[CmdletBinding()]
param(
    [string]$Platform = "windows"
)

Import-Module "$PSScriptRoot\_common.psm1" -Force

#region Helper Functions

function Read-IniFile {
    param([string]$Path)

    $ini = @{}
    $section = $null

    foreach ($line in Get-Content $Path) {
        $line = $line.Trim()

        # Skip empty lines and comments
        if ($line -eq '' -or $line -match '^[;#]') {
            continue
        }

        # Section header
        if ($line -match '^\[(.+)\]$') {
            $section = $matches[1]
            $ini[$section] = @{}
            continue
        }

        # Key-value pair
        if ($line -match '^(.+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            if ($section) {
                $ini[$section][$key] = $value
            }
        }
    }

    return $ini
}

function Get-FilesRecursive {
    param(
        [string]$Path,
        [string]$BaseDir
    )

    $files = @()

    Get-ChildItem -Path $Path -Recurse -File | ForEach-Object {
        $shouldSkip = $false

        # Get the relative path from base directory
        $fullPath = $_.FullName
        $relativePath = $fullPath.Substring($BaseDir.Length).TrimStart('\', '/')

        # Split path into parts and check each one
        $pathParts = $relativePath -split '[\\/]'

        foreach ($part in $pathParts) {
            # Check if this part starts with a dot (like .git, .vscode, .conf)
            if ($part.Length -gt 0 -and $part[0] -eq '.') {
                $shouldSkip = $true
                break
            }
        }

        if (-not $shouldSkip) {
            $files += @{
                FullPath = $fullPath
                RelativePath = $relativePath
            }
        }
    }

    return $files
}

function Test-PathInList {
    param(
        [string]$Path,
        [string[]]$List
    )

    foreach ($item in $List) {
        $item = $item.Trim()
        if ($Path -eq $item -or $Path.StartsWith($item)) {
            return $true
        }
        # Handle directory matches
        if ($item.EndsWith('/') -or $item.EndsWith('\')) {
            $normalizedItem = $item.TrimEnd('/', '\')
            if ($Path.StartsWith($normalizedItem + '\') -or $Path.StartsWith($normalizedItem + '/')) {
                return $true
            }
        }
    }
    return $false
}

#endregion


try {
    Write-Banner -Text "Station Builder" -Color Magenta -Width 70
    Write-Host ""

    # Paths
    $scriptDir = $PSScriptRoot
    $configPath = Join-Path $scriptDir "config/build.ini"
    $sourceDir = Join-Path $scriptDir "../" | Resolve-Path
    $buildDir = Join-Path $scriptDir "build"

    Write-Section -Title "Configuration" -Width 70
    Write-KeyValue -Key "Script Directory" -Value $scriptDir
    Write-KeyValue -Key "Source Directory" -Value $sourceDir
    Write-KeyValue -Key "Config File" -Value $configPath
    Write-Host ""

    # Read configuration
    Write-Styled "Reading configuration file..." -Style Info
    if (-not (Test-Path $configPath)) {
        Write-Styled "Configuration file not found: $configPath" -Style Error
        exit 1
    }

    $config = Read-IniFile -Path $configPath
    Write-Styled "Configuration loaded successfully" -Style Success
    Write-Host ""

    # Validate configuration
    if (-not $config.ContainsKey('build') -or -not $config.ContainsKey('windows')) {
        Write-Styled "Invalid configuration: missing required sections" -Style Error
        exit 1
    }

    $platform = $Platform ?? "windows"
    $platform = $platform.ToLower()

    $platformConfig = $config[$platform]
    if (-not $platformConfig) {
        Write-Styled "Invalid platform: $platform" -Style Error
        exit 1
    }

    $loveDir = $platformConfig['LoveDirectory']
    $executableName = $platformConfig['ExecutableName']
    $includeDLLs = $platformConfig['IncludeDLLs'] -eq 'true'

    $extraFiles = if ($config['build']['ExtraFiles']) {
        $config['build']['ExtraFiles'] -split ',' | ForEach-Object { $_.Trim() }
    } else { @() }

    $doNotPack = if ($config['build']['DoNotPack']) {
        $config['build']['DoNotPack'] -split ',' | ForEach-Object { $_.Trim() }
    } else { @() }

    Write-Section -Title "Build Settings" -Width 70
    Write-KeyValue -Key "Platform" -Value $platform
    Write-KeyValue -Key "LÖVE Directory" -Value $loveDir
    Write-KeyValue -Key "Executable Name" -Value $executableName
    Write-KeyValue -Key "Include DLLs" -Value $includeDLLs
    Write-KeyValue -Key "Extra Files" -Value ($extraFiles -join ', ')
    Write-KeyValue -Key "Do Not Pack" -Value ($doNotPack -join ', ')
    Write-Host ""

    # Validate LÖVE directory
    if ($PSVersionTable.Platform -eq 'Win32NT') {
        $loveExePath = Join-Path $loveDir "love.exe"
        if (-not (Test-Path $loveExePath)) {
            Write-Styled "LÖVE executable not found: $loveExePath" -Style Error
            exit 1
        }
    } else {
        $loveExePath = Join-Path $loveDir "love"
        if (-not (Test-Path $loveExePath)) {
            Write-Styled "LÖVE executable not found: $loveExePath" -Style Error
            exit 1
        }
    }

    # Create build directory
    Write-Styled "Creating build directory..." -Style Info
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $buildDir | Out-Null
    Write-Styled "Build directory created" -Style Success
    Write-Host ""

    # Collect files to pack
    Write-Section -Title "Collecting Files" -Width 70
    Write-Styled "Scanning source directory..." -Style Info

    $allFiles = Get-FilesRecursive -Path $sourceDir -BaseDir $sourceDir
    $filesToPack = @()

    foreach ($file in $allFiles) {
        $relativePath = $file.RelativePath.Replace('\', '/')

        # Skip if in DoNotPack list
        if (Test-PathInList -Path $relativePath -List $doNotPack) {
            Write-Styled "  Skipping (DoNotPack): $relativePath" -Style Subtle
            continue
        }

        $filesToPack += $file
    }

    Write-Styled "Found $($filesToPack.Count) files to pack" -Style Success
    Write-Host ""

    # Create .love file
    Write-Section -Title "Creating Game Archive" -Width 70
    $loveFilePath = Join-Path $buildDir "game.love"

    Write-Styled "Creating .love archive..." -Style Info

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::Open($loveFilePath, [System.IO.Compression.ZipArchiveMode]::Create)

    $current = 0
    $total = $filesToPack.Count

    foreach ($file in $filesToPack) {
        $current++
        $relativePath = $file.RelativePath.Replace('\', '/')

        Show-ProgressBar -Current $current -Total $total -Activity "Packing" -ItemName $relativePath

        $entry = $zip.CreateEntry($relativePath)
        $entryStream = $entry.Open()
        $fileStream = [System.IO.File]::OpenRead($file.FullPath)
        $fileStream.CopyTo($entryStream)
        $fileStream.Close()
        $entryStream.Close()
    }

    $zip.Dispose()
    Write-Host ""
    Write-Styled ".love archive created successfully" -Style Success
    Write-Host ""

    # Create executable
    Write-Section -Title "Building Executable" -Width 70
    $outputExePath = Join-Path $buildDir $executableName

    Start-Spinner -Text "Concatenating love.exe + game.love..."
    Stop-Spinner

    $loveExeBytes = [System.IO.File]::ReadAllBytes($loveExePath)
    $loveFileBytes = [System.IO.File]::ReadAllBytes($loveFilePath)
    $combinedBytes = $loveExeBytes + $loveFileBytes

    [System.IO.File]::WriteAllBytes($outputExePath, $combinedBytes)

    Write-Styled "Executable created: $executableName" -Style Success

    # Clean up temporary .love file
    Remove-Item $loveFilePath -Force
    Write-Host ""

    # Copy DLLs
    if ($includeDLLs) {
        Write-Section -Title "Copying DLLs" -Width 70
        Write-Styled "Copying DLL files..." -Style Info

        $dllFiles = Get-ChildItem -Path $loveDir -Filter "*.dll"
        $current = 0
        $total = $dllFiles.Count

        foreach ($dll in $dllFiles) {
            $current++
            Show-ProgressBar -Current $current -Total $total -Activity "Copying DLLs" -ItemName $dll.Name
            Copy-Item $dll.FullName -Destination $buildDir
        }

        Write-Host ""
        Write-Styled "Copied $($dllFiles.Count) DLL files" -Style Success
        Write-Host ""
    }

    # Copy extra files
    if ($extraFiles.Count -gt 0) {
        Write-Section -Title "Copying Extra Files" -Width 70
        Write-Styled "Copying additional files..." -Style Info

        $current = 0
        $total = $extraFiles.Count

        foreach ($extraFile in $extraFiles) {
            $current++
            $sourcePath = Join-Path $sourceDir $extraFile

            if (Test-Path $sourcePath) {
                $item = Get-Item $sourcePath

                if ($item.PSIsContainer) {
                    # Directory
                    $destPath = Join-Path $buildDir $extraFile
                    Show-ProgressBar -Current $current -Total $total -Activity "Copying" -ItemName "$extraFile/"
                    Copy-Item $sourcePath -Destination $destPath -Recurse -Force
                } else {
                    # File
                    Show-ProgressBar -Current $current -Total $total -Activity "Copying" -ItemName $extraFile
                    Copy-Item $sourcePath -Destination $buildDir -Force
                }

                Write-Host ""
                Write-Styled "  Copied: $extraFile" -Style Success
            } else {
                Write-Host ""
                Write-Styled "  Not found: $extraFile" -Style Warning
            }
        }

        Write-Host ""
    }

    # Build summary
    Write-Section -Title "Build Complete" -Width 70
    Write-Styled "Build completed successfully!" -Style Success
    Write-Host ""

    Write-KeyValue -Key "Output Directory" -Value $buildDir
    Write-KeyValue -Key "Executable" -Value $executableName
    Write-KeyValue -Key "Files Packed" -Value $filesToPack.Count

    $buildSize = (Get-Item $outputExePath).Length / 1MB
    Write-KeyValue -Key "Executable Size" -Value ("{0:N2} MB" -f $buildSize)

    Write-Host ""
    Write-Banner -Text "BUILD SUCCESS" -Color Green -Width 70

} catch {
    Write-Host ""
    Write-Styled "Build failed: $($_.Exception.Message)" -Style Error
    Write-Styled $_.ScriptStackTrace -Style Subtle
    exit 1
}
