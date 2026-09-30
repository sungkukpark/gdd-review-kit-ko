# 시각화 감사 — `review-viz.html`

감사자: viz-reviewer
대상: 프로젝트 루트 `review-viz.html`(1232행)
대조 원본: `reviews/viz-data.json`, `reviews/viz-spec.md`, 여섯 리뷰 파일(`systems-designer.md`, `narrative-critic.md`, `player-psychologist.md`, `feasibility-lead.md`, `adversarial-qa.md`, `business-analyst.md`), `reviews/SYNTHESIS.md`
이전 감사 결과(`viz-audit.md`)는 원본으로 쓰지 않았다.

---

## 0. 검증 범위와 방법

### 0.1 감사자가 소스를 검토해 확인한 사항
- 감사자는 브라우저를 실행하지 않았다. 필터·정렬·키보드 조작·툴팁 위치·레이아웃·반응형 동작은 **HTML/CSS/JS 소스를 읽고 추론한 것**이다. 실제 렌더링으로 확인한 것이 아니다.
- `viz-data.json`의 30개 지적, 충돌 30개, 연결 26개, 수정 30건, 상위 이슈 5개, 쟁점 6개를 여섯 리뷰 파일·`SYNTHESIS.md`와 한 줄씩 대조했다. 지적 제목, 1라운드 심각도, 2라운드 최종 심각도, 리뷰어 귀속, 항목 ID는 모두 원문과 일치한다.
- 집계도 원문에서 직접 다시 셌다. 1라운드는 BLOCKING 2 / MAJOR 21 / MINOR 7이다. 최종은 BLOCKING 3 / MAJOR 19 / MINOR 8이다. 등급 변경은 상향 2건(feasibility-lead/F1, adversarial-qa/F5)과 하향 2건(adversarial-qa/F1, player-psychologist/F5)이고, 철회는 없다. 화면의 헤더·V4·V5는 이 값을 JSON에서 계산해 보여 주므로 원문과 일치한다.
- 지적은 모두 `finding_key = "<reviewer>/<Fn>"`로 식별한다(`FMAP`, `cssId`, `data-fid`). 여섯 리뷰어의 F1~F5가 서로 충돌하지 않는다. 화면에 보이는 지적 ID도 항상 `리뷰어/F번호` 전체 형식이다.
- JSON 내부 값은 영문(`BLOCKING`/`MAJOR`/`MINOR`, `SURVIVED`/`STRENGTHENED`/`WEAKENED`)을 그대로 유지한다. 화면의 태그·필터·범례·툴팁은 `SEV_LABEL`/`OUT_LABEL`에서 `BLOCKING · 치명` 등의 병기 표시를 만든다. 예외는 아래 E3·E5에 적었다.
- **호스트의 보완 3건 확인 결과**
  1. `const DATA` 복원: 354행 한 줄에 DATA가 들어 있다(353행 주석 "reviews/viz-data.json 전체를 값 변경 없이 포함한다."). 이 줄은 약 8만 4천 토큰이라 감사 도구로는 읽을 수 없었다. 그래서 **JSON과 같은지 감사자가 직접 확인하지는 못했다.** 대신 렌더링 코드가 읽는 필드(`description`, `evidence`, `missing`, `impact`, `recommendation`, `cross_exam_revisions`, `synthesis_verdict`, `aggregate_counts` 등)가 모두 JSON에 있고 이름도 같다는 점을 확인했다. 푸터의 `aggregate_counts` 대조 코드(459~473행)는 존재한다. 다만 이 코드는 JSON 안의 두 값끼리만 비교할 뿐, 원본 리뷰 파일과 비교하지는 않는다.
  2. `.mx-scroll{position:relative;overflow-x:auto}`: 134행에서 확인했다. 매트릭스 안의 `.vh`(position:absolute) 요소가 스크롤 컨테이너를 기준으로 잘리는 구조다.
  3. 차트 최소 폭 처리: `#v4-chart{position:relative;overflow-x:auto}`와 `.v4 svg{min-width:720px}`를 202~203행에서 확인했다. 1000px 이하에서는 `.v4`가 한 컬럼이 된다. 스크롤 컨테이너인 그리드 아이템의 자동 최소 크기가 0이므로, 이론상 페이지 전체가 가로로 넘치지 않는다.

