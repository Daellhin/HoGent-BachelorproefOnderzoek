param ( 	
    [int]$iterations = 10,
    [string]$projectName = "Mindustry" # Cake or Mindustry
);
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0 

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Constants
$programName = "Notepad"

$test = "Search"
$csvOutputFileName = "$programName-$($test)Results-$projectName"
$csvOutputFilePath = "../CSV/$csvOutputFileName.csv"
$csvHeader = "Program, Project, $($test)Time(ms)"

# Screen unscaling setup
Add-Type @'
using System; 
using System.Runtime.InteropServices;
using System.Drawing;

public class DPI {  
  [DllImport("gdi32.dll")]
  static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

  public enum DeviceCap {
  VERTRES = 10,
  DESKTOPVERTRES = 117
  } 

  public static float scaling() {
  Graphics g = Graphics.FromHwnd(IntPtr.Zero);
  IntPtr desktop = g.GetHdc();
  int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
  int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);

  return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
  }
}
'@ -ReferencedAssemblies 'System.Drawing.dll' -ErrorAction Stop
$screenScale = [DPI]::scaling()

# Only accepts scaled cursorposition
function Set-CursorPosition([int]$x, [int]$y) {
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
}

# Returns scaled cursorposition
function Get-CursorPosition() {
    return [System.Windows.Forms.Cursor]::Position
}

function Get-UnscaledCursorPosition() {
    $postion = Get-CursorPosition
    return New-Object PSObject -Property @{
        X = $postion.X * $screenScale
        Y = $postion.Y * $screenScale
    }
}

# Only accepts unscaled cursorposition
# https://community.spiceworks.com/scripts/show/4263-get-screencolor
function Get-ColorAt([int]$x, [int]$y) {
    $map = [System.Drawing.Rectangle]::FromLTRB($x, $y, $x + 1, $y + 1)
    $bmp = New-Object System.Drawing.Bitmap(1, 1)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($map.Location, [System.Drawing.Point]::Empty, $map.Size)
    return $bmp.GetPixel(0, 0)
}

# AvailableKeys : https://docs.microsoft.com/en-us/previous-versions/office/developer/office-xp/aa202943(v=office.10)
function Use-Key([string]$key) {
    [System.Windows.Forms.SendKeys]::SendWait($key)
}

# https://stackoverflow.com/a/14096416/8807613
function Use-MouseButton([string]$Button) {
    $signature = @' 
      [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
      public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

    $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru 
    if ($Button -eq "left") {
        $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0)
        $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0)
    }
    if ($Button -eq "right") {
        $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0)
        $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0)
    }
    if ($Button -eq "middle") {
        $SendMouseClick::mouse_event(0x00000020, 0, 0, 0, 0)
        $SendMouseClick::mouse_event(0x00000040, 0, 0, 0, 0)
    }
}

# -- Main Block --
Write-Output "Measuring $test time for program: $programName in project: $projectName with iterations: $iterations"

# Prepare file
$csvHeader | Out-File -FilePath $csvOutputFilePath
Write-Output "Saved csv file to $csvOutputFilePath, with header: $csvHeader"

# Locations
$resultsXPos = 445 * $screenScale
$resultsYPos = 660 * $screenScale
$resultsFoundColor = "ffe8e8ff"

Read-Host -Prompt "Press Enter to start(Notepad++ must be opened)"

for ($i = 0; $i -lt $iterations; $i++) {
    # Get focus
    Set-CursorPosition 500 0 
    Use-MouseButton "left"

    # # remove old results
    # Use-Key "^a"
    # Start-Sleep 1
    # Use-Key "{DELETE}"

    Use-Key "^+f"
    Start-Sleep 1
    Write-Output "Starting search $i on $(Get-Date)"
    Use-Key "{ENTER}"

    $startingTime = Get-Date
    $endingTime = $null
    $resultsFound = $false
    Start-Sleep 1
    while (! $resultsFound) {
        $endingTime = Get-Date
        $color = Get-ColorAt $resultsXPos $resultsYPos 
        if ($color.Name -eq $resultsFoundColor) {
            $endingTime = Get-Date
            $resultsFound = $true
        }
    }
    
    $searchTime = ($endingTime - $startingTime).TotalMilliseconds

    # Write to file
    $newLine = "$programName, $projectName, $searchTime"
    $newLine | Add-Content -path $csvOutputFilePath

    Write-Output "Wrote: $newLine"

    Start-Sleep 2
}

Read-Host -Prompt "Press Enter to exit"
