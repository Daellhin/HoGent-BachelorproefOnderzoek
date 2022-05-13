param ( 	
    [int]$iterations = -1 # -1 to to loop indefinately
);
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

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

function Get-ColorAt([int]$x, [int]$y) {
    $map = [System.Drawing.Rectangle]::FromLTRB($x, $y, $x + 1, $y + 1)
    $bmp = New-Object System.Drawing.Bitmap(1, 1)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($map.Location, [System.Drawing.Point]::Empty, $map.Size)
    return $bmp.GetPixel(0, 0)
}

function Show-PositionAndColor([int]$x, [int]$y) {
    $scaledPosition = Get-CursorPosition
    $unscaledPosition = Get-UnscaledCursorPosition
    $color = Get-ColorAt $unscaledPosition.X $unscaledPosition.Y
    #  Write-Output "X: $($unscaledPosition.X) => $($scaledPosition.X), Y: $($unscaledPosition.Y) => $($scaledPosition.Y) | R: $($color.R), G: $($color.G), B: $($color.B)"
    Write-Output "X: $($scaledPosition.X) => $($unscaledPosition.X), Y: $($scaledPosition.Y) => $($unscaledPosition.Y) | $($color.Name.Substring(2))"
}

# -- Main Block --
if ($iterations -eq -1) {
    while ($true) {
        Show-PositionAndColor
    }
}
else {
    for ($i = 0; $i -lt $iterations; $i++) {
        Show-PositionAndColor
    }
    Read-Host -Prompt "Press Enter to exit"
}