### 0.2 호스트 브라우저 검증에서 보고된 사항 (`local/t05/viz-browser-validation.json`, 감사자가 재현하지 않음)
- Edge 154.0.4258.37과 Firefox 155.0 모두 다음을 보고했다. `embeddedDataEqual: true`, 지적 30개, 필터링·정렬·빈 상태·키보드·복합 ID 링크·역방향 보기·차트 라운드 전환·차트 키보드 필터·포커스 툴팁·색 구성 모두 pass, 상위 이슈 드릴다운 5개, 쟁점 드릴다운 6개, 매트릭스 셀 30개, `reducedMotion`·`offline` true, 오류와 외부 요청 없음. 1440px과 390px 폭에서 `scrollWidth`는 뷰포트 폭과 같다.
- 보고서에 `htmlSha256`이 있다. 감사자는 해시를 계산할 수 없었으므로 이 검증이 현재 파일에 대해 실행된 것인지 확인하지 못했다.
- `matrixCounts: "source references verified"`는 셀 숫자가 참조 ID와 맞는다는 뜻이다. 아래 E2의 의미 문제(참조가 곧 충돌인가)는 이 검증 항목이 다루지 않는다.

---

## 1. 정확성 오류

모두 5건이다. 앞의 두 건은 MUST-FIX(필수 수정)이고 나머지 세 건은 권고(SHOULD-FIX, 권장 수정)다.

### E1. 상위 이슈 3위의 "원본 지적"에 systems-designer/F5가 섞여 있다 — MUST-FIX
- **HTML:** V1 3위 카드의 "원본 지적:" 줄에 `systems-designer/F1 · player-psychologist/F1 · business-analyst/F3 · systems-designer/F5`가 나란히 표시된다. 펼침 1단계 "원본 지적 (1라운드)"에도 F5 행이 있다. V2 블록 A의 3위 행 시스템 칸에는 "F1 · F5"가 보인다. V5의 systems-designer/F5 펼침에는 "상위 이슈 3위의 원본 지적" 버튼이 있다. V1 3위의 2라운드 단계에도 systems-designer/F5를 참조한 항목(adversarial-qa L3, feasibility-lead L1, business-analyst L3)이 "동료가 이 이슈의 원본 지적을 참조한 항목"으로 들어간다.
- **원본(SYNTHESIS.md 3위):** "지적한 리뷰어: systems-designer/F1, player-psychologist/F1, business-analyst/F3 **(관련: systems-designer/F5)**". F5는 원본이 아니라 관련 지적이다. systems-designer/F5가 원본 지적인 곳은 2위("systems-designer/F5(셋째 항목)")다.
- **원인:** `viz-data.json`의 `synthesis_top_issues[2].source_findings`가 관련 지적까지 원본 배열에 넣었다. HTML은 이 배열을 그대로 쓴다.
- **수정:** 관련 지적을 `related_findings` 같은 별도 필드로 분리한다. 화면에서는 "관련: systems-designer/F5"로 구분해 보여 준다. V2 블록 A 칸과 V5의 "원본 지적" 링크에서는 빼야 한다.

### E2. V3 교차 검토 매트릭스의 "충돌"이 실제 논쟁 상대가 아닌 리뷰어에게까지 매겨진다 — MUST-FIX
- **HTML:** 섹션 설명은 "2라운드에서 누가 누구의 지적과 논쟁했고(충돌)…"라고 쓴다. 그런데 `mkItem`(427~437행)은 충돌 항목의 상대를 `peer_reviewers`와 `referenced_findings`에 나온 모든 지적 소유자의 합집합으로 잡는다. 그 결과 **동의하거나 근거로 인용하려고 언급한 동료**도 "충돌" 칸에 1로 올라간다.
- **원본과 대비한 예:**
  - adversarial-qa/2라운드 C4의 반박 대상은 player-psychologist/F2 하나다. systems-designer/F4, narrative-critic/F3, feasibility-lead/F1은 "다섯 명이 독립적으로 짚은 구절"이라는 **지지 근거**로 인용되었다. 그런데 화면에는 QA → 시스템, QA → 내러티브, QA → 실현성에 각각 "충돌 1"로 잡힌다.
  - business-analyst/2라운드 C5의 대상은 feasibility-lead 총평이다. adversarial-qa/F2와 systems-designer/F4는 "모두 같은 구멍을 지적했다"는 지지 근거인데, 비즈니스 → QA와 비즈니스 → 시스템의 충돌로 집계된다.
  - feasibility-lead/2라운드 C4는 narrative-critic/F3과 player-psychologist/F2의 제안을 "비용이 가장 낮은 해법"이라며 **지지**한다. 그런데 실현성 → 내러티브와 실현성 → 심리에 충돌로 잡힌다.
  - 같은 유형: feasibility-lead C1(→QA), C5(→QA, →심리), adversarial-qa C3(→시스템), C5(→실현성), business-analyst C1(→시스템), C2(→실현성).
