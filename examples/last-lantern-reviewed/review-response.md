# 리뷰 반영 내역

기존 리뷰 6개·종합·감사와 v1 게임 소스는 바이트 단위로 보존했다. 아래는 기존
리뷰 지적 **30/30개에 대한 구현·문서 반영**이다. 외부 사용자의 승률·체험 시간·이해도
목표는 아직 미검증이며, 30개가 새 독립 리뷰에서 해결 판정을 받았다는 뜻은 아니다.

원본 GDD의 누락과 원본 구현의 동작을 구분했다. 원본 구현에도 결말·3층 계단 없음·
확인창 차단이 있으므로 이 기능들을 새로 생긴 개선이라고 부르지 않는다.

## 지적별 반영

| 원문 지적 | 원본 | 반영 결과 | 구현 / 검증 |
| --- | --- | --- | --- |
| [원문 systems-designer/F1](../last-lantern/reviews/systems-designer.md) | 회복 약 150 / 피해 약 40이라는 리뷰 진단 | 회복 최대 36, 자동 회복 제거, 물약을 HP와 연료에 배분 | `drink_potion, burn_potion` / H/O 배분 · 자연 정책 40판 |
| [원문 systems-designer/F2](../last-lantern/reviews/systems-designer.md) | 무비용 대기 · 전멸해야 계단 개방 | 매 행동 연료 -1 · 수문장만 처치하면 이동 가능 | `_finish_action, _gate_alive` / 연료 패배 · 남은 적 있는 층 전환 |
| [원문 systems-designer/F3](../last-lantern/reviews/systems-designer.md) | 공격 +2 · 피해 ±1 · 마왕 경험치 20 | 공격 +1 · 고정 피해 · 레벨 4 상한 · 마왕 경험치 0 | `_attack_enemy` / 예측 가능한 타수 · 마왕 승리 시 경험치 없음 |
| [원문 systems-designer/F4](../last-lantern/reviews/systems-designer.md) | 마왕도 추격하는 일반 근접 적 | 왕좌 고정 · 예고→공격→회복 패턴 | `_boss_turn` / 한 칸 회피 · 피해 8 · 왕좌 유지 |
| [원문 systems-designer/F5](../last-lantern/reviews/systems-designer.md) | 층마다 같은 공급 · 가득 차면 바닥 보관 | 층별 2/3/1개 보급 · 넘치는 아이템 즉시 소비 | `_collect_item, _make_floor` / 층별 공급 · 물약/구슬 초과 소비 |
| [원문 narrative-critic/F1](../last-lantern/reviews/narrative-critic.md) | 등불은 시각 장식 | 등불 연료가 행동 예산과 패배 조건 | `_finish_action, burn_potion` / 연료 감소 · 보충 · 소진 결말 |
| [원문 narrative-critic/F2](../last-lantern/reviews/narrative-critic.md) | 결말·층 서사는 GDD에 미정의 (구현에는 결말 존재) | GDD에 오프닝·층 서사·마왕 조우·세 결말을 명시 | `_show_title, _finish_run` / 서사 전용 줄 · 엔진 화면 캡처 |
| [원문 narrative-critic/F3](../last-lantern/reviews/narrative-critic.md) | 마왕 뒤에 일반 적을 더 처치해야 승리 | 마왕 처치 즉시 새벽 결말 · 고유 공격 패턴 | `_attack_enemy, _boss_turn` / 일반 적이 남아도 즉시 승리 |
| [원문 narrative-critic/F4](../last-lantern/reviews/narrative-critic.md) | 같은 용사 무한 부활 해석의 여지 | 재시작은 다른 가능성의 여정이라고 명시 | `_finish_run, start_run` / 결과 문구 · 모든 성장 초기화 |
| [원문 narrative-critic/F5](../last-lantern/reviews/narrative-critic.md) | 층 이름 외에 동일 방·복도·공급 규칙 | 입구 넓은 복도 · 병영 좁은 복도 · 왕좌 넓은 방 | `_carve_tile, _make_floor` / 세 층의 구조·보급 구분 |
| [원문 player-psychologist/F1](../last-lantern/reviews/player-psychologist.md) | 회복 과잉과 숨은 기습의 난이도 분산 | 회복 조정 + 안전한 시작 + 각성 표시를 함께 도입 | `_generate_floor, _refresh` / 300층 안전 배치 · 두 정책 각각 20판 |
| [원문 player-psychologist/F2](../last-lantern/reviews/player-psychologist.md) | 마왕 처치가 마지막 사건이 아닐 수 있음 | 마왕 처치가 항상 즉시 결말 | `_attack_enemy` / 마왕 우선 승리 · 남은 적 행동 없음 |
| [원문 player-psychologist/F3](../last-lantern/reviews/player-psychologist.md) | 각성 여부 미표시 · 벽 관통 맨해튼 각성 | Z/!와 바닥 범위 점 · 벽을 따른 거리로 각성 | `_enemy_turn, _draw` / 시작 각성 0 · 각성 표시 캡처 |
| [원문 player-psychologist/F4](../last-lantern/reviews/player-psychologist.md) | 입력 거부·계단 조건 안내가 GDD에 없음 | 고정 목표·거부 이유 · 열린 계단 위 Enter | `_notice, descend` / 무효 입력 무비용 · 중복 안내 억제 |
| [원문 player-psychologist/F5](../last-lantern/reviews/player-psychologist.md) | 새 seed로만 다시 시작 · 기록 비교 없음 | seed 입력 · 같은 seed 재도전 · 세션 최소 승리 턴 | `start_run, _finish_run` / seed 재현 · 진행 초기화 |
| [원문 feasibility-lead/F1](../last-lantern/reviews/feasibility-lead.md) | GDD의 왕좌 참조 미정의 · 생성 실패 처리는 assert | 왕좌 방 명시 · 12회 검증 후 고정 폴백 | `_generate_floor, floor_errors` / 300층 + 강제 폴백 3층 |
| [원문 feasibility-lead/F2](../last-lantern/reviews/feasibility-lead.md) | 공유 RNG · 처리 순서 명세 없음 | 층별 생성 seed · 고정 전투 · ID순/BFS 동률 고정 | `_generate_floor, _step_towards` / 동일 입력 재현 · 이전 RNG와 층 생성 분리 |
| [원문 feasibility-lead/F3](../last-lantern/reviews/feasibility-lead.md) | 검증 수단·담당·절삭 순서 미정의 | GDD 제작 순서·담당·절삭 목록 · 내장 자가 점검 | `_run_self_checks` / --check-seeds=100 실제 실행 |
| [원문 feasibility-lead/F4](../last-lantern/reviews/feasibility-lead.md) | GDD에 상태별 입력 표 없음 (구현은 확인창 차단) | 입력 상태표 · 직접 행동 메서드에도 확인창 차단 | `act, drink_potion, burn_potion, descend` / 확인창 중 상태 보존 · 수문장 턴의 적 행동 |
| [원문 feasibility-lead/F5](../last-lantern/reviews/feasibility-lead.md) | 네이티브 프로젝트가 OS 한글 폰트에 의존 | OFL Noto Sans KR 동봉 · 확인 버전 명시 | `_ready` / 네이티브·웹 한글 렌더링 |
| [원문 adversarial-qa/F1](../last-lantern/reviews/adversarial-qa.md) | 전멸 시 남은 적 행동이라는 공허한 조항 | 수문장 처치 후 살아 있는 일반 적이 행동 | `_attack_enemy, _finish_action` / 수문장 처치 턴에 남은 적 공격 |
| [원문 adversarial-qa/F2](../last-lantern/reviews/adversarial-qa.md) | GDD의 3층 계단·왕좌 참조 미정의 (구현은 계단 없음) | 3층 계단 없음 · 방 2 중심 왕좌 · 마왕 고정 | `_make_floor, floor_errors` / 3층 목표·좌표·왕좌 검사 |
| [원문 adversarial-qa/F3](../last-lantern/reviews/adversarial-qa.md) | 거리 5 배치 / 거리 6 각성 · 벽 무시 | 경로 거리 8 이상 배치 / 거리 4 각성 · 벽 반영 | `_empty_cell, _enemy_turn` / 300층에서 시작 안전 거리 |
| [원문 adversarial-qa/F4](../last-lantern/reviews/adversarial-qa.md) | 후보 부족 시 assert · 폴백 미정의 | 후보 검증 · 유한 재시도 · 고정 폴백 검사 | `_generate_floor, floor_errors` / 무작위 300층 · 강제 폴백 |
| [원문 adversarial-qa/F5](../last-lantern/reviews/adversarial-qa.md) | 새 seed만 재시작 · RNG·확인창 명세 부족 | 같은 seed UI · 생성/전투 분리 · 상태표 | `start_run, _generate_floor` / 재현 · 확인창 차단 · 두 재시작 |
| [원문 business-analyst/F1](../last-lantern/reviews/business-analyst.md) | 교육용과 플레이어용 목적 미정의 | 주 사용자 개발자·수강생 · 리뷰→게임 변화 비교 | `GDD §1–2` / GDD 목표 · 비교 페이지 |
| [원문 business-analyst/F2](../last-lantern/reviews/business-analyst.md) | 등불의 이름 외에 고유 규칙 없음 | 행동마다 줄어드는 연료와 물약 배분 | `_finish_action, burn_potion` / 연료 상태 · H/O 선택 |
| [원문 business-analyst/F3](../last-lantern/reviews/business-analyst.md) | HP 회복만 있고 배분 대상이 없음 | 같은 물약으로 HP +10 또는 연료 +20 | `drink_potion, burn_potion` / 서로 배타적인 실제 상태 변화 |
| [원문 business-analyst/F4](../last-lantern/reviews/business-analyst.md) | 리뷰 없이 구현 조건 · 디자인 수용 기준 없음 | 리뷰 결정표 선행 · 자동/사람 수용 기준 분리 | `GDD §10` / 정책 40판 측정 · 외부 관찰은 미검증 |
| [원문 business-analyst/F5](../last-lantern/reviews/business-analyst.md) | 엔진 설치와 OS 글꼴 필요 · seed 목적 불명 | 프로젝트 + 설치 없는 웹판 · 동봉 글꼴 · seed 비교 | `tools/export-demos.ps1` / 두 웹 게임 키 입력 · 재현 안내 |

