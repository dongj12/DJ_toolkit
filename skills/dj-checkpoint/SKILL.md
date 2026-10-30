---
name: dj-checkpoint
description: 지금까지의 변경을 git 커밋으로 남긴다(세이브 포인트). 기능 하나 완성, 버그 수정, 테스트 통과 직후나 사용자가 "커밋해줘", "저장해줘"라고 할 때 사용한다. push는 하지 않는다.
---

# 체크포인트 커밋

## 순서

1. `git rev-parse --is-inside-work-tree` 로 저장소인지 확인한다. 아니면 `git init`.
2. 사용자 정보가 없으면 저장소 범위로만 설정한다 (전역 설정은 건드리지 않는다):
   `git config user.name >/dev/null || git config user.name "participant"`
   `git config user.email >/dev/null || git config user.email "participant@example.com"`
3. `.gitignore`를 확인하고 없거나 부족하면 추가한다:
   ```
   node_modules/
   .venv/
   venv/
   __pycache__/
   *.pyc
   .env
   .playwright-cli/
   dist/
   build/
   .DS_Store
   ```
4. `git status --short` 로 변경을 본다. 비밀 정보(.env, 키 파일)나 큰 산출물이 섞여 있으면 제외한다.
5. `git add -A && git commit -m "<메시지>"`
6. `git log --oneline -5` 를 보여준다.

## 커밋 메시지
- 한국어, "무엇: 왜" 형식으로 한 줄. 50자 안팎.
- 예: `할 일 추가 API 구현: R1 요구사항`, `빈 입력 검증 추가: 400 반환`, `저장 방식을 JSON으로 변경: DB 설정 시간 절약`
- 여러 기능이 섞였으면 나눠서 커밋한다 (`git add <파일>`).

## 원칙
- `git push`, `git commit --amend`, `git rebase`, `git reset --hard`는 쓰지 않는다. 작업 이력이 평가 자료다.
- 테스트가 깨진 상태면 메시지에 "(테스트 실패 중)"을 붙인다.