- **규모:** 합치면 대상이 아닌 방향에 충돌 14건이 더 매겨진다. 시스템 디자이너가 받은 충돌은 화면에서 12로 나온다. `viz-spec.md`가 주 참조 대상 기준으로 원문에서 센 값은 8이다.
- **수정:** 충돌 항목은 JSON의 `peer_reviewers`만 상대로 센다. 근거로 인용된 동료는 상세 패널에 "근거로 인용"으로 따로 보여 준다. 다른 방법으로, 현재 집계를 유지하려면 섹션 설명과 범례를 "충돌 항목에서 이 리뷰어의 지적을 참조한 수"로 고쳐 '논쟁 상대'라는 주장을 빼야 한다. 앞의 방법을 권한다.

### E3. 상위 이슈 심각도 단서 문구에 영문 값만 노출된다 — SHOULD-FIX
- **HTML:** 1위 "심각도 단서: feasibility-lead/F1을 2라운드에서 상향한 등급이다. 나머지 원본 지적은 **MAJOR**다." 3위 "…같은 진단을 player-psychologist/F1과 business-analyst/F3은 **MAJOR**로 매겼다. 등급은 미해결 쟁점 1에서 다툼."
- **원본(SYNTHESIS.md):** "나머지 원본 지적은 **MAJOR · 주요**다." / "…**MAJOR · 주요**로 매겼다." 추출 과정에서 병기 표시가 빠졌다. 그 결과 화면 문구가 원문과도, 표시 규칙과도 다르다. 3위의 "등급은 미해결 쟁점 1에서 다툼"은 SYNTHESIS 요지의 "등급 판정은 미해결 쟁점 1로 넘긴다"를 줄인 것이어서 추적은 된다.
- **수정:** JSON의 `severity_note`를 원문 문구 그대로 되돌린다.

### E4. V2 쟁점 블록의 범례가 입장 라벨의 출처를 사실과 다르게 적는다 — SHOULD-FIX
- **HTML:** 범례는 "아래 블록: 칸의 문구는 **SYNTHESIS에 적힌** 그 리뷰어의 입장"이라고 한다. 쟁점 6의 행 제목에는 "입장 4개로 갈림"이 붙는다.
- **원본:** 쟁점 5·6의 라벨("턴 압박과 각성 표시 동시 채택", "폴백 규칙 먼저", "결과 창 통계는 절삭 후보", "중복 알림 억제 규칙" 등)은 SYNTHESIS에 없다. `viz-data.json` `extraction_notes`가 밝힌 대로 추출자가 붙인 요약 라벨이다(논지 본문은 원문 그대로다). 쟁점 6의 네 "입장" 가운데 두 개는 같은 feasibility-lead의 것이다. "중복 알림 억제 규칙"(feasibility-lead/2라운드 L4)은 SYNTHESIS에서 대립하는 편으로 서술되지 않았다. "4개로 갈림"은 원문보다 대립을 크게 보이게 한다.
- **수정:** 범례를 "쟁점 1~4는 SYNTHESIS 원문 표기, 5·6은 요약 라벨"로 고친다. "입장 N개로 갈림"은 서로 다른 리뷰어 수를 기준으로 세거나, 쟁점 5·6에는 붙이지 않는다.

