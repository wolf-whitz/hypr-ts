export interface Shader {
  name: string;
  options: Record<string, any>;
}

export class ShaderCompiler {
  private shaders: Shader[] = [];

  add(name: string, options: Record<string, any>) {
    this.shaders.push({ name, options });
    return this;
  }

  compile(): string {
    return this.shaders
      .map(s => `shader = ${s.name} ${JSON.stringify(s.options)}`)
      .join("\n") + "\n";
  }
}
