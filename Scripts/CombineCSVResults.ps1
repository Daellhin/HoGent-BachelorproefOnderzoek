param ( 	
    [string[]]$tests = ("Search", "Startup", "Profile", "Build" )
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

Write-Output "Make sure combined.csv files are deleted"

foreach ($test in $tests) {
    # Constants
    $csvInputPath = "..\CSV\"
    $csvOutputFileName = "Combined-$($test)Results"
    $csvOutputFilePath = "../CSV/$csvOutputFileName.csv"

    # -- Main Block --
    Write-Output "Conbining $test results from folder $csvInputPath"

    # Load files
    $csvInputFiles = Get-ChildItem $csvInputPath -Filter "*$test*.csv"
    Write-Output "Found $(@($csvInputFiles).Count) files to combine"
    $csvInputFiles

    # Append
    $csvInputFiles | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $csvOutputFilePath -NoTypeInformation -Append
    Write-Output "Saved csv file to $csvOutputFilePath"
}

Read-Host -Prompt "Press Enter to exit"
