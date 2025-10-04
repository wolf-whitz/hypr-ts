export interface UserPrefs {
  [key: string]: string | number | boolean;
}

export class UserPrefsCompiler {
  private prefs: UserPrefs = {};

  set(key: string, value: string | number | boolean) {
    this.prefs[key] = value;
    return this;
  }

  compile(): string {
    return Object.entries(this.prefs)
      .map(([k, v]) => `${k} = ${v}`)
      .join("\n") + "\n";
  }
}
