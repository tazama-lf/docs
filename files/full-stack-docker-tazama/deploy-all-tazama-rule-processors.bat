@echo on
@echo ===================================
@echo 1. Duplicating Rule Executer folder
@echo ===================================
@echo off
pause
@echo on

xcopy rule-executer rule-executer-001 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-001\package.json) -replace 'rule-901@2.0.0', 'rule-001@2.0.0' | Set-Content %1\rule-executer-001\package.json"
powershell -Command "(Get-Content %1\rule-executer-001\Dockerfile) -replace '901', '001' | Set-Content %1\rule-executer-001\Dockerfile"
xcopy rule-executer rule-executer-002 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-002\package.json) -replace 'rule-901@2.0.0', 'rule-002@2.0.0' | Set-Content %1\rule-executer-002\package.json"
powershell -Command "(Get-Content %1\rule-executer-002\Dockerfile) -replace '901', '002' | Set-Content %1\rule-executer-002\Dockerfile"
xcopy rule-executer rule-executer-003 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-003\package.json) -replace 'rule-901@2.0.0', 'rule-003@2.0.0' | Set-Content %1\rule-executer-003\package.json"
powershell -Command "(Get-Content %1\rule-executer-003\Dockerfile) -replace '901', '003' | Set-Content %1\rule-executer-003\Dockerfile"
xcopy rule-executer rule-executer-004 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-004\package.json) -replace 'rule-901@2.0.0', 'rule-004@2.0.0' | Set-Content %1\rule-executer-004\package.json"
powershell -Command "(Get-Content %1\rule-executer-004\Dockerfile) -replace '901', '004' | Set-Content %1\rule-executer-004\Dockerfile"
xcopy rule-executer rule-executer-006 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-006\package.json) -replace 'rule-901@2.0.0', 'rule-006@2.0.0' | Set-Content %1\rule-executer-006\package.json"
powershell -Command "(Get-Content %1\rule-executer-006\Dockerfile) -replace '901', '006' | Set-Content %1\rule-executer-006\Dockerfile"
xcopy rule-executer rule-executer-007 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-007\package.json) -replace 'rule-901@2.0.0', 'rule-007@2.0.0' | Set-Content %1\rule-executer-007\package.json"
powershell -Command "(Get-Content %1\rule-executer-007\Dockerfile) -replace '901', '007' | Set-Content %1\rule-executer-007\Dockerfile"
xcopy rule-executer rule-executer-008 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-008\package.json) -replace 'rule-901@2.0.0', 'rule-008@2.0.0' | Set-Content %1\rule-executer-008\package.json"
powershell -Command "(Get-Content %1\rule-executer-008\Dockerfile) -replace '901', '008' | Set-Content %1\rule-executer-008\Dockerfile"
xcopy rule-executer rule-executer-010 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-010\package.json) -replace 'rule-901@2.0.0', 'rule-010@2.0.0' | Set-Content %1\rule-executer-010\package.json"
powershell -Command "(Get-Content %1\rule-executer-010\Dockerfile) -replace '901', '010' | Set-Content %1\rule-executer-010\Dockerfile"
xcopy rule-executer rule-executer-011 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-011\package.json) -replace 'rule-901@2.0.0', 'rule-011@2.0.0' | Set-Content %1\rule-executer-011\package.json"
powershell -Command "(Get-Content %1\rule-executer-011\Dockerfile) -replace '901', '011' | Set-Content %1\rule-executer-011\Dockerfile"
xcopy rule-executer rule-executer-016 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-016\package.json) -replace 'rule-901@2.0.0', 'rule-016@2.0.0' | Set-Content %1\rule-executer-016\package.json"
powershell -Command "(Get-Content %1\rule-executer-016\Dockerfile) -replace '901', '016' | Set-Content %1\rule-executer-016\Dockerfile"
xcopy rule-executer rule-executer-017 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-017\package.json) -replace 'rule-901@2.0.0', 'rule-017@2.0.0' | Set-Content %1\rule-executer-017\package.json"
powershell -Command "(Get-Content %1\rule-executer-017\Dockerfile) -replace '901', '017' | Set-Content %1\rule-executer-017\Dockerfile"
xcopy rule-executer rule-executer-018 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-018\package.json) -replace 'rule-901@2.0.0', 'rule-018@2.0.0' | Set-Content %1\rule-executer-018\package.json"
powershell -Command "(Get-Content %1\rule-executer-018\Dockerfile) -replace '901', '018' | Set-Content %1\rule-executer-018\Dockerfile"
xcopy rule-executer rule-executer-020 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-020\package.json) -replace 'rule-901@2.0.0', 'rule-020@2.0.0' | Set-Content %1\rule-executer-020\package.json"
powershell -Command "(Get-Content %1\rule-executer-020\Dockerfile) -replace '901', '020' | Set-Content %1\rule-executer-020\Dockerfile"
xcopy rule-executer rule-executer-021 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-021\package.json) -replace 'rule-901@2.0.0', 'rule-021@2.0.0' | Set-Content %1\rule-executer-021\package.json"
powershell -Command "(Get-Content %1\rule-executer-021\Dockerfile) -replace '901', '021' | Set-Content %1\rule-executer-021\Dockerfile"
xcopy rule-executer rule-executer-024 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-024\package.json) -replace 'rule-901@2.0.0', 'rule-024@2.0.0' | Set-Content %1\rule-executer-024\package.json"
powershell -Command "(Get-Content %1\rule-executer-024\Dockerfile) -replace '901', '024' | Set-Content %1\rule-executer-024\Dockerfile"
xcopy rule-executer rule-executer-025 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-025\package.json) -replace 'rule-901@2.0.0', 'rule-025@2.0.0' | Set-Content %1\rule-executer-025\package.json"
powershell -Command "(Get-Content %1\rule-executer-025\Dockerfile) -replace '901', '025' | Set-Content %1\rule-executer-025\Dockerfile"
xcopy rule-executer rule-executer-026 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-026\package.json) -replace 'rule-901@2.0.0', 'rule-026@2.0.0' | Set-Content %1\rule-executer-026\package.json"
powershell -Command "(Get-Content %1\rule-executer-026\Dockerfile) -replace '901', '026' | Set-Content %1\rule-executer-026\Dockerfile"
xcopy rule-executer rule-executer-027 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-027\package.json) -replace 'rule-901@2.0.0', 'rule-027@2.0.0' | Set-Content %1\rule-executer-027\package.json"
powershell -Command "(Get-Content %1\rule-executer-027\Dockerfile) -replace '901', '027' | Set-Content %1\rule-executer-027\Dockerfile"
xcopy rule-executer rule-executer-028 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-028\package.json) -replace 'rule-901@2.0.0', 'rule-028@2.0.0' | Set-Content %1\rule-executer-028\package.json"
powershell -Command "(Get-Content %1\rule-executer-028\Dockerfile) -replace '901', '028' | Set-Content %1\rule-executer-028\Dockerfile"
xcopy rule-executer rule-executer-030 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-030\package.json) -replace 'rule-901@2.0.0', 'rule-030@2.0.0' | Set-Content %1\rule-executer-030\package.json"
powershell -Command "(Get-Content %1\rule-executer-030\Dockerfile) -replace '901', '030' | Set-Content %1\rule-executer-030\Dockerfile"
xcopy rule-executer rule-executer-044 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-044\package.json) -replace 'rule-901@2.0.0', 'rule-044@2.0.0' | Set-Content %1\rule-executer-044\package.json"
powershell -Command "(Get-Content %1\rule-executer-044\Dockerfile) -replace '901', '044' | Set-Content %1\rule-executer-044\Dockerfile"
xcopy rule-executer rule-executer-045 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-045\package.json) -replace 'rule-901@2.0.0', 'rule-045@2.0.0' | Set-Content %1\rule-executer-045\package.json"
powershell -Command "(Get-Content %1\rule-executer-045\Dockerfile) -replace '901', '045' | Set-Content %1\rule-executer-045\Dockerfile"
xcopy rule-executer rule-executer-048 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-048\package.json) -replace 'rule-901@2.0.0', 'rule-048@2.0.0' | Set-Content %1\rule-executer-048\package.json"
powershell -Command "(Get-Content %1\rule-executer-048\Dockerfile) -replace '901', '048' | Set-Content %1\rule-executer-048\Dockerfile"
xcopy rule-executer rule-executer-054 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-054\package.json) -replace 'rule-901@2.0.0', 'rule-054@2.0.0' | Set-Content %1\rule-executer-054\package.json"
powershell -Command "(Get-Content %1\rule-executer-054\Dockerfile) -replace '901', '054' | Set-Content %1\rule-executer-054\Dockerfile"
xcopy rule-executer rule-executer-063 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-063\package.json) -replace 'rule-901@2.0.0', 'rule-063@2.0.0' | Set-Content %1\rule-executer-063\package.json"
powershell -Command "(Get-Content %1\rule-executer-063\Dockerfile) -replace '901', '063' | Set-Content %1\rule-executer-063\Dockerfile"
xcopy rule-executer rule-executer-074 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-074\package.json) -replace 'rule-901@2.0.0', 'rule-074@2.0.0' | Set-Content %1\rule-executer-074\package.json"
powershell -Command "(Get-Content %1\rule-executer-074\Dockerfile) -replace '901', '074' | Set-Content %1\rule-executer-074\Dockerfile"
xcopy rule-executer rule-executer-075 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-075\package.json) -replace 'rule-901@2.0.0', 'rule-075@2.0.0' | Set-Content %1\rule-executer-075\package.json"
powershell -Command "(Get-Content %1\rule-executer-075\Dockerfile) -replace '901', '075' | Set-Content %1\rule-executer-075\Dockerfile"
xcopy rule-executer rule-executer-076 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-076\package.json) -replace 'rule-901@2.0.0', 'rule-076@2.0.0' | Set-Content %1\rule-executer-076\package.json"
powershell -Command "(Get-Content %1\rule-executer-076\Dockerfile) -replace '901', '076' | Set-Content %1\rule-executer-076\Dockerfile"
xcopy rule-executer rule-executer-078 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-078\package.json) -replace 'rule-901@2.0.0', 'rule-078@2.0.0' | Set-Content %1\rule-executer-078\package.json"
powershell -Command "(Get-Content %1\rule-executer-078\Dockerfile) -replace '901', '078' | Set-Content %1\rule-executer-078\Dockerfile"
xcopy rule-executer rule-executer-083 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-083\package.json) -replace 'rule-901@2.0.0', 'rule-083@2.0.0' | Set-Content %1\rule-executer-083\package.json"
powershell -Command "(Get-Content %1\rule-executer-083\Dockerfile) -replace '901', '083' | Set-Content %1\rule-executer-083\Dockerfile"
xcopy rule-executer rule-executer-084 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-084\package.json) -replace 'rule-901@2.0.0', 'rule-084@2.0.0' | Set-Content %1\rule-executer-084\package.json"
powershell -Command "(Get-Content %1\rule-executer-084\Dockerfile) -replace '901', '084' | Set-Content %1\rule-executer-084\Dockerfile"
xcopy rule-executer rule-executer-090 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-090\package.json) -replace 'rule-901@2.0.0', 'rule-090@2.0.0' | Set-Content %1\rule-executer-090\package.json"
powershell -Command "(Get-Content %1\rule-executer-090\Dockerfile) -replace '901', '090' | Set-Content %1\rule-executer-090\Dockerfile"
xcopy rule-executer rule-executer-091 /E /I /H
powershell -Command "(Get-Content %1\rule-executer-091\package.json) -replace 'rule-901@2.0.0', 'rule-091@2.0.0' | Set-Content %1\rule-executer-091\package.json"
powershell -Command "(Get-Content %1\rule-executer-091\Dockerfile) -replace '901', '091' | Set-Content %1\rule-executer-091\Dockerfile"

