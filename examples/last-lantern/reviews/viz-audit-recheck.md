# 시각화 감사(재감사) — `review-viz.html`

감사자: viz-reviewer
대상: 프로젝트 루트 `review-viz.html`(현재 최종본, 1235행)
대조 원본: `reviews/viz-data.json`(호스트 수정본), `reviews/viz-spec.md`, 여섯 리뷰 파일(`systems-designer.md`, `narrative-critic.md`, `player-psychologist.md`, `feasibility-lead.md`, `adversarial-qa.md`, `business-analyst.md`), `reviews/SYNTHESIS.md`
이전 감사 파일은 근거로 쓰지 않았다. 이전 항목 번호(E1~E5, U4, U7, U8)는 호스트 수정 목록을 대조할 때만 썼다.

---

## 0. 검증 범위와 방법

### 0.1 감사자가 직접 한 일
- HTML의 CSS·마크업·스크립트(1~352행, 355~1235행)를 끝까지 읽었다.
- `viz-data.json` 전체(2565행)를 읽고 여섯 리뷰 파일, `SYNTHESIS.md`와 항목별로 대조했다.
- 화면 수치(헤더, V2, V3, V4)는 스크립트의 집계 로직을 JSON 값에 적용해 손으로 다시 계산했다.

### 0.2 감사자가 직접 확인하지 못한 것
- **브라우저를 실행하지 않았다.** 필터, 정렬, 키보드 조작, 툴팁 위치, Esc 동작, 페이드업, 레이아웃, 글꼴 폴백, 줄바꿈이 실제로 어떻게 동작하는지는 소스를 보고 추론했을 뿐 눈으로 확인하지 않았다.
- **HTML에 들어 있는 데이터(353행)를 읽지 못했다.** 353행은 한 줄짜리 인라인 JSON이다. 이 줄이 너무 길어서 사용한 읽기 도구로 열 수 없었다. 그래서 인라인 데이터가 `reviews/viz-data.json`과 같은지는 감사자가 확인하지 못했다. 이 감사의 데이터 판단은 모두 "인라인 데이터 = `viz-data.json`"이라는 전제 위에 있다.
- **SHA-256 해시를 계산하지 않았다.** `local/t05/viz-browser-validation.json`의 `htmlSha256`(573166ae…87d6)이 현재 파일과 맞는지 확인하지 못했다.

### 0.3 호스트 브라우저 검증에서 보고된 사항(`local/t05/viz-browser-validation.json`, 감사자가 재현하지 않음)
- Edge 154.0.4258.37과 Firefox 155.0에서 실행했다고 보고되었다.
- 보고된 결과: `embeddedDataEqual: true`, 지적 30개, 원본과 관련 지적 구분, 필터·정렬·빈 상태, 키보드, 필터 포커스 유지, Esc 한 번으로 쟁점 닫기, 복합 ID 링크, 상위 이슈 드릴다운 5개, 쟁점 드릴다운 6개, 매트릭스 30칸, 지지 인용 분리, 반대 방향 보기, 차트 라운드 전환, 차트 키보드 필터, 포커스 툴팁, color-scheme, reduced motion, 오프라인 동작이 모두 pass. 콘솔 오류 0건, 외부 요청 0건. 1440px과 390px 폭에서 가로 넘침이 없고 `lang="ko"`, `charset="utf-8"`.
- 주의: 호스트 보고의 `matrixCounts`는 "주 충돌 대상과 연결 참조를 확인했다"고 적는다. 이것은 JSON의 `peer_reviewers` 값을 기준으로 확인한 결과로 보인다. 아래 A1은 그 `peer_reviewers` 값 자체가 원본 리뷰와 맞지 않는 경우다. 따라서 호스트 검증의 pass와 충돌하지 않는다.

### 0.4 호스트 수정 8건 확인 결과(감사자 소스 검토 기준)

