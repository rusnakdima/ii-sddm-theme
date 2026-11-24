# Local patches vs upstream `3d3f/ii-sddm-theme`

This fork tracks upstream `https://github.com/3d3f/ii-sddm-theme` and adds the
divergences below. Run `git fetch upstream && git merge upstream/main` to pull in
new upstream releases.

| File | Change | Reason |
| --- | --- | --- |
| `Components/UserButton.qml` | Always-visible dropdown; appends an **"Other user"** row after `userModel`; hardcoded avatar for `dmitriy`; `selectionChanged()` / `accepted()` signals | User list stays a dropdown; "Other user" reveals the free-form username field |
| `Components/InputLogin.qml` | Extra username `TextField` above the password field, shown only for "Other user"; login uses the typed name in that case, the dropdown selection otherwise; trim/lowercase rules preserved | Allow authenticating arbitrary usernames without giving up the dropdown |
| `Components/Input.qml` | Wires `selectUser` selection/accepted signals to focus the active field | Keyboard focus follows the chosen user source |
| `Components/Colors.qml` | Custom colour palette | Matches the rest of the desktop theme |
| `iiMatugen/sddm-theme-apply.sh` | Root-aware `run_root` helper | Apply the theme from a root-owned install without breaking permissions |
| `setup.sh` | `sudo -n` for non-interactive setup | Allows the installer to run without prompting for a password |

Per-device generated files (`Components/Settings.qml`, `iiMatugen/Settings.qml`,
`noMatugen/Settings.qml`, `Matugen/Settings.qml`, `Themes/ii-sddm.conf`, and
`Backgrounds/*`) are **not** stored in this fork. They are generated locally and
preserved by the `end4-pC` installer (`install.sh:install_sddm_theme()`).
