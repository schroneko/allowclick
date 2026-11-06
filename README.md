# AllowClick

AllowClick is a macOS menu bar app that clicks Allow on standard system permission dialogs. It matches a modal window owned by an Apple-signed app under `/System/Library/`, with a non-empty message and exactly one enabled Allow button together with one enabled Don't Allow button (or 許可 / 許可しない). It skips web content. It requires macOS Accessibility permission.

Examples it is meant to match include Apple Events prompts and TCC prompts such as an app asking to access files in Documents.

The menu bar shows the current Accessibility permission state. When permission is missing, select `Open Accessibility Settings…` to request the permission and open the macOS Accessibility settings. The user controls whether the permission is granted.

To build and check the matcher:

```sh
ALLOWCLICK_BUILD_DIR="$(mktemp -d -t allowclick-build)" bash scripts/build-app.sh
swiftc AllowRule.swift main.swift -o /tmp/allowclick-rule-tests
/tmp/allowclick-rule-tests
```

The build script creates `AllowClick.app` in the selected build directory. It uses ad hoc signing unless `ALLOWCLICK_SIGNING_IDENTITY` selects a stable signing identity. `scripts/install-agent.sh` accepts an absolute app path, starts at login, and restarts after an unsuccessful exit. `scripts/uninstall-agent.sh` removes the installed LaunchAgent.
