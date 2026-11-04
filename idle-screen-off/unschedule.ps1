Unregister-ScheduledTask -TaskPath "\pc-tools\" -TaskName "idle-screen-off" -Confirm:$false -ErrorAction SilentlyContinue
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'idle-screen-off\.ps1' -and $_.ProcessId -ne $PID } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
"예약 해제 완료: 더 이상 자동 실행되지 않고, 실행 중인 것도 멈췄습니다."