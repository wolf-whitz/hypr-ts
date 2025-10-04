import { KeybindingCompiler } from "../../src/compiler/keybinding.compiler.ts";

const $mainMod = "Super";
const $TERMINAL = "kitty";
const $EDITOR = "code";
const $EXPLORER = "thunar";
const $BROWSER = "flatpak run com.zen.Zen";

const kb = new KeybindingCompiler("/home/whitz/");

// █ Window Management
kb
  .add(`${$mainMod}+Q`, "close focused window", "exec", "dontkillsteam.sh", "Window Management")
  .add(`Alt+F4`, "close focused window", "exec", "dontkillsteam.sh", "Window Management")
  .add(`${$mainMod}+Delete`, "kill hyprland session", "exec", "hyde-shell logout", "Window Management")
  .add(`${$mainMod}+W`, "toggle floating", "togglefloating", undefined, "Window Management")
  .add(`${$mainMod}+G`, "toggle group", "togglegroup", undefined, "Window Management")
  .add(`Shift+F11`, "toggle fullscreen", "fullscreen", undefined, "Window Management")
  .add(`${$mainMod}+L`, "lock screen", "exec", "lockscreen.sh", "Window Management")
  .add(`${$mainMod}+Shift+F`, "toggle pin on focused window", "exec", "windowpin.sh", "Window Management")
  .add(`Control+Alt+Delete`, "logout menu", "exec", "logoutlaunch.sh", "Window Management")
  .add(`Alt_R+Control_R`, "toggle waybar and reload config", "exec", "hyde-shell waybar --hide", "Window Management");

// █ Launcher
kb
  .add(`${$mainMod}+T`, "terminal emulator", "exec", $TERMINAL, "Launcher")
  .add(`${$mainMod}+Alt+T`, "dropdown terminal", "exec", "hyde-shell pypr toggle console", "Launcher")
  .add(`${$mainMod}+E`, "file explorer", "exec", $EXPLORER, "Launcher")
  .add(`${$mainMod}+C`, "text editor", "exec", $EDITOR, "Launcher")
  .add(`${$mainMod}+B`, "web browser", "exec", $BROWSER, "Launcher");

// █ Hardware Controls
kb
  .add(`F10`, "toggle mute output", "exec", "volumecontrol.sh -o m", "Audio")
  .add(`XF86AudioMute`, "toggle mute output", "exec", "volumecontrol.sh -o m", "Audio")
  .add(`F11`, "decrease volume", "exec", "volumecontrol.sh -o d", "Audio")
  .add(`F12`, "increase volume", "exec", "volumecontrol.sh -o i", "Audio")
  .add(`XF86AudioPlay`, "play media", "exec", "playerctl play-pause", "Media")
  .add(`XF86AudioNext`, "next media", "exec", "playerctl next", "Media")
  .add(`XF86AudioPrev`, "previous media", "exec", "playerctl previous", "Media");

// █ Workspaces
kb
  .add(`${$mainMod}+1`, "navigate to workspace 1", "workspace", "1", "Workspaces")
  .add(`${$mainMod}+2`, "navigate to workspace 2", "workspace", "2", "Workspaces")
  .add(`${$mainMod}+3`, "navigate to workspace 3", "workspace", "3", "Workspaces");

export const hyprBindings = kb.compile();
