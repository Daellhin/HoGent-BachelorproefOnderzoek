param ( 	
    [int]$iterations = 1,
    [string]$projectName = "Cake", # Cake or Mindustry
    [string]$projectPath = "..\EclipseWorkspaces\$projectName",
    [switch]$onlyConvert
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$processName = "eclipse"
$programName = "Eclipse"
$logFileName = "consoleLog"
$logFileExtension = ".log"
$optionsFilePath = ".\.options"

$test = "Search"
$tempLogPath = "$HOME\Downloads\"
$outputLogPath = "..\Logs\$programName\$projectName\$test\"
$logPath = $outputLogPath
$csvOutputFileName = "$programName-$($test)Results-$projectName"
$csvOutputFilePath = "../CSV/$csvOutputFileName.csv"
$csvHeader = "Program, Project, $($test)Time(ms)"

# -- Main Block (Starts eclipse > Waits for user to perform searches > converts to csv) --
if (!$onlyConvert) {
    $tempLogFilePath = "$tempLogPath$logFileName$logFileExtension"
    $process = Start-Process $processName "-data", $projectPath, "-debug", $optionsFilePath, "-consoleLog" -PassThru -RedirectStandardOutput "$tempLogFilePath"
    Write-Output "Started process with name: $($process.Name) on $(Get-Date)"

    Read-Host -Prompt "Press Enter after some searches have been made"

    # Close process and move log
    $process.CloseMainWindow() | Out-Null
    $process.WaitForExit()

    Write-Output "Process $($process.Name) stopped, moving file to $outputLogPath"
    $outputLogFilePath = "$outputLogPath$($logFileName)0$logFileExtension"
    Move-Item $tempLogFilePath $outputLogFilePath -Force
}

Write-Output "Converting $test logs for program: $programName in project: $projectName with iterations: $iterations"

# Prepare csv file
Write-Output "Saving csv file to $csvOutputFilePath"
$csvHeader | Out-File -FilePath $csvOutputFilePath

for ($i = 0; $i -lt $iterations; $i++) {
    $currentLogFilePath = "$logPath$logFileName$i$logFileExtension"
    Write-Output "Converting $i $currentLogFilePath"

    # Extract data(IDE specific)
    $fileContents = Get-Content $currentLogFilePath
    $searchTimeLines = $fileContents | Select-String "TextSearch] Search duration for"

    foreach ($searchTimeLine in $searchTimeLines) {
        if (-Not ($searchTimeLine.ToString() -match "(?<=: ).*(?=ms)")) {
            throw "Didnt find '[TextSearch] Search duration for' in $currentLogFilePath"
        }
        $searchTime = $matches[0]

        # Write to file
        $newLine = "$programName, $projectName, $searchTime"
        $newLine | Add-Content $csvOutputFilePath
        Write-Output "Wrote: $newLine"
    }
}

Read-Host -Prompt "Press Enter to exit"