| 항목 | 호스트 설명 | 감사자 확인 | 판정 |
|---|---|---|---|
| E1 | 3위의 systems-designer/F5를 related_findings로 분리 | JSON 3위 `source_findings`는 systems-designer/F1, player-psychologist/F1, business-analyst/F3 세 개이고, `related_findings`는 systems-designer/F5다. 카드에는 "관련 지적:" 줄로 따로 나온다(637행). V2 원본 칸(`cellA`)과 V5 "상위 이슈 연결"(`topIssuesOf`)은 `source_findings`만 쓴다. 그래서 systems-designer/F5는 2위의 원본으로만 연결된다. "지적한 리뷰어 3명"도 맞다. | 확인됨 |
| E2 | 충돌 상대를 peer_reviewers로만 집계, 지지 인용 분리, 축 설명 수정 | 코드는 수정되었다. `mkItem`이 충돌을 `peer_reviewers`로만 세고(429행), `v3ItemRow`가 나머지 동료 인용을 "근거로 인용한 동료 지적"으로 분리하며(905·910행), 축 설명도 바뀌었다(318행). 하지만 데이터에 남은 오류(A1)와 지적 단위 라벨 오류(A2)가 있다. | **부분 확인**(A1 MUST-FIX, A2 잔존) |
| E3 | severity_note 병기 원문 복원 | 1위는 "…나머지 원본 지적은 MAJOR · 주요다."이고, 3위는 "(systems-designer/F1이 1·2라운드 모두 유지). 같은 진단을 … MAJOR · 주요로 매겼다."이다. 둘 다 SYNTHESIS 원문과 같다. | 확인됨(표기 문제는 N4) |
| E4 | 쟁점 5·6 라벨 출처 표시, "갈림 수" 제거 | V2 범례에 "5·6은 추출자가 붙인 요약 라벨"이라고 적혀 있다(711행). "입장 N개로 갈림"은 `dispute_id <= 4`일 때만 표시된다(748행). 쟁점 1~4 라벨은 SYNTHESIS 원문 "…측" 표기와 모두 같다. | 확인됨(보강 권고는 N3) |
| E5 | SVG 구간에는 숫자만 표시 | 구간 글자가 `String(list.length)`뿐이다(997행). 라벨은 툴팁과 aria-label에만 있다. | 확인됨 |
| U4 | data-filter-key로 필터 포커스 유지 | 리뷰어 칩, 심각도 태그, 등급 기준, 라운드 변화 버튼에 키가 있고 `renderV5`가 다시 그린 뒤 포커스를 되돌린다(1062~1086, 1176~1184행). 정렬 `select`도 다시 포커스를 받는다. 다만 "필터 초기화" 버튼 두 곳에는 키가 없다(U4 참조). | 대부분 확인(잔여는 U4) |
| U7 | Esc 한 번으로 툴팁과 쟁점 패널 동시 닫기 | keydown 처리기가 `hideTip()`과 `closeDisputes(true)`를 연달아 부른다(559~563행). 부작용은 U3 참조. | 확인됨(부작용 U3) |
| U8 | 조사 오류 수정 | 스크립트의 조사 결합 문자열을 모두 확인했다. "…가 받은 참조", "…가 보낸 참조"는 여섯 리뷰어 이름 모두 받침이 없어 맞다. 다른 조사 오류는 찾지 못했다. 이전 오류 문구와 직접 비교하지는 않았다. | 확인됨 |

---

## 1. 정확성 오류

아래 표에서 "HTML"은 인라인 데이터가 `viz-data.json`과 같다는 전제에서 화면에 그려지는 내용이다(0.2 참조).

### A1. player-psychologist/2라운드 C1이 adversarial-qa와의 "충돌"로 집계됨 — **MUST-FIX(필수 수정)**
- **HTML/JSON:** `cross_exam_conflicts`의 player-psychologist C1은 `peer_reviewers: ["systems-designer", "adversarial-qa"]`다. 그 결과 V3 매트릭스의 플레이어 심리 전문가 → 적대적 QA 칸이 **충돌 2**로 나온다. 행 합계("보낸 참조")와 적대적 QA 열 합계("받은 참조")도 1씩 부풀려진다. 그 칸의 상세 패널은 C1을 충돌 항목으로 보여 주고 "주 대상의 지적: adversarial-qa/F3"이라고 적는다.
- **원본(`player-psychologist.md` C1):** C1의 논쟁 상대는 systems-designer/F1이다("systems-designer/F1이 권하는 방향, 즉 회복 공급만 줄이는 조정에는 반대한다"). adversarial-qa/F3은 반박 대상이 아니라 근거로 인용된다("adversarial-qa/F3은 이 전제가 seed에 따라 깨진다는 것을 보여 준다"). 수정 절에도 "adversarial-qa/F3의 분산 문제 때문에"라고 지지 근거로 쓴다. SYNTHESIS 쟁점 1도 player-psychologist/2라운드 C1을 systems-designer/F1 등급 논쟁에만 배치한다. `viz-spec.md` 검증 참고치도 이 항목의 adversarial-qa/F3을 "근거로만 스치듯 언급된 동료"로 보고 심리→QA 충돌을 1로 센다.
- **결과:** 페이지 스스로 밝힌 규칙("지지 근거로만 인용한 동료는 충돌 상대에 포함하지 않습니다")을 페이지가 어긴다. 동의를 충돌로 보여 주므로 입장을 잘못 귀속하는 오류다.
- **수정:** `viz-data.json` player-psychologist C1의 `peer_reviewers`를 `["systems-designer"]`로 고치고 HTML 인라인 데이터(353행)에 다시 넣는다. 고친 뒤 기대값은 다음과 같다. 심리→QA 충돌 1·연결 2, 심리 행 보낸 참조 −1, QA 열 받은 참조 −1. `aggregate_counts.cross_exam_conflicts`(30)는 항목 수이므로 바뀌지 않는다.
- 나머지 29개 충돌 항목의 `peer_reviewers`는 원본 리뷰의 논쟁 상대와 대조했고 문제를 찾지 못했다.

