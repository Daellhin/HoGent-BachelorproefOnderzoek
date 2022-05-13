param ( 	
    [int]$iterations = 1,
    [string]$projectName = "Cake" # "Cake" or "Mindustry"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$programName = "VSCode"
$logFileName = "rendererLog"
$logFileExtension = ".txt"

$test = "Search"
$logPath = "..\Logs\$programName\$projectName\$test\"
$csvOutputFileName = "$programName-$($test)Results-$projectName"
$csvOutputFilePath = "../CSV/$csvOutputFileName.csv"
$csvHeader = "Program, Project, $($test)Time(ms)"

# -- Main Block --
Write-Output "Converting $test logs for program: $programName in project: $projectName with iterations: $iterations"

# Prepare file
Write-Output "Saving csv to $csvOutputFilePath"
$csvHeader | Out-File -FilePath $csvOutputFilePath

for ($i = 0; $i -lt $iterations; $i++) {
    $currentFilePath = "$logPath$logFileName$i$logFileExtension"
    Write-Output "Converting $i $currentFilePath"

    # Extract data
    $fileContents = Get-Content  $currentFilePath
    $searchTimes = $fileContents | Select-String "SearchService#search:" -List;

    foreach ($searchTime in $searchTimes) {
        $time = (($searchTime.ToString() -split ': ')[1] -split 'ms')[0];
        # Write to file
        $newLine = "$programName, $projectName, $time"
        $newLine | Add-Content -path $csvOutputFilePath
        Write-Output "Wrote: $newLine"
    }
}

Read-Host -Prompt "Press Enter to exit"
