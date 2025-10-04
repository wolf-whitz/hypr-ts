export interface Workflow {
  workspace: string;
  command: string;
}

export class WorkflowCompiler {
  private workflows: Workflow[] = [];

  add(workspace: string, command: string) {
    this.workflows.push({ workspace, command });
    return this;
  }

  compile(): string {
    return this.workflows
      .map(w => `[workspace:${w.workspace}]\ncommand = ${w.command}`)
      .join("\n") + "\n";
  }
}
