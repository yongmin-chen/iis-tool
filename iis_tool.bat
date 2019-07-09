@echo off
setlocal enabledelayedexpansion
path %systemroot%\system32\inetsrv;%path%
mode con cols=80 lines=31
:start
cls
title IIS 7+ ������
echo.
echo.
echo    �����������������������쩤�������������������쩤��������������������
ECHO.                                 
ECHO               A. ��ʾ��վ�б�                  
ECHO               B. ֹͣ���վ��        
ECHO               C. �������վ��        
ECHO               D. վ��Ǩ��        
ECHO               I. �½�վ��        
ECHO               T. �˳�                 
ECHO.                                
ECHO    ����������������������������������������������������������������������
echo.
SET Choice=
SET /P Choice=    ��ѡ��Ҫ���еĲ�����A/B/C/D/...����Ȼ�󰴻س���
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

:: ��վ�б�
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

:: ֹͣ�����վ
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
set /P IDS=������Ҫֹͣ����վID���ÿո�ָa Ϊȫ������:  
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

:: ֹͣվ��
:fun_stop_site
appcmd stop site %1
goto:eof

:: ���������վ
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
set /P IDS=������Ҫ��������վID���ÿո�ָa Ϊȫ��ֹͣ: 
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

:: ����վ��
:fun_start_site
appcmd start site %1
goto:eof

:: Ǩ��
:D
cls
echo.
echo.
echo    �����������������������쩤�������������������쩤��������������������
ECHO.                                 
ECHO               D1. Ǩ��                 
ECHO               D2. Ǩ��        
echo.
ECHO    ����������������������������������������������������������������������
echo.
SET Choice=
SET /P Choice=    ��ѡ��Ҫ���еĲ�����/D1/D2����Ȼ�󰴻س���
ECHO.
if %Choice% EQU D1 (
    if not exist config ( mkdir config )
    appcmd list apppool /config /xml > config\apppools.xml
    if %errorlevel% EQU 0 (
           echo Ӧ�ó���ص����ɹ��� �뵽 config �ļ����²鿴�� 
    ) else (
           echo Ӧ�ó���ص���ʧ�ܣ� 
    )
    appcmd list site /config /xml > config\sites.xml
    if %errorlevel% EQU 0 (
           echo վ�㵼���ɹ��� �뵽 config �ļ����²鿴�� 
    ) else (
           echo վ�㵼��ʧ�ܣ� 
    )
    pause
    GOTO Start
)
if %Choice% EQU D2 (
    echo ��ʼ���ݡ�����
    appcmd add backup
    if %errorlevel% EQU 0 echo ������ɡ�
    set /P is_clean= ���ԭ�����ã������� Y ��س��� 
    if !is_clean! EQU Y (
        for /f "tokens=1,*" %%i in ('appcmd list site') do (
                call :Fun_del_site %%j
        )
        if %errorlevel% EQU 0 (�ɹ����վ������)
        for /f "tokens=1,*" %%i in ('appcmd list apppool') do (
                call :fun_del_pool %%j
        )
        if %errorlevel% EQU 0 (�ɹ����)
    )

    appcmd add site /in < config\sites.xml
    if %errorlevel% NEQ 0 (
                echo ��վ����ʧ��
    ) else (
                echo ��վ��ɹ�
    )

    appcmd add apppool /in < config\apppools.xml
    if %errorlevel% NEQ 0  (
                echo Ӧ�óص���ʧ��
    ) else (
                echo Ӧ�óص���ɹ�
    )

)
pause
GOTO Start


:: ���Ӧ�ó���� 
:fun_del_pool
appcmd delete apppool %1
goto:eof

:: ���վ����Ϣ
:fun_del_site
appcmd delete site %1
goto:eof


:: �½�վ��
:I
cls
SET root_path=c:\wwwroot
SET site_name=
SET /P site_name=    ��������վ��������Ȼ�󰴻س���
:: �������̳�
appcmd add apppool /name:%site_name%

:: ������վĿ¼
set site_dir=%root_path%\%site_name%\www
mkdir %site_dir%
choice /t 5 /d y /n >nul
icacls %site_dir% /grant "IIS AppPool\%site_name%":(CI)(OI)(M)

:: ������վ
appcmd add site /name:%site_name%  /physicalPath:%site_dir% /bindings:http/*:80:%site_name%

appcmd set site /site.name:%site_name% /[path='/'].applicationPool:%site_name%
pause
goto:Start

:T
Exit \B 0

