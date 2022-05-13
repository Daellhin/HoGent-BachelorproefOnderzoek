param ( 	
    [int]$iterations = 10,
    [string]$projectName = "Cake" # "Cake" or "Mindustry"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$programName = "VisualStudio"
$logFileName = "ActivityLog"
$logFileExtension = ".xml"

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
    $timeOrigin = $fileContents | Select-String "<record>1</record>" -Context 0, 1
    if(-Not ($timeOrigin -match "(?<=<time>).*(?=<\/time>)")) {
        throw "Didnt find <record>1</record> in $fileName"
    }
    $dateTimeStart = ([datetime]$matches[0])

    $didLoad = $fileContents | Select-String "<description>.NET Framework Version:" -Context 3, 0
    if(-Not ($didLoad -match "(?<=<time>).*(?=<\/time>)")) {
       throw "Didnt find .NET Framework Version in $fileName"
    }
    $dateTimeEnd = ([datetime]$matches[0])
    
    $startupTime = ($dateTimeEnd - $dateTimeStart).TotalMilliseconds

    # Write to file
    $newLine = "$programName, $projectName, $startupTime"
    $newLine | Add-Content -path $csvOutputFilePath
    Write-Output "Wrote: $newLine"
}

Read-Host -Prompt "Press Enter to exit"
