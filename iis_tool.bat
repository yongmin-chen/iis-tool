@echo off
setlocal enabledelayedexpansion
path %systemroot%\system32\inetsrv;%path%
mode con cols=80 lines=31
:start
cls
title IIS 7+ 工具箱
echo.
echo.
echo    ───────────§──────────§───────────
ECHO.                                 
ECHO               A. 显示网站列表                  
ECHO               B. 停止多个站点        
ECHO               C. 启动多个站点        
ECHO               D. 站点迁移        
ECHO               I. 新建站点        
ECHO               T. 退出                 
ECHO.                                
ECHO    ───────────────────────────────────
echo.
SET Choice=
SET /P Choice=    请选择要进行的操作（A/B/C/D/...），然后按回车：
ECHO.
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%
IF /I '%Choice%'=='A' GOTO A
IF /I '%Choice%'=='B' GOTO B
IF /I '%Choice%'=='C' GOTO C
IF /I '%Choice%'=='D' GOTO D
IF /I '%Choice%'=='H' GOTO H
IF /I '%Choice%'=='I' GOTO I
IF /I '%Choice%'=='T' GOTO T
GOTO Start

:: 网站列表
:A
cls
set a=0
for /f "delims=," %%i in ('appcmd list sites  /text:name') do (
    set names[!a!]=%%i
    set /a a+=1
)
set c=0
for /f "delims=," %%i in ('appcmd list sites  /text:state') do (
    set state[!c!]=%%i
    set /a c+=1
)
set /a d=%c%-1
for /l %%i in (0, 1, %d%) do (
    echo %%i     !names[%%i]!    !state[%%i]!
)
pause
GOTO Start

:: 停止多个网站
:B
cls
set a=0
for /f "delims=," %%i in ('appcmd list sites /state:Started /text:name') do (
    set names[!a!]=%%i
    set /a a+=1
)

set c=0
for /f "delims=," %%i in ('appcmd list sites /state:Started /text:state') do (
    set state[!c!]=%%i
    set /a c+=1
)

set /a d=%c%-1
for /l %%i in (0, 1, %d%) do (
    echo %%i     !names[%%i]!    !state[%%i]!
)

set IDS=
set /P IDS=请输入要停止的网站ID，用空格分割，a 为全部启动:  
if %IDS% EQU a (
    for /f "delims=," %%i in ('appcmd list sites /state:Started /text:name') do (
          call :fun_stop_site "%%i"  
    )
    pause
    goto:Start        
)

for %%i in (%IDS%) do (
     if "!names[%%i]!" NEQ "" ( 
        call :fun_stop_site "!names[%%i]!"
     )
)
pause
GOTO Start

:: 停止站点
:fun_stop_site
appcmd stop site %1
goto:eof

:: 启动多个网站
:C
cls
set a=0
for /f "delims=," %%i in ('appcmd list sites /state:Stopped /text:name') do (
    set names[!a!]=%%i
    set /a a+=1
)

set c=0
for /f "delims=," %%i in ('appcmd list sites /state:Stopped /text:state') do (
    set state[!c!]=%%i
    set /a c+=1
)

set /a d=%c%-1
for /l %%i in (0, 1, %d%) do (
    echo %%i     !names[%%i]!    !state[%%i]!
)
set IDS=
set /P IDS=请输入要启动的网站ID，用空格分割，a 为全部停止: 
if %IDS% EQU a (
    for /f "delims=," %%i in ('appcmd list sites /state:Stopped /text:name') do (
          call :fun_start_site "%%i"  
    )
    pause
    goto:Start       
)

for %%i in (%IDS%) do (
     if "!names[%%i]!" NEQ "" ( 
        call :fun_start_site "!names[%%i]!"
     )
)
pause
GOTO Start

:: 启动站点
:fun_start_site
appcmd start site %1
goto:eof

:: 迁移
:D
cls
echo.
echo.
echo    ───────────§──────────§───────────
ECHO.                                 
ECHO               D1. 迁出                 
ECHO               D2. 迁入        
echo.
ECHO    ───────────────────────────────────
echo.
SET Choice=
SET /P Choice=    请选择要进行的操作（/D1/D2），然后按回车：
ECHO.
if %Choice% EQU D1 (
    if not exist config ( mkdir config )
    appcmd list apppool /config /xml > config\apppools.xml
    if %errorlevel% EQU 0 (
           echo 应用程序池导出成功！ 请到 config 文件夹下查看。 
    ) else (
           echo 应用程序池导出失败！ 
    )
    appcmd list site /config /xml > config\sites.xml
    if %errorlevel% EQU 0 (
           echo 站点导出成功！ 请到 config 文件夹下查看。 
    ) else (
           echo 站点导出失败！ 
    )
    pause
    GOTO Start
)
if %Choice% EQU D2 (
    echo 开始备份。。。
    appcmd add backup
    if %errorlevel% EQU 0 echo 备份完成。
    set /P is_clean= 清空原有配置，请输入 Y 后回车： 
    if !is_clean! EQU Y (
        for /f "tokens=1,*" %%i in ('appcmd list site') do (
                call :Fun_del_site %%j
        )
        if %errorlevel% EQU 0 (成功清除站点配置)
        for /f "tokens=1,*" %%i in ('appcmd list apppool') do (
                call :fun_del_pool %%j
        )
        if %errorlevel% EQU 0 (成功清除)
    )

    appcmd add site /in < config\sites.xml
    if %errorlevel% NEQ 0 (
                echo 网站导入失败
    ) else (
                echo 网站入成功
    )

    appcmd add apppool /in < config\apppools.xml
    if %errorlevel% NEQ 0  (
                echo 应用池导入失败
    ) else (
                echo 应用池导入成功
    )

)
pause
GOTO Start


:: 清空应用程序池 
:fun_del_pool
appcmd delete apppool %1
goto:eof

:: 清空站点信息
:fun_del_site
appcmd delete site %1
goto:eof


:: 新建站点
:I
cls
SET root_path=c:\wwwroot
SET site_name=
SET /P site_name=    请输入网站主域名，然后按回车：
:: 创建进程池
appcmd add apppool /name:%site_name%

:: 创建网站目录
set site_dir=%root_path%\%site_name%\www
mkdir %site_dir%
choice /t 5 /d y /n >nul
icacls %site_dir% /grant "IIS AppPool\%site_name%":(CI)(OI)(M)

:: 创建网站
appcmd add site /name:%site_name%  /physicalPath:%site_dir% /bindings:http/*:80:%site_name%

appcmd set site /site.name:%site_name% /[path='/'].applicationPool:%site_name%
pause
goto:Start

:T
Exit \B 0

