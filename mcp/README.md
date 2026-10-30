# MCP 설정 (선택)

**MCP 없이도 툴킷은 동작합니다.** 화면 확인은 `$dj-verify`가 Playwright CLI로 처리합니다.
MCP를 쓰고 싶으면 사전 체험 때 먼저 시험해 보고, 동작할 때만 본 과제에서 쓰세요.

- 응시 환경의 **MCP 탭**에 붙여 넣습니다. `config.toml`을 직접 고치지 마세요 (플랫폼 설정 수정 금지).
- **개인 API 키는 넣지 마세요.** 아래는 모두 키 없이 동작하는 공개 MCP입니다.
- 저장 후 Codex를 다시 시작하고 `/mcp`로 도구가 보이는지 확인합니다.

## 1. JSON 형식 (MCP 탭이 JSON일 때)

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@0.0.83", "--headless", "--isolated", "--browser", "chromium", "--no-sandbox", "--output-dir", "/tmp/pw-mcp"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@4.4.4"]
    }
  }
}
```

## 2. TOML 형식 (MCP 탭이 config.toml 형식일 때)

```toml
[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp@0.0.83", "--headless", "--isolated", "--browser", "chromium", "--no-sandbox", "--output-dir", "/tmp/pw-mcp"]

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@4.4.4"]
```

## 각 서버가 하는 일

| 서버 | 용도 | 주의 |
|---|---|---|
| playwright | Codex가 브라우저를 직접 조작해 내 앱을 확인 (클릭, 입력, 스크린샷) | 첫 실행 시 브라우저 설치 필요: `bash ~/DJ_toolkit/install.sh --browser`. 메모리 사용량 큼 |
| context7 | 라이브러리 최신 공식 문서 검색 (예: "FastAPI 최신 lifespan 사용법") | 키 없이 쓰면 호출 횟수 제한이 낮음. 과제 내용·코드는 보내지 말고 라이브러리 이름과 질문만 |

## 확인할 것 (사전 체험)
- [ ] MCP 탭 형식이 JSON인지 TOML인지
- [ ] 저장 후 `/mcp`에 playwright, context7 도구가 보이는지
- [ ] Cofa Helper에게: "Playwright MCP로 내가 만든 앱을 테스트해도 되나요?" (규정의 Computer Use 금지와 구분 확인)
