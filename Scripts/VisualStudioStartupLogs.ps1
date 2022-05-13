param ( 	
    [int]$timeout = 45, # in Seconds
    [int]$iterations = 1,
    [int]$offset = 0, # skip first n iterations
    [string]$projectName = "Cake", # "Cake" or "Mindustry"
    [string]$projectFilePath = "C:\Users\lorin\git\cake\src\Cake.sln"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$processName = "devenv"
$programName = "VisualStudio"
$logFileName = "ActivityLog"
$logFileExtension = ".xml"
$tempLogPath = "$HOME\Downloads\"

$test = "Startup"
$outputLogPath = "..\Logs\$programName\$projectName\$test\"

# -- Main Block --
Write-Output "Creating $test logs for program: $programName in project: $projectName with iterations: $iterations"

for ($i = $offset; $i -lt $iterations; $i++) {
    $tempLogFilePath = "$tempLogPath$logFileName$logFileExtension"
    $process = Start-Process $processName $projectFilePath, "/log", $tempLogFilePath -passthru
    Write-Output "Started process $i with name: $($process.Name) on $(Get-Date), waiting $timeout s"

    Start-Sleep $timeout

    $process.CloseMainWindow() | Out-Null
    $process.WaitForExit()

    Write-Output "Process $($process.Name) stopped, moving file"
    $outputLogFilePath = "$outputLogPath$logFileName$i$logFileExtension"
    Move-Item $tempLogFilePath $outputLogFilePath -force
}

Read-Host -Prompt "Press Enter to exit"