### E5. V4 막대 안의 심각도 라벨이 한국어만 쓴다 — SHOULD-FIX
- **HTML:** 막대 구간 텍스트가 `SEV_KO[s] + ' ' + n`(994행)이어서 "주요 3", "치명 1", "경미 2"처럼 한국어만 표시된다. 폭이 84px 미만이면 숫자만 표시된다.
- **기준:** CLAUDE.md 언어 규칙과 `viz-spec.md` 1.1절("영문만 또는 한글만 쓰지 않는다")은 `MAJOR · 주요` 병기를 요구한다. 명세 6장은 구간 안에 개수만 넣으라고 했다.
- **수정:** 구간 안에는 숫자만 둔다(색과 위쪽 범례 태그로 등급을 식별). 병기 라벨은 툴팁과 범례에만 쓴다.

### 오류가 없음을 확인한 항목
- 헤더 수치: 전체 지적 30, BLOCKING · 치명 (최종) 3, "1라운드 2 → 2라운드 3", 미해결 쟁점 6.
- 한 줄 판정과 "가장 중요한 단 하나의 변경"은 SYNTHESIS 4장 문장과 같다. 리뷰 날짜는 원문에 없으므로 "리뷰 파일에 기록되지 않음"으로 표시한 것이 맞다.
- 상위 이슈 1~5위의 순위, 제목, 심각도, 교차 검토 결과(STRENGTHENED · 강화 ×4, 3위 WEAKENED · 약화)와 3위 단서 문구. 1위 "지적한 리뷰어 5명"은 SYNTHESIS의 "다섯 명"과 같다.
- 쟁점 1~6의 제목, 양측 리뷰어, 논지, "상위로 올릴 결정"이 SYNTHESIS 2장과 같다. 쟁점 3에서 systems-designer와 narrative-critic이 찬성 측과 반대·보완 측에 모두 나오는 것도 원문 그대로다.
- V4의 등급 변경 4건 목록과 "나머지 26건… 철회된 지적은 없습니다."
- 30개 지적의 문제·근거·누락·영향·권고 본문은 원문과 실질적으로 같다(표 기호와 굵게 표시만 제거). 누락, 중복, 지어낸 지적은 발견하지 못했다.

---

## 2. 사용성 문제

모두 11건이다. MUST-FIX는 없고 SHOULD-FIX 4건, NICE-TO-FIX 7건이다. 브라우저로 확인하지 않은 항목은 "(소스 추론)"으로 표시했다.

### U1. V1 펼침의 "교차 검토 논쟁"이 지나치게 많은 항목을 담고, 입장별로 나뉘지 않는다 — SHOULD-FIX
명세는 "지지·강화 / 반박·하향 요구 / 보완·조건" 세 묶음을 요구했다. 구현은 "동료가 이 이슈의 원본 지적을 참조한 항목"이라는 기계적 필터를 쓴다(663~668행). 1위처럼 원본이 6개인 이슈에는 약 16개 항목이 들어간다. 이 중에는 이슈와 관계없는 논쟁도 있다. 예를 들어 adversarial-qa C1은 systems-designer/F1의 등급 논쟁인데, systems-designer/F4를 인용했다는 이유만으로 1위에 들어온다. 발표자가 "이 이슈를 두고 누가 어떻게 다퉜는가"를 한눈에 보여 주기 어렵다. 입장 구분 데이터가 없다면 적어도 SYNTHESIS 요지에 이름이 나온 항목만 추리거나, 해당 이슈의 원본 지적을 **주 대상**(peer_reviewers)으로 삼은 항목만 우선 보여 준다.

### U2. 프로젝터용 최소 글자 크기를 지키지 않는 본문이 있다 — SHOULD-FIX
명세는 "지적 텍스트 최소 18px"를 요구한다. 이보다 작은 본문은 다음과 같다. 쟁점 패널의 논지 본문 `.dp-col p` 17px, V5 근거 인용 `blockquote` 17px, V5 동료 항목 제목·본문 `.mitem` 16px, V1·V3의 2라운드 본문 `.xitem details p` 16px, 수정 이유 `.chg details p` 16px, V5 지적 ID `.c-id` 15px. 심각도 태그도 14px(영문 토큰 13px)라 교실 뒷자리에서 읽기 어렵다(소스 추론). 논지·인용·항목 본문은 18px로 올리고 태그는 16px 안팎으로 키운다.

