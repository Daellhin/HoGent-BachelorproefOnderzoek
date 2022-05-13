param ( 	
    [int]$timeout = 60, # in Seconds
    [int]$iterations = 10,
    [int]$offset = 0, # skip first n iterations
    [string]$project = "Mindustry", # "Cake" or "Mindustry"
    [string]$projectFilePath = "C:\Users\lorin\git\Mindustry\build.gradle"  # "C:\Users\lorin\git\cake\src\Cake.sln" or "C:\Users\lorin\git\Mindustry\build.gradle"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

# Constants
$processName = "idea64"
$programName = "IntelliJ"
$intelliJVersion = "IntelliJIdea2022.1"
$logFileName = "idea"
$logFileExtension = ".log"
$tempLogPath = "C:\Users\lorin\AppData\Local\JetBrains\$intelliJVersion\log\"

$test = "Startup"
$outputLogPath = "..\Logs\$programName\$project\$test\"

# -- Main Block --
Write-Output "Creating $test logs for program: $programName in project: $project with iterations: $iterations"

for ($i = $offset; $i -lt $iterations; $i++) {
    $tempLogFilePath = "$tempLogPath$logFileName$logFileExtension" # log file is created automaticaly
    $process = Start-Process $processName $projectFilePath -passthru
    Write-Output "Started process $i with name $($process.Name) on $(Get-Date), waiting $timeout s"

    Start-Sleep $timeout

    $process.CloseMainWindow() | Out-Null
    $process.WaitForExit()

    Write-Output "Process $($process.Name) stopped, moving file"
    $outputLogFilePath = "$outputLogPath$logFileName$i$logFileExtension"

    Move-Item $tempLogFilePath $outputLogFilePath -force
}

Read-Host -Prompt "Press Enter to exit"
