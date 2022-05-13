param ( 	
    [int]$iterations = 10
);

Add-Type -AssemblyName System.Drawing

function Get-ColorAt([int]$x, [int]$y) {
    $map = [System.Drawing.Rectangle]::FromLTRB($x, $y, $x + 1, $y + 1)
    $bmp = New-Object System.Drawing.Bitmap(1, 1)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($map.Location, [System.Drawing.Point]::Empty, $map.Size)
    return $bmp.GetPixel(0, 0)
}

for ($i = -1; $i -lt $iterations; $i++) {
    $startingTime = Get-Date
    
    $color = Get-ColorAt 1 1

    $endingTime = Get-Date
    $timeDifference = ($endingTime - $startingTime).TotalMilliseconds;
    Write-Output "Took: $timeDifference";
}

Read-Host -Prompt "Press Enter to exit"