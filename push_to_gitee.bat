@echo off
echo ============================================
echo    超级天气课程表 - 推送到Gitee
echo ============================================
echo.

REM 检查是否已初始化git
if not exist ".git" (
    echo [1/6] 初始化Git仓库...
    git init
    if errorlevel 1 (
        echo 错误: Git初始化失败
        pause
        exit /b 1
    )
    echo ? Git仓库初始化成功
    echo.
)

REM 添加远程仓库
echo [2/6] 添加Gitee远程仓库...
git remote remove origin 2>nul
git remote add origin https://gitee.com/gcx_952128814/super_-weather_-schedule_1.git
if errorlevel 1 (
    echo 警告: 添加远程仓库时出现问题，但继续执行
)
echo ? 远程仓库已添加
echo.

REM 添加所有文件
echo [3/6] 添加文件到暂存区...
git add .
echo ? 文件已添加
echo.

REM 提交更改
echo [4/6] 提交更改...
git commit -m "feat: 初始化超级天气课程表项目"
if errorlevel 1 (
    echo 提示: 如果没有更改需要提交，这是正常的
)
echo ? 提交完成
echo.

REM 推送到Gitee
echo [5/6] 推送到Gitee...
echo.
echo ============================================
echo    注意: 推送到远程仓库
echo ============================================
echo.
echo ============================================
echo.

echo [6/6] 尝试推送到Gitee...
git branch -M master
git push -u origin master

echo.
echo ============================================
echo    完成!
echo ============================================
echo.
echo 如果推送失败，请检查:
echo 1. Gitee仓库地址是否正确
echo 2. 是否已配置Git凭据
echo 3. 网络连接是否正常
echo.
pause
