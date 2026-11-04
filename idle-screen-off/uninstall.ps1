Remove-Item (Join-Path ([Environment]::GetFolderPath("Startup")) "idle-screen-off.lnk") -ErrorAction SilentlyContinue
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'idle-screen-off\.ps1' -and $_.ProcessId -ne $PID } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
"제거 완료: 시작프로그램에서 빼고 실행 중인 것을 멈췄습니다."