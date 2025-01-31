import * as vscode from "vscode";

export type LOG_LEVEL = "DEBUG" | "INFO" | "WARN" | "ERROR" | "FATAL";

class Logger {
  private channel = vscode.window.createOutputChannel("Jaive Turkey");

  log(message: string, level?: LOG_LEVEL) {
    // TODO: Wrap in a level check
    if (level) {
      this.channel.append(`[${level}] `);
    }
    this.channel.appendLine(`${message}`);
  }

  debug(message: string) {
    this.log(message, "DEBUG");
  }
  info(message: string) {
    this.log(message, "INFO");
  }
  warning(message: string) {
    this.log(message, "WARN");
  }
  error(message: string) {
    this.log(message, "ERROR");
  }
  fatal(message: string) {
    this.log(message, "FATAL");
  }

  show() {
    this.channel.show(true);
  }
}

export const logger = new Logger();