@echo =========================
@echo 2. Building rule packages
@echo =========================
@echo off
pause
@echo on

cd rule-executer-001
call npm install

cd ..\rule-executer-002
call npm install

cd ..\rule-executer-003
call npm install

cd ..\rule-executer-004
call npm install

cd ..\rule-executer-006
call npm install

cd ..\rule-executer-007
call npm install

cd ..\rule-executer-008
call npm install

cd ..\rule-executer-010
call npm install

cd ..\rule-executer-011
call npm install

cd ..\rule-executer-016
call npm install

cd ..\rule-executer-017
call npm install

cd ..\rule-executer-018
call npm install

cd ..\rule-executer-020
call npm install

cd ..\rule-executer-021
call npm install

cd ..\rule-executer-024
call npm install

cd ..\rule-executer-025
call npm install

cd ..\rule-executer-026
call npm install

cd ..\rule-executer-027
call npm install

cd ..\rule-executer-028
call npm install

cd ..\rule-executer-030
call npm install

cd ..\rule-executer-044
call npm install

cd ..\rule-executer-045
call npm install

cd ..\rule-executer-048
call npm install

cd ..\rule-executer-054
call npm install

cd ..\rule-executer-063
call npm install

cd ..\rule-executer-074
call npm install

cd ..\rule-executer-075
call npm install

