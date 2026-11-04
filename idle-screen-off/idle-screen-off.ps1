<#
  idle-screen-off: 마우스·키보드 입력이 IdleMin분 넘게 없으면 모니터를 끈다.
  절전·잠금은 하지 않는다. 다른 프로그램이 화면을 켜도, 입력이 없으면 다시 끈다.
#>
param([int]$IdleMin = 10, [int]$CheckSec = 300, [string]$Until = "", [string]$UntilTime = "")

$dir = Join-Path $env:LOCALAPPDATA "idle-screen-off"
New-Item -ItemType Directory $dir -Force | Out-Null
$log = Join-Path $dir "log.txt"
function Log($m) { Add-Content $log ("[{0:yyyy-MM-dd HH:mm}] {1}" -f (Get-Date), $m) -Encoding UTF8 }

$created = $false
$mutex = New-Object System.Threading.Mutex($true, "Local\idle-screen-off", [ref]$created)
if (-not $created) { exit 0 }

$end = [datetime]::MaxValue
if ($Until) { $end = [datetime]::ParseExact($Until, "yyyy-MM-ddTHH:mm", $null) }
elseif ($UntilTime) {
  $end = (Get-Date).Date.Add([datetime]::ParseExact($UntilTime, "HH:mm", $null).TimeOfDay)
  if ($end -le (Get-Date)) { $end = $end.AddDays(1) }
}

Add-Type -Namespace IdleOff -Name W -MemberDefinition @"
[StructLayout(LayoutKind.Sequential)] public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
[DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
[DllImport("user32.dll")] public static extern bool PostMessage(System.IntPtr hWnd, uint Msg, System.IntPtr wParam, System.IntPtr lParam);
public static uint IdleMs() { var i = new LASTINPUTINFO(); i.cbSize = (uint)Marshal.SizeOf(i); GetLastInputInfo(ref i); return unchecked((uint)System.Environment.TickCount - i.dwTime); }
"@

Log ("시작: 입력 없음 {0}분이면 화면 끔, {1}초마다 확인, 종료 {2}" -f $IdleMin, $CheckSec, $(if ($end -eq [datetime]::MaxValue) { "없음" } else { $end.ToString("yyyy-MM-dd HH:mm") }))
$logged = $false
while ((Get-Date) -lt $end) {
  if ([IdleOff.W]::IdleMs() -gt [uint32]($IdleMin * 60000)) {
    # WM_SYSCOMMAND 0x0112, SC_MONITORPOWER 0xF170, 2 = off
    [IdleOff.W]::PostMessage([System.IntPtr]0xFFFF, 0x0112, [System.IntPtr]0xF170, [System.IntPtr]2) | Out-Null
    if (-not $logged) { Log "화면 끔"; $logged = $true }
  } else { $logged = $false }
  Start-Sleep -Seconds $CheckSec
}
Log "종료"