### U3. OS가 라이트 모드이면 팔레트가 자동으로 바뀐다 — SHOULD-FIX
`prefers-color-scheme: light`에서 배경이 #F4F3F0으로 바뀌고, 심각도 태그의 글자색도 심각도 색이 아니라 #16181D가 된다(20~27행). 명세는 차콜 팔레트를 "정확히" 따르라고 했다. 발표용 노트북이 라이트 모드라면 명세와 다른 화면이 프로젝터에 나간다. 호스트 검증의 `colorScheme: pass`는 두 모드가 모두 렌더링된다는 뜻으로 보인다. 의도된 확장이라면 명세에 적고, 아니라면 다크 고정으로 되돌린다.

### U4. V5 필터에서 "전체"를 누르면 키보드 포커스가 다른 버튼으로 튄다 — SHOULD-FIX
`renderV5`는 다시 렌더링한 뒤 포커스를 `textContent`가 같은 첫 버튼으로 되돌린다(1178~1181행). "전체"는 리뷰어 줄과 라운드 변화 줄에 모두 있다. 라운드 변화의 "전체"를 누르면 포커스가 리뷰어의 "전체" 칩으로 옮겨 간다(소스 추론). 키보드 사용자는 위치를 잃는다. 버튼에 `data-key`를 붙여 그 값으로 다시 찾는다.

### U5. 좁은 화면에서 고정(sticky) 필터 막대가 화면을 많이 가린다 — NICE-TO-FIX
필터 막대는 세 줄에 요약 줄까지 있다. 390px 폭에서는 리뷰어 칩 7개, 태그 3개, 세그먼트가 여러 줄로 줄바꿈되어 막대 높이가 뷰포트의 절반 가까이 될 수 있다. 지적 행의 `scroll-margin-top`은 260px로 고정되어 있어 막대가 더 높으면 이동한 행이 막대 뒤에 가려진다(소스 추론). 프로젝터 데스크톱이 주 대상이라 등급을 낮췄다. 좁은 폭에서는 sticky를 끄거나 필터를 접을 수 있게 한다.

### U6. V2 열 머리글이 포커스는 받지만 아무 동작도 하지 않는다 — NICE-TO-FIX
`.mx-colhead`는 `tabindex="0"`인 `span`이다. 포커스와 호버 때 열을 강조하고 툴팁을 띄우지만, Enter나 클릭에는 반응하지 않는다(714~717행). 바로 아래 V3의 열 머리글은 누를 수 있는 버튼이어서 사용자는 같은 동작을 기대한다. 누르면 V5를 그 리뷰어로 거르게 하거나, 반대로 탭 순서에서 빼고 호버 강조만 남긴다.

### U7. 쟁점 패널을 닫으려면 Esc를 두 번 눌러야 할 수 있다 — NICE-TO-FIX
쟁점 칸 버튼을 누르면 포커스가 그 버튼에 남고 포커스 툴팁이 뜬다. Esc 처리기는 툴팁이 열려 있으면 툴팁만 닫고 끝난다(559~563행). 그래서 첫 Esc는 툴팁만 닫고 두 번째 Esc에서야 패널이 닫힌다(소스 추론). 설명 문구는 "Esc로 닫습니다"라서 첫 시도가 실패한 것처럼 보인다.

### U8. 조사 오류 "쟁점 3로 이동", "쟁점 6로 이동" — NICE-TO-FIX
V1 최종 상태 단계의 버튼 문구가 `'쟁점 ' + id + '로 이동'`으로 고정되어 있다(699행). 3과 6 뒤에는 "으로"가 맞다. 번호 앞에 "쟁점 3번으로"처럼 쓰면 조사 문제를 피할 수 있다.

### U9. V5의 "본인 표기 STRENGTHENED · 강화" 태그가 종합 결과와 혼동될 수 있다 — NICE-TO-FIX
V5 행 오른쪽에 리뷰어 자기 수정 절에서 뽑은 `self_reported_outcome` 태그가 교차 검토 결과 태그와 같은 모양으로 붙는다. 이것은 SYNTHESIS의 판정이 아니다. "근거 강화", "확신도 상승"처럼 원문 표현이 제각각이라 어느 행에 태그가 붙는지도 일관성이 약하다(예: narrative-critic/F2 "확신도 상승"은 태그 없음). "본인 표기" 작은 글씨만으로는 구분이 약하다. 모양을 다르게 하거나 펼침 상세에만 둔다.

