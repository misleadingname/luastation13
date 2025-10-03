function Write-Styled {
    <#
    .SYNOPSIS
        Writes styled text with color gradients and formatting
    .PARAMETER Text
        The text to display
    .PARAMETER Style
        The style preset (Success, Error, Warning, Info, Highlight, Subtle)
    .PARAMETER Prefix
        Optional prefix symbol
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,

        [Parameter(Position = 1)]
        [ValidateSet('Success', 'Error', 'Warning', 'Info', 'Highlight', 'Subtle', 'Header', 'Subheader')]
        [string]$Style = 'Info',

        [Parameter()]
        [string]$Prefix = ''
    )

    $styles = @{
        Success = @{
            ForegroundColor = 'Green'
            Prefix = '✓'
            Bright = $true
        }
        Error = @{
            ForegroundColor = 'Red'
            Prefix = '✗'
            Bright = $true
        }
        Warning = @{
            ForegroundColor = 'Yellow'
            Prefix = '▲'
            Bright = $true
        }
        Info = @{
            ForegroundColor = 'Cyan'
            Prefix = '●'
            Bright = $false
        }
        Highlight = @{
            ForegroundColor = 'Magenta'
            Prefix = '◆'
            Bright = $true
        }
        Subtle = @{
            ForegroundColor = 'DarkGray'
            Prefix = '·'
            Bright = $false
        }
        Header = @{
            ForegroundColor = 'White'
            Prefix = '═'
            Bright = $true
        }
        Subheader = @{
            ForegroundColor = 'White'
            Prefix = '─'
            Bright = $false
        }
    }

    $styleConfig = $styles[$Style]
    $displayPrefix = if ($Prefix) { $Prefix } else { $styleConfig.Prefix }

    if ($styleConfig.Bright) {
        Write-Host "$displayPrefix " -ForegroundColor $styleConfig.ForegroundColor -NoNewline
        Write-Host $Text -ForegroundColor $styleConfig.ForegroundColor
    } else {
        Write-Host "$displayPrefix " -ForegroundColor $styleConfig.ForegroundColor -NoNewline
        Write-Host $Text -ForegroundColor $styleConfig.ForegroundColor
    }
}

function Write-Banner {
    <#
    .SYNOPSIS
        Creates a styled banner with borders
    .PARAMETER Text
        The text to display in the banner
    .PARAMETER Width
        The width of the banner (default: 80)
    .PARAMETER Color
        The color of the banner
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [Parameter()]
        [int]$Width = 80,

        [Parameter()]
        [ConsoleColor]$Color = 'Cyan'
    )

    $topBorder = "╔" + ("═" * ($Width - 2)) + "╗"
    $bottomBorder = "╚" + ("═" * ($Width - 2)) + "╝"

    $paddingLength = $Width - $Text.Length - 4
    $leftPadding = [Math]::Floor($paddingLength / 2)
    $rightPadding = [Math]::Ceiling($paddingLength / 2)

    $contentLine = "║ " + (" " * $leftPadding) + $Text + (" " * $rightPadding) + " ║"

    Write-Host $topBorder -ForegroundColor $Color
    Write-Host $contentLine -ForegroundColor $Color
    Write-Host $bottomBorder -ForegroundColor $Color
}

function Write-Section {
    <#
    .SYNOPSIS
        Writes a section header with a decorative line
    .PARAMETER Title
        The section title
    .PARAMETER Width
        The width of the section line
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter()]
        [int]$Width = 80
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor White
    Write-Host ("─" * $Width) -ForegroundColor DarkGray
}

function Write-KeyValue {
    <#
    .SYNOPSIS
        Writes key-value pairs in a styled format
    .PARAMETER Key
        The key name
    .PARAMETER Value
        The value
    .PARAMETER KeyColor
        Color for the key
    .PARAMETER ValueColor
        Color for the value
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Value,

        [Parameter()]
        [ConsoleColor]$KeyColor = 'Gray',

        [Parameter()]
        [ConsoleColor]$ValueColor = 'White'
    )

    Write-Host "  $Key" -ForegroundColor $KeyColor -NoNewline
    Write-Host ": " -ForegroundColor DarkGray -NoNewline
    Write-Host $Value -ForegroundColor $ValueColor
}

function Write-Table {
    <#
    .SYNOPSIS
        Writes a simple styled table
    .PARAMETER Headers
        Array of header names
    .PARAMETER Rows
        Array of row data
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Headers,

        [Parameter(Mandatory)]
        [object[][]]$Rows
    )

    $colWidths = @()
    foreach ($i in 0..($Headers.Count - 1)) {
        $maxWidth = $Headers[$i].Length
        foreach ($row in $Rows) {
            if ($row[$i].ToString().Length -gt $maxWidth) {
                $maxWidth = $row[$i].ToString().Length
            }
        }
        $colWidths += $maxWidth + 2
    }

    # Header
    Write-Host "┌" -ForegroundColor Cyan -NoNewline
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        Write-Host ("─" * $colWidths[$i]) -ForegroundColor Cyan -NoNewline
        if ($i -lt $Headers.Count - 1) {
            Write-Host "┬" -ForegroundColor Cyan -NoNewline
        }
    }
    Write-Host "┐" -ForegroundColor Cyan

    # Header content
    Write-Host "│" -ForegroundColor Cyan -NoNewline
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        Write-Host (" " + $Headers[$i].PadRight($colWidths[$i] - 1)) -ForegroundColor White -NoNewline
        Write-Host "│" -ForegroundColor Cyan -NoNewline
    }
    Write-Host ""

    # Separator
    Write-Host "├" -ForegroundColor Cyan -NoNewline
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        Write-Host ("─" * $colWidths[$i]) -ForegroundColor Cyan -NoNewline
        if ($i -lt $Headers.Count - 1) {
            Write-Host "┼" -ForegroundColor Cyan -NoNewline
        }
    }
    Write-Host "┤" -ForegroundColor Cyan

    # Rows
    foreach ($row in $Rows) {
        Write-Host "│" -ForegroundColor Cyan -NoNewline
        for ($i = 0; $i -lt $row.Count; $i++) {
            Write-Host (" " + $row[$i].ToString().PadRight($colWidths[$i] - 1)) -ForegroundColor Gray -NoNewline
            Write-Host "│" -ForegroundColor Cyan -NoNewline
        }
        Write-Host ""
    }

    # Bottom
    Write-Host "└" -ForegroundColor Cyan -NoNewline
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        Write-Host ("─" * $colWidths[$i]) -ForegroundColor Cyan -NoNewline
        if ($i -lt $Headers.Count - 1) {
            Write-Host "┴" -ForegroundColor Cyan -NoNewline
        }
    }
    Write-Host "┘" -ForegroundColor Cyan
}

