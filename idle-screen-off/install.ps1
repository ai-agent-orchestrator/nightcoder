param([int]$IdleMin = 10)
$dst = Join-Path $env:LOCALAPPDATA "idle-screen-off\idle-screen-off.ps1"
New-Item -ItemType Directory (Split-Path $dst) -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot "idle-screen-off.ps1") $dst -Force
$a = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$dst`" -IdleMin $IdleMin"
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut((Join-Path ([Environment]::GetFolderPath("Startup")) "idle-screen-off.lnk"))
$lnk.TargetPath = "powershell.exe"; $lnk.Arguments = $a; $lnk.WindowStyle = 7; $lnk.Save()
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList $a
"설치 완료: 로그온할 때마다 자동 실행 (입력 없음 $IdleMin 분이면 화면 끔)"