### A2. V3 상세의 "주 대상의 지적:" 라벨이 같은 리뷰어의 지지 인용까지 주 대상으로 표시함 — SHOULD-FIX(권장 수정)
지지 인용 분리가 리뷰어 단위로만 이루어져서 생기는 문제다. 논쟁 상대 리뷰어의 지적이면 근거로 인용한 것도 "주 대상의 지적"으로 표시된다(`v3ItemRow`, 904·909행).
- feasibility-lead C1 → 시스템 디자이너 칸: "주 대상의 지적: systems-designer/F1, systems-designer/F4"로 나온다. 원본에서 systems-designer/F4는 "마왕과 해골이 동시에 붙는 경우(systems-designer/F4의 턴당 14 피해)"라는 근거다.
- adversarial-qa C1 → 시스템 디자이너 칸: systems-designer/F4가 "주 대상"으로 나온다. 원본에서는 "systems-designer/F4가 직접 계산했듯이"라는 근거다.
- business-analyst C5 → 기술 실현성 리드 칸: "주 대상의 지적: feasibility-lead/F1"로 나온다. 원본 C5가 반박하는 대상은 feasibility-lead의 **1라운드 총평**("범위는 작다")이다. feasibility-lead/F1은 "모두 같은 구멍을 지적했다"는 근거로 인용되었다. `extraction_notes`도 이 항목이 지적 ID가 아닌 총평을 대상으로 한다고 적는다. 이 항목에는 "지적 ID가 아닌 총평을 대상으로 한 항목"이 나와야 한다.
- 수정 방향: 라벨을 중립적인 "이 동료의 참조 지적"으로 바꾼다. 또는 데이터에 지적 단위의 주 대상 필드를 추가한다.

### A3. 쟁점의 "관련 지적"과 V1의 "원본 지적을 공유하는 미해결 쟁점" 링크가 추출자 추정에 기반함 — SHOULD-FIX(권장 수정)
- **HTML:** 쟁점 패널 아래 "관련 지적:"(809행)과 V1 3단계의 쟁점 이동 버튼(699~700행)은 `synthesis_disputes[].related_findings`로 만들어진다. 그래서 1위 → 쟁점 3·5, 2위 → 쟁점 6, 5위 → 쟁점 4·5 링크가 생긴다.
- **원본(`SYNTHESIS.md` 2장):** 쟁점 3·5·6 본문에는 지적 ID가 거의 없다. 쟁점 3의 narrative-critic/F3, player-psychologist/F2, systems-designer/F3·F4, 쟁점 5의 네 지적, 쟁점 6의 narrative-critic/F2와 player-psychologist/F4, 쟁점 2의 business-analyst/F2는 추출자가 연결한 것이다. SYNTHESIS가 직접 잇는 이슈-쟁점 관계는 3위 → 쟁점 1("미해결 쟁점 1로 넘긴다")과 4위 → 쟁점 3("미해결 쟁점 3에서 다툼")뿐이다.
- 연결이 틀렸다고 보지는 않는다. 다만 SYNTHESIS 원문처럼 보이는 위치에 출처 표시 없이 놓여 있다. "추출자가 연결한 관련 지적"이라고 표시하거나 원문 연결만 남긴다.

