param ( 	
    [int]$timeout = 45, # in Seconds
    [int]$iterations = 10,
    [int]$offset = 0, # skip first n iterations
    [string]$projectName = "Mindustry", # "Cake" or "Mindustry"
    [string]$projectPath = "C:\Users\lorin\git\Mindustry\" # "C:\Users\lorin\git\Mindustry" or "C:\Users\lorin\git\cake\" 
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$processName = "notepad++"
$programName = "Notepad"

$test = "Startup"
$csvOutputFileName = "$programName-$($test)Results-$projectName"
$csvOutputFilePath = "../CSV/$csvOutputFileName.csv"
$csvHeader = "Program, Project, $($test)Time(ms)"

# -- Main Block --
Write-Output "Measuring $test time for program: $programName in project: $projectName with iterations: $iterations"

# Prepare file
Write-Output "Saving csv file to $csvoutputFilePath"
$csvHeader | Out-File -FilePath $csvoutputFilePath

for ($i = $offset; $i -lt $iterations; $i++) {
    $process = Start-Process $processName "-openFoldersAsWorkspace", $projectPath, "-loadingTime" -passthru
    Write-Output "Started process $i with name $($process.Name) on $(Get-Date)"
    $startupTime = ([int] (Read-Host "Enter startup time (in sec) from dialog")) * 1000 # Convert to miliseconds

    Stop-Process $process
    $process.WaitForExit()

    # Write to file
    $newLine = "$programName, $projectName, $startupTime"
    $newLine | Add-Content -path $csvoutputFilePath
    Write-Output "Wrote: $newLine"
}

Read-Host "Press Enter to exit"
