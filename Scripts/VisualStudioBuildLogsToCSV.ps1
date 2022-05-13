param ( 	
    [int]$iterations = 10,
    [string]$projectName = "Cake" # "Cake" or "Mindustry"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$programName = "VisualStudio"
$logFileName = "Output-Build"
$logFileExtension = ".txt"

$test = "Build"
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
    $buildTimeLines = ($fileContents | Select-String "Time Elapsed" -List)
    $buildTimeLines = $buildTimeLines[0..($buildTimeLines.Length - 9)]

    $cumulativeBuildTime = 0
    foreach ($buildTimeLine in $buildTimeLines) {
        $buildTime = ($buildTimeLine.ToString() -split 'Time Elapsed ')[1];
        $buildTimeMiliseconds = [TimeSpan]::Parse($buildTime).TotalMilliseconds
        $cumulativeBuildTime += $buildTimeMiliseconds
    }

    # Write to file
    $newLine = "$programName, $projectName, $cumulativeBuildTime"
    $newLine | Add-Content -Path $csvOutputFilePath
    Write-Output "Wrote: $newLine"
}

Read-Host -Prompt "Press Enter to exit"
