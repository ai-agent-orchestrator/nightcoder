# Field notes: running an AI coder overnight, unattended (Nov 2026)

*What actually broke in two weeks of real night runs, and the design that now stops it. 밤새 AI 코더를 무인으로 돌리며 실제로 겪은 사고와, 그것을 막는 설계.*

**Setup.** One Windows PC. Claude writes specs as CTO, Codex CLI codes, NightCoder (`nc2.py`) relays specs one by one, re-runs the tests itself, rolls back failures and writes a report per spec. Two weeks of field runs, about 130 specs, test suite grown from ~500 to 1,300+ tests. The source stays private; this page is the part worth sharing.

## The rule that shaped everything

> A coder agent is never trusted with money, with the repository's remotes, or with its own verdict.

Every incident below was a place where one of those three leaked, or where the guard that protects them fired at the wrong moment.

## Incidents and fixes

| # | What happened | Why | Fix now in place |
| --- | --- | --- | --- |
| 1 | The queue stopped with a "purchase" alarm while credit was left, and no coder output at all | A browser already running looked like the coder's child process (Windows reuses process ids) | Snapshot the browsers present when the coder starts; only new ones count |
| 2 | A plain usage-limit notice ("…or try again at 2:31 PM") was treated as a purchase screen and locked the whole queue | The purchase detector matched the word before it checked for a retry time | A limit notice with a retry time means *wait until then and retry the same spec*; only a purchase screen with no retry time stops |
| 3 | The spec that fixes the detector was stopped by the detector, twice | The coder echoes its prompt, and later printed a diff with test data quoting a purchase line | Ignore lines echoed from our own prompt; never put literal purchase phrases in specs; build detector changes outside the relay |
| 4 | The coder hung with no output; the queue waited 90 minutes | Only a total timeout existed | Idle timeout: no output for 15 minutes ends the attempt, one retry |
| 5 | Yesterday's finished specs ran again under new numbers | The queue looked at file names only | Hash the spec body; a body that already passed is skipped |
| 6 | New specs dropped into the inbox were ignored until a restart | The queue was read once at start | Re-read the inbox after every spec |
| 7 | Failures kept spending credit through the night | `continue_after_failure` had no limit | Breakers: 3 consecutive failed specs, or the same error 3 times, stop the queue |
| 8 | The wrapper that auto-commits the coder's work sat inside the repo the coder edits | Convenience | The wrapper lives outside the lane; the lane forbids that folder; commits name the spec |
| 9 | Test fixtures with fake phone numbers and e-mails failed the leak check | The redaction scanner could not tell fake from real | Reserved fakes only (`example.com`, `.test`, zero-filled phones, 0000/1234 numbers) pass |
| 10 | A stop was noticed 35+ minutes late, with nobody at the PC | No remote path back in | A resume watcher reads an approved request file; a request can say "not before the reset" |
| 11 | Starts failed for reasons visible beforehand (dirty tree, red baseline, base moved) | No pre-flight | `doctor` prints READY / NOT READY before anything runs |
| 12 | Leftover coder processes from an interrupted run | Nothing reaped them | Record pid + start time; kill only that tree at the next start |
| 13 | The lane could not start because its base branch moved on | Fast-forward only | Merge the base in, abort cleanly on conflict |
| 14 | A Chroma index could not be versioned: delete/rename failed twice | Windows file locks on the vector index | Never move or delete live folders: immutable version folders plus an atomic pointer file |
| 15 | A draft branch was merged by habit ("the button was there") | Pushed branches invite pull requests | Draft branches are named `DO-NOT-MERGE`; only the CTO's explicit "merge this" counts |
| 16 | The queue tool was edited in two places | Two copies of the source | One private repository is the only source |

## What I would tell anyone doing this

1. **Separate "wait" from "stop".** A rate limit is a wait with a time; a payment screen is a stop for a human. Mixing them either burns money or kills the night.
2. **Your safety net will catch your own work.** A guard that reads output will also read your specs, diffs and tests. Design for that from day one.
3. **Never trust the coder's verdict.** Re-run the tests yourself, check the files it touched against the spec's scope, roll back on any doubt, keep the failed work on a branch.
4. **Count, don't feel.** Duplicates, idle hangs and failure streaks only became visible once every attempt was a ledger line.
5. **One source, one board, no leftovers.** Most confusion came from two copies of something. Merge and delete instead of keeping both.

## 한국어 요약

- 원칙: 코더 에이전트에게 돈, 원격 저장소, 자기 판정을 맡기지 않는다.
- 가장 큰 교훈: "기다림"(한도, 재시도 시각 있음)과 "멈춤"(결제 화면, 사람 필요)을 구분해야 한다. 섞으면 돈이 새거나 밤이 통째로 날아간다.
- 안전장치는 내 작업도 잡는다. 출력을 읽는 감지기는 명세·diff·시험 데이터까지 읽는다.
- 위 16건은 모두 실제 무인 실행에서 나왔고, 지금은 표의 마지막 열처럼 막고 있다. 코드는 비공개다.
