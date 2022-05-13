param ( 	
    [int]$iterations = 10,
    [string]$projectName = "Mindustry" # "Cake" or "Mindustry"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$programName = "VSCode"
$logFileName = "Startup Performance"
$logFileExtension = ".txt"

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
    $currentFilePath = "$logPath$logFileName$i$logFileExtension"
    Write-Output "Converting $i $currentFilePath"
    
    # Extract data(IDE specific)
    $fileContents = Get-Content $currentFilePath
    $timeOrigin = $fileContents | Select-String "code/timeOrigin" -List
    $timestampStart = $timeOrigin[0].ToString().Split("	")[1]

    $didLoadExtensions = $fileContents | Select-String "code/didLoadExtensions" -List
    $timestampEnd = $didLoadExtensions[0].ToString().Split("	")[1]
    
    $startupTime = $timestampEnd - $timestampStart

    # Write to file
    $newLine = "$programName, $projectName, $startupTime"
    $newLine | Add-Content -path $csvOutputFilePath
    Write-Output "Wrote: $newLine"
}

Read-Host -Prompt "Press Enter to exit"