### U10. SYNTHESIS의 퀵 윈 3개가 페이지 어디에도 없다 — NICE-TO-FIX
`viz-data.json`에는 `synthesis_quick_wins`가 있지만 HTML은 렌더링하지 않는다. 명세의 시각화 5개에 포함되지 않아 오류로 보지는 않았다. 발표 흐름("결론 → 근거 → 전체")에서 "그래서 무엇을 먼저 고치나"에 대한 답이 빠진다. 헤더의 판정 아래에 세 줄로 넣을 만하다.

### U11. 좁은 폭에서 지적 ID가 단어 중간에서 줄바꿈될 수 있다 — NICE-TO-FIX
`.c-id{word-break:break-all}`(244행) 때문에 1000px 이하 레이아웃에서 `player-psychologist/F1` 같은 ID가 글자 단위로 끊길 수 있다(소스 추론). `overflow-wrap:anywhere`로 바꾸거나 `/` 뒤에 `<wbr>`을 넣는다. 한글 본문에는 `word-break: keep-all`이 적용되어 있고 한글 폴백 글꼴("Pretendard", "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR")도 본문·디스플레이·고정폭 스택에 모두 있다.

### 문제 없음(소스 기준)
- 단일 파일이고 외부 에셋·CDN·프레임워크가 없다. `<html lang="ko">`와 `<meta charset="utf-8">`가 지정되어 있다.
- 콘텐츠 최대 폭은 1100px(`.wrap` 1164px − 좌우 32px)이고, 섹션 간격은 80px, border-radius는 4px 이하다. 그림자, 그라디언트, 이모지, 아이콘은 없다.
- 페이드업은 한 번뿐이고 `prefers-reduced-motion`에서는 꺼진다. 펼침과 전환은 즉시 일어난다.
- 클릭할 수 있는 요소는 `button`이거나, SVG `g`에 `role="button"`·`tabindex`·Enter/Space 처리를 붙인 것이다. `:focus-visible` 외곽선이 있고 툴팁은 호버와 포커스에서 모두 뜬다.
- 모든 지적 ID 링크(`data-fid`)는 필터를 초기화한 뒤 V5 해당 행으로 이동해 펼치고, 2초간 좌측 막대로 표시한다.
- V4 "전체" 행에는 척도 안내("전체 행은 척도가 다릅니다(30개 기준)")가 있다. 3위 카드에는 BLOCKING · 치명 + WEAKENED · 약화 조합의 단서 문구가 태그 바로 아래 있다.
- 쟁점이 없을 때 쓰는 빈 상태 문구는 CLAUDE.md 문구 그대로다.

---

## 3. 판정

**한 번 더 손봐야 한다.**

리뷰 데이터 자체의 추출과 집계는 정확하다. 30개 지적, 심각도, 귀속, 등급 변경 4건, 상위 이슈 5개, 쟁점 6개는 원본과 일치한다. 복합 ID, 한국어 병기 표시, 빈 상태, 키보드 경로도 소스상 대체로 잘 갖춰져 있다.

그러나 MUST-FIX 두 건은 페이지가 주장하는 사실을 틀리게 만든다.
1. **E1:** 상위 이슈 3위가 관련 지적(systems-designer/F5)을 원본 지적으로 표시한다.
2. **E2:** 교차 검토 매트릭스가 "누가 누구와 논쟁했는가"를 보여 준다고 하면서, 지지 근거로 인용된 동료 14건을 충돌로 센다.

둘 다 수정 범위가 작다(E1은 JSON 필드 분리, E2는 `mkItem`에서 `peer_reviewers`만 사용). 권고 14건(정확성 3, 사용성 11)은 이번 수정과 함께 처리하면 좋다. 발표 전에 반드시 고칠 것은 아니다.

브라우저 동작(필터, 키보드, 레이아웃, 390px 폭)은 호스트의 Edge·Firefox 검증 보고에 기대고 있다. 감사자는 이를 직접 재현하지 않았다. 수정한 뒤에는 E2로 바뀌는 V3 셀 값과 U4·U7 포커스 동작을 실제 브라우저에서 다시 확인해야 한다.