### A4. "본인 수정 표기:" 라벨 아래 원문이 아닌 요약문이 나옴 — SHOULD-FIX(권장 수정)
- **HTML:** V4 변경 목록(1022행)과 V5 등급 이력(1126행)은 `revision_note`를 "본인 수정 표기: …"로 보여 준다.
- **원본:** 일부는 리뷰어 원문이 아니라 추출자 요약이다. 예를 들어 player-psychologist/F5의 "하향(정체성이 플레이어용으로 결정되면 다시 MAJOR)"은 원문 "MAJOR · 주요에서 MINOR · 경미로 하향."과 마지막 문장을 합쳐 줄인 것이다. player-psychologist/F1의 "유지(단서 추가)", narrative-critic/F2의 "유지(확신도 상승)"도 원문 표기가 아니다. systems-designer/F5는 원문 "…business-analyst/F4의 `BLOCKING · 치명`으로 넘긴다"에서 등급 병기가 빠졌다.
- 내용이 왜곡되지는 않았다. 하지만 "본인 … 표기"라는 라벨은 원문을 그대로 옮겼다는 뜻으로 읽힌다. 라벨을 "수정 요약"으로 바꾼다. V5 행의 "본인 표기 STRENGTHENED · 강화"도 같다. 이 표시는 원문 "근거 강화", "강화", "근거는 강화되었다"를 정규화한 값이며, 원문이 이 병기를 직접 쓴 것은 business-analyst뿐이다. 이 점은 `extraction_notes`에만 적혀 있다.

### 대조 결과 일치한 항목(오류 없음)
- 지적 수: 30개(리뷰어당 5개). 누락, 중복, 지어낸 지적이 없다. 30개 제목, 1라운드 심각도, 최종 심각도를 여섯 리뷰 파일과 모두 대조했다.
- 심각도 변경 4건: feasibility-lead/F1 MAJOR→BLOCKING, adversarial-qa/F5 MINOR→MAJOR, player-psychologist/F5 MAJOR→MINOR, adversarial-qa/F1 MAJOR→MINOR. 원본 수정 절과 같다. 철회는 0건이다.
- 헤더: 전체 지적 30, BLOCKING · 치명(최종) 3, "1라운드 2 → 2라운드 3", 미해결 쟁점 6, 한 줄 판정과 가장 중요한 변경이 SYNTHESIS 4장과 글자 그대로 같다. 리뷰 날짜는 "리뷰 파일에 기록되지 않음"으로 표시되며, 이는 원본과 맞다.
- V4 분포: 1라운드 2/21/7, 최종 3/19/8. 리뷰어별 최종 분포는 시스템 1/3/1, 내러티브 0/3/2, 심리 0/4/1, 실현성 1/2/2, QA 0/4/1, 비즈니스 1/3/1이다.
- 상위 5개 이슈의 제목, 심각도, 교차 검토 결과(STRENGTHENED 4, WEAKENED 1), 단서 문구, 원본 지적 ID, 요지가 SYNTHESIS 1장과 같다. 3위의 BLOCKING · 치명 + WEAKENED · 약화 조합에는 단서 문구가 붙어 있다.
- 쟁점 1~6의 입장, 리뷰어 귀속, 근거 항목, 상위로 올릴 결정이 SYNTHESIS 2장과 같다. 쟁점 3에서 systems-designer와 narrative-critic이 양쪽에 모두 나오는 것도 원문 그대로다.
- 리뷰어 식별자와 지적 ID 조합(`reviewer/F#`)이 모든 링크, 칸, 툴팁, 행 ID(`f-player-psychologist--F1` 형식)에서 구분된다. 같은 F번호가 다른 리뷰어와 섞이는 경우를 찾지 못했다.
- 화면의 심각도·결과 표시는 모두 `BLOCKING · 치명`, `MAJOR · 주요`, `MINOR · 경미`, `SURVIVED · 유지`, `STRENGTHENED · 강화`, `WEAKENED · 약화`이고, JSON 값은 영문을 유지한다. 심각도 변경은 "등급 상향/하향/유지"라는 별도 문구를 쓴다.
- 연결(L) 26개의 집계 기준(참조 지적 소유자)을 원본 참조와 대조했다. 명세 참고치와 다른 칸은 없었다.

---

## 2. 사용성 문제

