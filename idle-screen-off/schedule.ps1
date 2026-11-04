param([int]$IdleMin = 10, [string]$At = "18:20", [string]$UntilTime = "09:00", [string]$EndDate = "2027-01-20")
$dst = Join-Path $env:LOCALAPPDATA "idle-screen-off\idle-screen-off.ps1"
New-Item -ItemType Directory (Split-Path $dst) -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot "idle-screen-off.ps1") $dst -Force
$arg = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$dst`" -IdleMin $IdleMin -UntilTime $UntilTime"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arg
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At $At
$trigger.EndBoundary = ([datetime]::ParseExact($EndDate, "yyyy-MM-dd", $null)).AddDays(1).ToString("s")
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Hours 16)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskPath "\pc-tools\" -TaskName "idle-screen-off" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
$info = Get-ScheduledTask -TaskPath "\pc-tools\" -TaskName "idle-screen-off" | Get-ScheduledTaskInfo
"예약 완료: 월~금 $At 시작, 다음 날 $UntilTime 종료, $EndDate 까지 반복. 다음 실행: $($info.NextRunTime)"