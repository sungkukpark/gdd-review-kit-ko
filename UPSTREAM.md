# 원본 기준 및 번역 출처

최종 확인일: 2026-09-29

## 원본 기준

- 원본 저장소: [GixGosu/gdd-review-kit](https://github.com/GixGosu/gdd-review-kit)
- 초판 기준 브랜치: 원본 `main`
- 기준 커밋: [`2737b9102c3d02664b9f1c0eb72497d38c896e26`](https://github.com/GixGosu/gdd-review-kit/commit/2737b9102c3d02664b9f1c0eb72497d38c896e26)
- 기준 커밋 제목: `Update README to reflect full 10-agent setup`
- 원본 설계·작성: GixGosu

이 저장소는 위 커밋까지의 원본 Git 이력을 보존하고, 한국어 번역과 한국어판의
추가 변경을 그 위에 별도 커밋으로 기록합니다.

## 재사용한 한국어 번역

- 번역 작업 저장소: `sungkukpark/gdd-review-kit-kr`(확인 당시 비공개)
- 번역 출처 커밋: `f22df454a89527ffadea9ed014d04d745e853629`
- 번역 출처 커밋 제목: `feat: add Korean localization of GDD multi-agent review kit`
- 한국어 번역 및 유지관리: Sungkuk Park(박성국)

README.md, CLAUDE.md, `.claude/agents/`의 에이전트 10개, `.gitignore`를
재사용했습니다. 에이전트 10개와 CLAUDE.md는 번역 출처의 내용과 일치합니다.
README의 출처 표기, `.gitignore`의 로컬 문서 제외 규칙, 권리 안내와 이 문서를
추가하고 한국어판 변경을 커밋 하나로 정리했습니다.

기존 번역 커밋은 부모 없는 최초 커밋이므로, 해당 커밋을 원본 이력과 병합하는
대신 번역 파일을 원본 위에 적용했습니다. 번역 출처 SHA는 이 문서에
보존했습니다.

## 원격 구성

| 원격 | URL | 용도 |
|---|---|---|
| `origin` | `https://github.com/sungkukpark/gdd-review-kit-ko.git` | 한국어판 배포 |
| `upstream` | `https://github.com/GixGosu/gdd-review-kit.git` | 원본 변경 확인 |

원본 변경을 반영할 때는 기준 커밋과 변경 내용을 비교하고 한국어 지침을
검수합니다. 실행 결과에 영향을 주는 변경은 해당 라운드와 보고서를 검증한 뒤
이 문서의 기준 커밋·확인일을 갱신합니다.

원본 기준을 가져온 것은 실제 Claude Code 실행 검증을 의미하지 않습니다.
검증 환경과 예제 결과는 후속 실행 단계에서 기록합니다.