## 미해결 쟁점 6개의 결정

| 쟁점 | 선택과 이유 |
| --- | --- |
| 1. 난이도·회복 과잉 vs 양극화 | 회복 조정·배치 안전·각성 공개를 함께 적용. 자동 두 정책을 각각 20 seed에서 측정한다. 사람 첫 판 승률 40~80%는 외부 관찰 목표로 남긴다. |
| 2. 등불 표현 vs 자원 | 연료 카운터와 물약 배분을 채택. 시야·안개는 제외. 잔량·0일 때 패배·경고를 시작 화면과 고정 HUD에서 안내하고 서사도 유지한다. |
| 3. 마왕 처치 승리와 돌진 | 마왕 즉시 승리 + 왕좌 고정 + 회피 가능한 예고 공격을 묶는다. 해골 우회 돌진은 허용하되 경험치·HP·연료의 선택으로 둔다. |
| 4. 전멸 출구 유지 vs 부분 처치 | 수문장만 처치하면 개방한다. 그래서 수문장 처치 턴에 남은 적이 행동한다는 규칙이 실제 의미를 갖는다. |
| 5. 수정 순서 | 생성 검증·폴백 → 안전한 배치 → 각성 안내 → 연료·회복 조정 순으로 구현하고 한 변경 단위로 검증한다. 완성 게임에는 네 항목을 함께 제공한다. |
| 6. 로그·결과 소유권 | 목표·거부 이유는 고정 안내, 층 서사는 별도 줄, 로그는 7건과 연속 중복 억제. 결과의 서사 문구는 핵심, 세션 통계는 절삭 가능 항목이다. |

## 검증과 비교

- [v2 GDD](./gdd.txt): 구현 전 확정한 규칙·입력 표·제작 범위·수용 기준
- [실제 검증](./VALIDATION.md): 자동 정책과 사람 관찰을 구분한 결과
- [비교 데모](../../docs/demo/index.html): 주요 변화와 두 실제 Godot 웹 게임
- [원본 리뷰 종합](../last-lantern/reviews/SYNTHESIS.md): 선택 이전의 원문 쟁점
