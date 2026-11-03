# AllowClick

AllowClick is an unfinished macOS menu bar prototype for the Apple Events permission request from `Grok Bot.app` to `Terminal.app`. It is not ready for installation or use: the owner, Accessibility structure, and successful operation on the actual system dialog have not been verified.

The intended rule matches only the exact English or Japanese Apple Events message for that requester and target, a modal window belonging to an Apple-signed system application, and one enabled Allow button together with one enabled Don't Allow button. It excludes web content. It requires macOS Accessibility permission.

The app's watcher and the LaunchAgent installer have not been run against the real permission prompt. Do not activate them until the system dialog can be independently verified.

The menu bar shows the current Accessibility permission state. When permission is missing, select `Open Accessibility Settings…` to request the permission and open the macOS Accessibility settings. The user controls whether the permission is granted.

To build and check the current prototype in a new build directory:

```sh
ALLOWCLICK_BUILD_DIR="$(mktemp -d -t allowclick-build)" bash scripts/build-app.sh
swiftc AllowRule.swift main.swift -o /tmp/allowclick-rule-tests
/tmp/allowclick-rule-tests
```

The build script creates `AllowClick.app` in the selected build directory. It uses ad hoc signing unless `ALLOWCLICK_SIGNING_IDENTITY` selects a stable signing identity. The untested LaunchAgent installer accepts an absolute app path, starts at login, and restarts after an unsuccessful exit. `scripts/uninstall-agent.sh` removes the installed LaunchAgent.
