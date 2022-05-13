param ( 	
    [int]$iterations = 10,
    [int]$offset = 0, # skip first n iterations
    [string]$projectName = "Cake", # "Cake" or "Mindustry",
    [string]$projectPath = "C:\Users\lorin\git\cake\",
    [int]$maxBuildTime = 30, # in seconds
    [int]$maxCleanTime = 8
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

Add-Type -AssemblyName System.Windows.Forms

$programName = "VisualStudio"
$logFileName = "Output-Build"
$logFileExtension = ".txt"
$tempLogPath = "$HOME\Downloads\"
$tempLogFilePath = "$tempLogPath$logFileName$logFileExtension"

$test = "Build"
$outputLogPath = "..\Logs\$programName\$projectName\$test\"

# Available Keys : https://docs.microsoft.com/en-us/previous-versions/office/developer/office-xp/aa202943(v=office.10)
function Use-Key([string]$key) {
    [System.Windows.Forms.SendKeys]::SendWait($key)
}

# Only accepts scaled cursorposition
function Set-CursorPosition([int]$x, [int]$y) {
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
}

# https://stackoverflow.com/a/14096416/8807613
function Use-MouseButton([string]$Button) {
    $signature = @' 
      [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
      public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

    $SendMouseClick = Add-Type -MemberDefinition $signature -Name "Win32MouseEventNew" -Namespace Win32Functions -PassThru 
    if ($Button -eq "left") {
        $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0)
        $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0)
    }
    if ($Button -eq "right") {
        $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0)
        $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0)
    }
    if ($Button -eq "middle") {
        $SendMouseClick::mouse_event(0x00000020, 0, 0, 0, 0)
        $SendMouseClick::mouse_event(0x00000040, 0, 0, 0, 0)
    }
}

# -- Main Block --
Write-Output "Moving $test logs for program: $programName in project: $projectName with iterations: $iterations"

Read-Host -Prompt "Press Enter to start($programName must be opened)"

for ($i = $offset; $i -lt $iterations; $i++) {
    # Get focus
    Set-CursorPosition 460 560
    Use-MouseButton "left"

    Write-Output "Starting clean $i on $(Get-Date), waiting $maxCleanTime"
    Use-Key "^h"
    Start-Sleep $maxCleanTime

    Write-Output "Starting build $i on $(Get-Date), waiting $maxBuildTime"
    Use-Key "^+b"
    Start-Sleep $maxBuildTime

    Write-Output "Saving file $i to downloads"
    Set-CursorPosition 460 560
    Use-Key "^s"
    Use-Key "{ENTER}"
    Start-Sleep 2
    
    $outputLogFilePath = "$outputLogPath$logFileName$i$logFileExtension"
    Write-Output "Moving file $outputLogFilePath"
    Move-Item $tempLogFilePath $outputLogFilePath -Force
}

Read-Host -Prompt "Press Enter to exit"