### U1. 라이트 모드에서 명세와 다른 밝은 팔레트로 바뀜 — SHOULD-FIX(권장 수정)
`@media (prefers-color-scheme: light)`(20~27행)와 `<meta name="color-scheme" content="dark light">`가 배경을 #F4F3F0으로, 심각도 태그 글자를 검정으로 바꾼다. `viz-spec.md` 1.3과 4라운드 보드는 어두운 팔레트(#16181D 등) 하나만 정했다. Windows 11의 기본값은 라이트 모드이므로 강의실 노트북에서는 명세와 다른 화면이 나올 가능성이 높다. 호스트 보고의 `colorScheme: pass`는 두 모드가 동작한다는 뜻이지 명세와 맞는다는 뜻은 아니다. 어두운 팔레트로 고정할 것을 권한다.

### U2. 프로젝터 기준에 못 미치는 작은 글자 — SHOULD-FIX(권장 수정)
명세 기준은 지적 텍스트 18px 이상, 셀 라벨 16px 이상, 툴팁 16px 이상이다. 소스에서 확인한 크기는 다음과 같다.
- V2 칸의 심각도 라벨 `.mx-sevline` **12px**(151행). 뒷자리에서는 읽을 수 없다.
- V3 "충돌만/연결만" 모드의 칸 라벨 `.lbl` 13px, 심각도 태그 영문 13px, 필터 개수 13px.
- 근거 구절 인용 `blockquote` 17px, 교차 검토 본문 16px. 둘 다 지적 내용인데 18px보다 작다.
- 툴팁 보조 줄 15px, 지적 ID 줄 14px. V4 척도 안내 14px. V2 블록 A 행 제목 16px.
실제 렌더링 크기는 브라우저에서 확인하지 못했다.

### U3. Esc가 멀리 떨어진 쟁점 행으로 포커스를 옮김 — SHOULD-FIX(권장 수정)
Esc 처리기는 쟁점 패널이 열려 있으면 항상 `closeDisputes(true)`를 부른다. 이 함수는 `preventScroll`로 V2 행 제목에 포커스를 준다(819행). 쟁점 패널을 연 채 V5로 내려가 툴팁을 닫으려고 Esc를 누르면, 화면은 V5에 머물고 포커스만 화면 밖 V2로 사라진다. 다음 Tab은 V2에서 이어진다. 포커스가 패널 안에 있을 때만 다시 포커스를 주거나, 툴팁이 열려 있을 때는 툴팁만 닫도록 권한다. 브라우저에서 재현하지는 않았다.

### U4. "필터 초기화" 버튼을 누르면 포커스가 사라짐 — SHOULD-FIX(권장 수정)
필터 막대와 빈 상태의 "필터 초기화" 버튼(1094·1171행)에는 `data-filter-key`가 없다. `renderV5`가 막대와 목록을 다시 그리면 포커스를 되돌릴 대상이 없어 포커스가 `body`로 간다. U4 수정이 이 두 버튼에는 적용되지 않았다.

### U5. V3·V4를 조작한 뒤 포커스가 사라짐 — SHOULD-FIX(권장 수정)
V3의 칸, 행·열 제목, 표시 전환 버튼, V4의 등급 기준 버튼은 누를 때마다 `replaceChildren()`으로 전체를 다시 그린다(842·848·951행). 그래서 방금 누른 요소가 DOM에서 사라지고 포커스가 풀린다. 상세 패널은 `aria-live`라서 읽히지만, 키보드 사용자는 다음 칸으로 가려면 다시 찾아 들어가야 한다. V5에 적용한 키 기반 포커스 복원을 여기에도 적용할 것을 권한다. 다음 Tab이 실제로 어디로 가는지는 브라우저마다 다를 수 있고, 감사자는 확인하지 못했다.

### N1. V5 고정 필터 막대가 높음 — NICE-TO-FIX(선택 수정)
세 줄 필터에 요약 줄까지 붙은 sticky 막대가 1080p 화면에서 세로 공간을 크게 차지한다(`scroll-margin-top: 260px`로 보아 약 250px로 추정). 스크롤할 때는 접히게 하거나 한 줄로 줄이는 방안이 있다.

### N2. V2 행 제목이 SYNTHESIS 소제목 전문이라 행이 높아짐 — NICE-TO-FIX(선택 수정)
블록 A와 B의 행 제목은 소제목 전문이다. 300px 열에서 3~4줄로 늘어나고, 쟁점 5·6의 긴 입장 라벨도 좁은 칸에서 여러 줄로 쌓인다. 명세의 짧은 제목(두 줄 이내)을 쓰면 격자를 한눈에 보기 쉬워진다. 전문은 툴팁이나 패널에 두면 된다.

