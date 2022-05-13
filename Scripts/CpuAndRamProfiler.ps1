param ( 	
    [string]$processName = "idea64", # "devenv", "code", "eclipse", "notepad++", "idea64"
    [string]$programName = "IntelliJ",
    [string]$projectName = "Mindustry", # Cake or Mindustry
    [int] $iterations = 30,
    [int]$pollRate = 1, # in Seconds
    [switch]$monitorOnly
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 1.0 

# Constants
$csvOutputFileName = "$programName-Profile-$(Get-Date -Format "HH+mm+ss")-$projectName"
$csvOutputFileName
$csvOutputFilePath = "../CSV/$csvOutputFileName.csv"
$csvHeader = "Program, Project, Processes, TimeStamp(HH:mm:ss), CPU(%), RAM(MB)"

function Get-CorrectCPUData($oldProcessingData, $newProcessingData, $oldProcessingTime, $newProcessingTime ) {
    $diffProcessingData = $newProcessingData - $oldProcessingData
    $diffProcessingTime = $newProcessingTime - $oldProcessingTime
    $utilization = (($diffProcessingData / $diffProcessingTime) * 100) / $env:NUMBER_OF_PROCESSORS
 
    return $utilization
}

function Get-ChildProcesses ($ParentProcessId) {
    $filter = "parentprocessid = '$($ParentProcessId)'"
    Get-CimInstance -ClassName win32_process -Filter $filter | ForEach-Object {
        $_
        if ($_.ParentProcessId -ne $_.ProcessId) {
            Get-ChildProcesses $_.ProcessId
        }
    }
}

function Get-UtilizationStats() {
    $processTable = @{}
    
    for ($i = -1; $i -lt $iterations; $i++) {
        $childProcesses = Get-ChildProcesses $parentProcess.ProcessId

        $whereClause = "IDProcess='$($parentProcess.ProcessId)'"
        foreach ($childProcess in $childProcesses) {
            $whereClause += " or IDProcess='$($childProcess.ProcessId)'"
        }

        $statsQuery = "select * from Win32_PerfRawData_PerfProc_Process where $whereClause"
        $processData = Get-WmiObject -Query $statsQuery

        $ram = 0
        $cpu = 0
        foreach ($colData in $processData) {
            $previousData = $processTable[$colData.IDProcess]
            if ($previousData) {
                $ram += $colData.WorkingSetPrivate
                $cpu += Get-CorrectCPUData $previousData.ProcessingTime $colData.PercentProcessorTime $previousData.TimeStamp $colData.TimeStamp_Sys100NS
            }
            
            $processTable[$colData.IDProcess] = @{
                ProcessingTime = $colData.PercentProcessorTime
                TimeStamp      = $colData.TimeStamp_Sys100NS
            }

        }

        if ((!$monitorOnly) -and ($i -ne -1)) {
            $amountOfProcesses = 1 + $childProcesses.length
            $formatedTimestamp = Get-Date -Format "HH:mm:ss"
            $formatedCPU = [math]::Round($cpu, 2)
            $formatedRAM = [math]::Round(($ram / 1mb), 2)
            $newLine = "$programName, $projectName, $amountOfProcesses, $formatedTimestamp, $formatedCPU, $formatedRAM"
            $newLine | Add-Content $csvOutputFilePath
            Write-Output "Wrote: $newLine"
        }
        Start-Sleep $pollRate
    }
}

# -- Main block --
Write-Output "Collecting CPU/RAM data for program: $programName in project: $projectName with iterations: $iterations and pollrate: $pollRate(s)"

# Check if process exist
$parentProcess = $(Get-CimInstance -ClassName win32_process -Filter "name = '$processName.exe'")[0]
if (!$parentProcess) {
    Write-Output "Process: $processName not found, stopping execution"
    exit 1
}
Write-Output "Process: $parentProcess found"

if (!$monitorOnly) {
    Write-Output "Saving csv file to $csvOutputFilePath"
    $csvHeader | Out-File -FilePath $csvOutputFilePath
}

Get-UtilizationStats

Read-Host -Prompt "Press Enter to exit"