function Show-Progress {
    <#
    .SYNOPSIS
        Displays a stylish progress bar
    .PARAMETER Activity
        The activity being performed
    .PARAMETER PercentComplete
        Percentage complete (0-100)
    .PARAMETER Status
        Current status text
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Activity,

        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,

        [Parameter()]
        [string]$Status = ''
    )

    $barWidth = 50
    $completed = [Math]::Floor($barWidth * $PercentComplete / 100)
    $remaining = $barWidth - $completed

    $bar = "█" * $completed + "░" * $remaining

    $color = switch ($PercentComplete) {
        { $_ -lt 33 } { 'Red' }
        { $_ -lt 66 } { 'Yellow' }
        default { 'Green' }
    }

    Write-Host "`r" -NoNewline
    Write-Host "$Activity " -ForegroundColor White -NoNewline
    Write-Host "[" -ForegroundColor DarkGray -NoNewline
    Write-Host $bar -ForegroundColor $color -NoNewline
    Write-Host "]" -ForegroundColor DarkGray -NoNewline
    Write-Host " $PercentComplete%" -ForegroundColor White -NoNewline

    if ($Status) {
        Write-Host " - $Status" -ForegroundColor Gray -NoNewline
    }

    if ($PercentComplete -eq 100) {
        Write-Host ""
    }
}

function Start-Spinner {
    <#
    .SYNOPSIS
        Starts an animated spinner
    .PARAMETER Text
        Text to display next to the spinner
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Text = 'Processing'
    )

    $script:SpinnerRunning = $true
    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')

    $script:SpinnerJob = Start-Job -ScriptBlock {
        param($frames, $text)
        $i = 0
        while ($true) {
            $frame = $frames[$i % $frames.Count]
            Write-Host "`r$frame $text" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 80
            $i++
        }
    } -ArgumentList $frames, $Text
}

function Stop-Spinner {
    <#
    .SYNOPSIS
        Stops the running spinner
    .PARAMETER FinalText
        Optional final text to display
    .PARAMETER Success
        Whether the operation was successful
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$FinalText = '',

        [Parameter()]
        [bool]$Success = $true
    )

    if ($script:SpinnerJob) {
        Stop-Job -Job $script:SpinnerJob
        Remove-Job -Job $script:SpinnerJob
        Write-Host "`r" -NoNewline

        if ($FinalText) {
            if ($Success) {
                Write-Styled -Text $FinalText -Style Success
            } else {
                Write-Styled -Text $FinalText -Style Error
            }
        }
    }
}

function Show-ProgressBar {
    <#
    .SYNOPSIS
        Displays a more detailed progress bar with statistics
    .PARAMETER Current
        Current item number
    .PARAMETER Total
        Total number of items
    .PARAMETER Activity
        Activity description
    .PARAMETER ItemName
        Current item being processed
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Current,

        [Parameter(Mandatory)]
        [int]$Total,

        [Parameter()]
        [string]$Activity = 'Processing',

        [Parameter()]
        [string]$ItemName = ''
    )

    $percent = [Math]::Round(($Current / $Total) * 100, 1)
    $barWidth = 40
    $completed = [Math]::Floor($barWidth * $percent / 100)
    $remaining = $barWidth - $completed

    $bar = "▓" * $completed + "░" * $remaining

    $color = switch ($percent) {
        { $_ -lt 33 } { 'Red' }
        { $_ -lt 66 } { 'Yellow' }
        default { 'Green' }
    }

    Write-Host "`r" -NoNewline
    Write-Host "$Activity " -ForegroundColor White -NoNewline
    Write-Host "[" -ForegroundColor DarkGray -NoNewline
    Write-Host $bar -ForegroundColor $color -NoNewline
    Write-Host "]" -ForegroundColor DarkGray -NoNewline
    Write-Host " $percent% " -ForegroundColor White -NoNewline
    Write-Host "($Current/$Total)" -ForegroundColor Gray -NoNewline

    if ($ItemName) {
        Write-Host " - $ItemName" -ForegroundColor DarkGray -NoNewline
    }

    if ($Current -eq $Total) {
        Write-Host ""
    }
}

Export-ModuleMember -Function @(
    'Write-Styled',
    'Write-Banner',
    'Write-Section',
    'Write-KeyValue',
    'Write-Table',
    'Show-Progress',
    'Start-Spinner',
    'Stop-Spinner',
    'Show-ProgressBar'
)
