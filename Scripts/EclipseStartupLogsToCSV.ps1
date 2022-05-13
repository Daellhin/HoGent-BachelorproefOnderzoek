param ( 	
    [int]$iterations = 10,
    [string]$projectName = "Cake" # "Cake" or "Mindustry"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 1.0 

# Constants
$programName = "Eclipse"
$logFileName = "consoleLog"
$logFileExtension = ".log"

$test = "Startup"
$logPath = "..\Logs\$programName\$projectName\$test\"
$csvOutputFileName = "$programName-$($test)Results-$projectName"
$csvOutputFilePath = "../CSV/$csvOutputFileName.csv"
$csvHeader = "Program, Project, $($test)Time(ms)"

# -- Main Block --
Write-Output "Converting $test logs for program: $programName in project: $projectName with iterations: $iterations"

# Prepare file
Write-Output "Saving csv file to $csvOutputFilePath"
$csvHeader | Out-File -FilePath $csvOutputFilePath

for ($i = 0; $i -lt $iterations; $i++) {
    $currentLogFilePath = "$logPath$logFileName$i$logFileExtension"
    Write-Output "Converting $i $currentLogFilePath"
    
    # Extract data(IDE specific)
    $fileContents = Get-Content $currentLogFilePath
    $startupTimeLine = $fileContents | Select-String "Application started in"
    if(-Not ($startupTimeLine -match "(?<=: ).*(?=ms)")) {
        throw "Didnt find: Application started in :  0ms in $currentLogFilePath"
    }
    $startupTime = $matches[0]

    # Write to file
    $newLine = "$programName, $projectName, $startupTime"
    $newLine | Add-Content $csvOutputFilePath
    Write-Output "Wrote: $newLine"
}

Read-Host -Prompt "Press Enter to exit"
