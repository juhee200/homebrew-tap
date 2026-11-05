cask "pr-ai-reviewer" do
  version "0.5.0"
  sha256 "34f62202ecc84a1df09701c5ca6004bdb25b43fab72eee05e1c9ec8ff3944505"

  url "https://github.com/juhee200/pr-ai-reviewer/releases/download/v#{version}/pr-ai-reviewer-#{version}.zip"
  name "PR AI Reviewer"
  desc "Menu bar app that reviews your pull requests with local Claude Code or Codex"
  homepage "https://github.com/juhee200/pr-ai-reviewer"

  depends_on formula: ["gh", "node"]
  depends_on macos: :sonoma

  app "PR AI Reviewer.app"

  postflight_steps do
    # 개발자 인증서 없이 ad-hoc 서명한 앱이라, Gatekeeper가 실행을 막지 않도록 quarantine 속성을 지운다.
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/PR AI Reviewer.app"]
    # 업그레이드라면 자동 리뷰를 새 버전으로 다시 시작한다. 등록돼 있지 않으면 아무 일도 하지 않는다.
    run "bin/node",
        base:         :homebrew_prefix,
        args:         ["{{appdir}}/PR AI Reviewer.app/Contents/Resources/cli/dist/cli.js", "service", "restart"],
        must_succeed: false
  end

  # 자동 리뷰(LaunchAgent)는 uninstall에서 내리지 않는다. brew upgrade 때도 uninstall이 실행되기 때문이다.
  # 앱을 지우면 감시 프로세스가 앱이 사라진 것을 확인하고 2분 안에 자기 등록을 지운 뒤 끝난다.
  uninstall quit: "io.github.juhee200.pr-ai-reviewer"

  zap launchctl: "io.github.juhee200.pr-ai-reviewer.agent",
      trash:     [
        "~/.cache/pr-ai-reviewer",
        "~/.config/pr-ai-reviewer",
        "~/.local/state/pr-ai-reviewer",
        "~/Library/Logs/pr-ai-reviewer",
      ]

  caveats <<~EOS
    메뉴바의 PR AI Reviewer 아이콘에서 설정을 열어 저장소를 고르고 자동 리뷰를 켜세요.
    리뷰 엔진으로 Claude Code 또는 Codex CLI 중 하나가 설치·로그인돼 있어야 합니다.
  EOS
end