cd ..\rule-executer-076
call npm install

cd ..\rule-executer-078
call npm install

cd ..\rule-executer-083
call npm install

cd ..\rule-executer-084
call npm install

cd ..\rule-executer-090
call npm install

cd ..\rule-executer-091
call npm install

@echo ========================================
@echo 3. Deploying rule processors into Docker
@echo ========================================
@echo off
pause
@echo on

cd %1

cd Full-Stack-Docker-Tazama

docker compose up -d rule-001
docker compose up -d rule-002
docker compose up -d rule-003
docker compose up -d rule-004
docker compose up -d rule-006
docker compose up -d rule-007
docker compose up -d rule-008
docker compose up -d rule-010
docker compose up -d rule-011
docker compose up -d rule-016
docker compose up -d rule-017
docker compose up -d rule-018
docker compose up -d rule-020
docker compose up -d rule-021
docker compose up -d rule-024
docker compose up -d rule-025
docker compose up -d rule-026
docker compose up -d rule-027
docker compose up -d rule-028
docker compose up -d rule-030
docker compose up -d rule-044
docker compose up -d rule-045
docker compose up -d rule-048
docker compose up -d rule-054
docker compose up -d rule-063
docker compose up -d rule-074
docker compose up -d rule-075
docker compose up -d rule-076
docker compose up -d rule-078
docker compose up -d rule-083
docker compose up -d rule-084
docker compose up -d rule-090
docker compose up -d rule-091

@echo ===================
@echo Deployment complete
@echo ===================
