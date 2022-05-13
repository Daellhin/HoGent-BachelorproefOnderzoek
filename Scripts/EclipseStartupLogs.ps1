param ( 	
    [int]$timeout = 60, # in Seconds
    [int]$iterations = 10,
    [int]$offset = 0, # skip first n iterations
    [string]$projectName = "Cake", # "Cake" or "Mindustry"
    [string]$projectPath = "..\EclipseWorkspaces\$projectName"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$processName = "eclipse"
$programName = "Eclipse"
$logFileName = "consoleLog"
$logFileExtension = ".log"
$tempLogPath = "$HOME\Downloads\"

$test = "Startup"
$outputLogPath = "..\Logs\$programName\$projectName\$test\"

# -- Main Block --
Write-Output "Creating $test logs for program: $programName in project: $projectName with iterations: $iterations"

for ($i = $offset; $i -lt $iterations; $i++) {
    $tempLogFilePath = "$tempLogPath$logFileName$logFileExtension"
    $process = Start-Process $processName "-data", $projectPath, "-debug", "-consoleLog" -passthru -RedirectStandardOutput "$tempLogFilePath"
    Write-Output "Started process $i with name: $($process.Name) on $(Get-Date), waiting $timeout s"

    Start-Sleep $timeout

    $process.CloseMainWindow() | Out-Null
    $process.WaitForExit()

    Write-Output "Process $($process.Name) stopped, moving file"
    $outputLogFilePath = "$outputLogPath$logFileName$i$logFileExtension"
    Move-Item $tempLogFilePath $outputLogFilePath -force
}

Read-Host -Prompt "Press Enter to exit"
