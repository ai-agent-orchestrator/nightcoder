# idle-screen-off

마우스·키보드 입력이 일정 시간 없으면 **모니터만** 끄는 Windows 도구입니다.
절전이나 잠금은 하지 않아서, 밤새 도는 작업(빌드, 에이전트, 다운로드)에 영향이 없습니다.

## 왜 필요한가
Windows의 "화면 끄기" 설정은 어떤 프로그램이 화면 유지를 요청하면 동작하지 않습니다.
이 도구는 입력이 없는 동안 5분마다 확인해서, 다른 프로그램이 화면을 켜도 다시 끕니다.

## 평일 저녁 자동 실행 (권장)
```powershell
git clone -b tools/idle-screen-off https://github.com/ai-agent-orchestrator/nightcoder.git C:\work\pc-tools
powershell -NoProfile -ExecutionPolicy Bypass -File C:\work\pc-tools\idle-screen-off\schedule.ps1
```
기본값: 월~금 18:20 시작, 다음 날 09:00 종료, 2027-01-20까지 반복, 입력 없음 10분.
바꾸려면 `-At 18:30 -UntilTime 08:30 -EndDate 2027-03-01 -IdleMin 15`처럼 붙입니다. 관리자 권한은 필요 없습니다.

해제:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\work\pc-tools\idle-screen-off\unschedule.ps1
```

## 로그온할 때마다 실행 (대안)
`install.ps1` / `uninstall.ps1`

## 한 번만 실행
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\idle-screen-off.ps1 -IdleMin 10 -UntilTime 09:00
```

## 동작
- 두 번 실행돼도 하나만 돕니다.
- 로그: `%LOCALAPPDATA%\idle-screen-off\log.txt`