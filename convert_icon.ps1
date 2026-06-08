# ????????? - ????APP???
Add-Type -AssemblyName System.Drawing

Write-Host "Processing image..." -ForegroundColor Green

# ???¡¤??
$sourceImage = "e:\flutter_projects\course_schedule_1\20250515_164006(1).jpg"

# ?????
$targetDirs = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

Write-Host "Source: $sourceImage" -ForegroundColor Cyan

# ???????
$image = [System.Drawing.Image]::FromFile($sourceImage)

foreach ($size in $targetDirs.Keys) {
    $width = $targetDirs[$size]
    $height = $targetDirs[$size]
    
    $targetPath = "e:\flutter_projects\course_schedule_1\android\app\src\main\res\mipmap-$size\ic_launcher.png"
    
    Write-Host "Generating $size ($width x $height)..." -ForegroundColor Yellow
    
    # ?????????
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    
    # ????????????
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # ??????§Ó¨¹?????
    $minSide = [Math]::Min($image.Width, $image.Height)
    $srcX = ($image.Width - $minSide) / 2
    $srcY = ($image.Height - $minSide) / 2
    
    # ????
    $srcRect = New-Object System.Drawing.Rectangle($srcX, $srcY, $minSide, $minSide)
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $graphics.DrawImage($image, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    
    # ????
    $bmp.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # ??????
    $graphics.Dispose()
    $bmp.Dispose()
    
    Write-Host "Saved to: $targetPath" -ForegroundColor Green
}

$image.Dispose()

Write-Host ""
Write-Host "? All icons generated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'flutter clean'" -ForegroundColor Cyan
Write-Host "2. Run 'flutter run' to reinstall the app" -ForegroundColor Cyan
