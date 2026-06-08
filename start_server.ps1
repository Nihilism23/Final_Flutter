# ??? HTTP ?????? - PowerShell
Write-Host "Starting web server on http://localhost:8000" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = $request.Url.LocalPath
        if ($urlPath -eq "/") { $urlPath = "/index.html" }

        $filePath = Join-Path "build\web" $urlPath.TrimStart("/")

        if (Test-Path $filePath) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length

            $extension = [System.IO.Path]::GetExtension($filePath)
            switch ($extension) {
                ".html" { $response.ContentType = "text/html; charset=utf-8" }
                ".css"  { $response.ContentType = "text/css; charset=utf-8" }
                ".js"   { $response.ContentType = "application/javascript" }
                ".json" { $response.ContentType = "application/json" }
                ".png"  { $response.ContentType = "image/png" }
                ".jpg"  { $response.ContentType = "image/jpeg" }
                ".gif"  { $response.ContentType = "image/gif" }
                ".ico"  { $response.ContentType = "image/x-icon" }
                ".svg"  { $response.ContentType = "image/svg+xml" }
                ".webp" { $response.ContentType = "image/webp" }
                ".ttf"  { $response.ContentType = "font/ttf" }
                ".otf"  { $response.ContentType = "font/otf" }
                ".wasm" { $response.ContentType = "application/wasm" }
                ".bin"  { $response.ContentType = "application/octet-stream" }
                default { $response.ContentType = "application/octet-stream" }
            }

            $response.OutputStream.Write($content, 0, $content.Length)
            Write-Host "200 - $urlPath" -ForegroundColor Green
        } else {
            $response.StatusCode = 404
            $errorMsg = "404 - File not found"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorMsg)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            Write-Host "404 - $urlPath" -ForegroundColor Red
        }

        $response.Close()
    }
} finally {
    $listener.Stop()
    Write-Host "Server stopped" -ForegroundColor Yellow
}
