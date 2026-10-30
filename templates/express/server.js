import { createApp } from './app.js';

const PORT = Number(process.env.PORT) || 3000;
// 0.0.0.0 바인딩: localhost만 쓰면 웹 IDE 미리보기가 열리지 않는다.
createApp().listen(PORT, '0.0.0.0', () => {
  console.log(`listening on http://0.0.0.0:${PORT}`);
});
