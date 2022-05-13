param ( 	
    [int]$iterations = 10,
    [string]$projectName = "Mindustry" # "Cake" or "Mindustry"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 1.0 

# Constants
$programName = "IntelliJ"
$logFileName = "idea"
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
    $fileName = "$logPath$logFileName$i$logFileExtension"
    Write-Output "Converting $i $fileName"
    
    # Extract data(IDE specific)
    $fileContents = Get-Content $fileName
    $timeOriginLines = $fileContents | Select-String "IDE STARTED"
    # IntelliJ logs can contain information about more than 1 startup, so check if it is an array and take last startup
    $timeOriginLastLine = $timeOriginLines[$timeOriginLines.Length - 1]
    $timeOrigin = $timeOriginLastLine.ToString().Substring(0, 23)
    # Format: 2022-05-07 10:49:24,032
    $dateTimeStart = ([datetime]$timeOrigin.Replace(",", "."))

    $didLoadLines = $fileContents | Select-String "notify that start-up thread is free"
    $didLoadLinesLastLine = $didLoadLines[$didLoadLines.Length - 1]
    $timeOrigin = $didLoadLinesLastLine.ToString().Substring(0, 23)
    $dateTimeEnd = ([datetime]$timeOrigin.Replace(",", "."))

    $startupTime = ($dateTimeEnd - $dateTimeStart).TotalMilliseconds

    # Write to file
    $newLine = "$programName, $projectName, $startupTime"
    $newLine | Add-Content $csvOutputFilePath
    Write-Output "Wrote: $newLine"
}

Read-Host -Prompt "Press Enter to exit"