### N3. 쟁점 5·6의 라벨 출처가 범례에만 적혀 있음 — NICE-TO-FIX(선택 수정)
출처 표시는 격자 위 범례 한 줄에만 있다. 쟁점 5·6의 패널 열 제목과 칸 툴팁에서는 원문 라벨(쟁점 1~4)과 구분되지 않는다. 행이나 패널에 "요약 라벨" 표시를 붙일 것을 권한다. 또 "갈림 수" 조건이 `dispute_id <= 4`로 고정되어 있어 데이터가 바뀌면 틀어진다. 데이터 필드(예: 라벨 출처)로 판정하는 편이 안전하다.

### N4. 3위 심각도 단서가 괄호로 시작함 — NICE-TO-FIX(선택 수정)
"심각도 단서: (systems-designer/F1이 1·2라운드 모두 유지). 같은 진단을…"처럼 문장이 여는 괄호로 시작해 어색하다. 원문 충실도는 맞으므로 표시할 때만 괄호를 빼거나 "BLOCKING · 치명"을 앞에 붙이는 정도로 충분하다.

### N5. 동작 없는 포커스 정지점과 개발용 문구 — NICE-TO-FIX(선택 수정)
V2 열 머리글 여섯 개는 `tabindex="0"`인 `span`이다. 툴팁과 열 강조만 있고 클릭 동작이 없다. 키보드 탐색에서 동작 없는 정지점이 여섯 개 생긴다. 푸터의 "데이터 검증: 화면의 집계가 viz-data.json의 aggregate_counts와 모두 일치합니다."는 발표 청중에게는 개발용 문구다.

### 문제없이 확인한 사용성 요소(소스 기준)
`<html lang="ko">`, `<meta charset="utf-8">`을 지정했다. 본문 `word-break: keep-all`이 적용되어 있다. 본문·디스플레이·고정폭 스택 모두에 Malgun Gothic, Apple SD Gothic Neo, Noto Sans KR 폴백이 있다. 한글에는 대문자 변환과 음수 자간이 없다. 태그는 `nowrap`이다. 최대 폭은 1100px이고 섹션 간격은 80px이다. 모서리 반경은 4px 이하이고 그림자와 그라디언트는 없다. 색은 심각도에만 쓰였다. 순위 숫자는 90px에 불투명도 0.3이다. 상위 5개 진술은 28px이다. 페이드업은 한 번뿐이며 reduced motion에서는 꺼진다. 모든 클릭 요소가 `button`이거나 `role="button"`이며 `tabindex`를 가진 SVG `g`다. 펼침 요소에는 `aria-expanded`가 있다. 3위 카드의 등급-결과 긴장에는 단서가 붙어 있다. V4 전체 행의 척도 안내가 있다. 빈 상태 문구는 명세와 같다.

---

## 3. 판정

- **정확성 오류 4건:** MUST-FIX 1건(A1), SHOULD-FIX 3건(A2, A3, A4)
- **사용성 문제 10건:** SHOULD-FIX 5건(U1~U5), NICE-TO-FIX 5건(N1~N5)
- **남은 MUST-FIX: 1건.** A1이다. `reviews/viz-data.json`의 `cross_exam_conflicts` 중 player-psychologist C1의 `peer_reviewers`에 adversarial-qa가 들어 있다. 그 결과 V3 매트릭스의 심리 → QA 칸과 두 합계가 부풀려지고, 동의가 충돌로 표시된다. HTML 353행의 인라인 데이터도 함께 고쳐야 한다.
- **권고(SHOULD-FIX + NICE-TO-FIX): 13건.**

**최종 판정: 한 번 더 손봐야 한다.** 호스트 수정 8건 중 7건은 소스에서 확인했다. E2는 코드 수정은 맞지만 데이터에 오류 하나가 남아 있다. 이 오류가 바로 E2가 고치려던 "지지 인용을 충돌로 세는" 유형이다. 페이지는 스스로 밝힌 집계 규칙을 어기는 숫자를 보여 준다. 고치는 데는 JSON 값 하나와 재임베드만 있으면 된다. A1을 고치고 인라인 데이터가 `viz-data.json`과 같은지 다시 확인하면 그 상태로 보여 줄 수 있다. 발표 전에 U1(라이트 모드 팔레트)과 U2(12~15px 글자)도 함께 고칠 것을 강하게 권한다.
