cask "review-owl" do
  version "0.6.0"
  sha256 "2be55c03253d8a51748ec019c81851cc624ba4ac840d835de58e6143bdcaad8d"

  url "https://github.com/juhee200/review-owl/releases/download/v#{version}/review-owl-#{version}.zip"
  name "리뷰엉이"
  name "Review Owl"
  desc "Menu bar app that reviews your pull requests with local Claude Code or Codex"
  homepage "https://github.com/juhee200/review-owl"

  depends_on formula: ["gh", "node"]
  depends_on macos: :sonoma

  app "Review Owl.app"

  postflight_steps do
    # 개발자 인증서 없이 ad-hoc 서명한 앱이라, Gatekeeper가 실행을 막지 않도록 quarantine 속성을 지운다.
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/Review Owl.app"]
  end

  # 업그레이드 후 감시 프로세스는 설치된 버전이 바뀐 것을 보고 스스로 다시 시작한다.
  # cask 설치 후 명령은 Homebrew 샌드박스에서 실행돼 launchd 작업을 다시 시작할 수 없다.
  # 자동 리뷰(LaunchAgent)는 uninstall에서 내리지 않는다. brew upgrade 때도 uninstall이 실행되기 때문이다.
  # 앱을 지우면 감시 프로세스가 앱이 사라진 것을 확인하고 2분 안에 자기 등록을 지운 뒤 끝난다.
  uninstall quit: "io.github.juhee200.review-owl"

  zap launchctl: "io.github.juhee200.review-owl.agent",
      trash:     [
        "~/.cache/review-owl",
        "~/.config/review-owl",
        "~/.local/state/review-owl",
        "~/Library/Logs/review-owl",
      ]

  caveats <<~EOS
    메뉴바의 리뷰엉이 아이콘에서 설정을 열어 저장소를 고르고 자동 리뷰를 켜세요.
    리뷰 엔진으로 Claude Code 또는 Codex CLI 중 하나가 설치·로그인돼 있어야 합니다.
    pr-ai-reviewer(v0.5.0 이하)를 쓰던 경우 brew uninstall --cask pr-ai-reviewer로 지운 뒤 앱을 여세요.
    설정과 리뷰 기록은 처음 실행할 때 옮겨집니다.
  EOS
end
