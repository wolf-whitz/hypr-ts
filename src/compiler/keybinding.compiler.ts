import fs from "fs";
import path from "path";

export type ActionType =
  | "exec"
  | "togglefloating"
  | "togglegroup"
  | "fullscreen"
  | "changegroupactive"
  | "movefocus"
  | "resizeactive"
  | "movewindow"
  | "workspace"
  | "movetoworkspace"
  | "movetoworkspacesilent"
  | "togglesplit"
  | "cyclenext";

export interface Keybind {
  combo: string;
  description?: string;
  group?: string;
  action: ActionType;
  args?: string;
}

export class KeybindingCompiler {
  private keybinds: Keybind[] = [];
  private basePath: string;

  constructor(basePath: string = process.cwd()) {
    this.basePath = basePath;
  }

  add(
    combo: string,
    description?: string,
    action?: ActionType,
    args?: string,
    group?: string
  ) {
    if (!action) throw new Error("Action must be provided");
    const keybind: Keybind = { combo, action };
    if (description !== undefined) keybind.description = description;
    if (group !== undefined) keybind.group = group;
    if (args !== undefined) keybind.args = args;
    this.keybinds.push(keybind);
    return this;
  }

  include(relativePath: string) {
    const fullPath = path.resolve(this.basePath, relativePath);
    if (!fs.existsSync(fullPath)) throw new Error(`Included file not found: ${fullPath}`);
    const mod = require(fullPath);
    if (!mod.hyprBindings) throw new Error(`Included file must export hyprBindings: ${fullPath}`);
    if (mod.hyprBindings instanceof KeybindingCompiler) {
      this.keybinds.push(...mod.hyprBindings.keybindsData);
    } else if (Array.isArray(mod.hyprBindings)) {
      this.keybinds.push(...mod.hyprBindings);
    } else {
      throw new Error(`hyprBindings in included file must be KeybindingCompiler or Keybind[]: ${fullPath}`);
    }
    return this;
  }

  compile(): string {
    return this.keybinds
      .map((k) => {
        const groupPrefix = k.group ? `[${k.group}] ` : "";
        const argsPart = k.args ? `, ${k.args}` : "";
        return `bind = ${k.combo}, ${groupPrefix}${k.description ?? ""}, ${k.action}${argsPart}`;
      })
      .join("\n") + "\n";
  }

  get keybindsData() {
    return this.keybinds;
  }
}
