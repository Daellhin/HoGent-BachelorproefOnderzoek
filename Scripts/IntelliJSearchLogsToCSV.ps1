param ( 	
    [int]$iterations = 2,
    [string]$projectName = "Mindustry" # Cake or Mindustry
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$programName = "IntelliJ"
$logFileName = "idea"
$logFileExtension = ".log"

$test = "Search"
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
    $searchTimeLines = $fileContents | Select-String "Find Usages in"

    foreach ($searchTimeLine in $searchTimeLines) {
        if(-Not ($searchTimeLine.ToString() -match "(?<=took ).*(?=ms)")) {
            throw "Didnt find 'Find Usages in projectName took 0ms' in $currentLogFilePath"
        }
        $searchTime = $matches[0]

        # Write to file
        $newLine = "$programName, $projectName, $searchTime"
        $newLine | Add-Content $csvOutputFilePath
        Write-Output "Wrote: $newLine"
    }
}

Read-Host -Prompt "Press Enter to exit"
