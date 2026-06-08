@echo off
echo Starting local web server...
echo.
echo Your app will be available at:
echo http://localhost:8080
echo.
echo On your local network, use your IP address, like:
echo http://192.168.x.x:8080
echo.
echo Press Ctrl+C to stop
echo.
cd build\web
python -m http.server 8080
pause
