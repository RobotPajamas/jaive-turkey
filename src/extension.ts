import * as proc from "child_process";
import * as vscode from "vscode";
import { getJaiExecutable } from "./configuration";
import { logger } from "./logging";

// let disposables: vscode.Disposable[] = [];

const extensionName = "robotpajamas.vscode-jai";
const extensionVersion = "0.0.3";

export async function activate(context: vscode.ExtensionContext) {
  logger.info(`Extension name: ${extensionName}`);
  logger.info(`Extension version: ${extensionVersion}`);

  logger.info(`The configured executable is: ${getJaiExecutable()}`);
}

export function deactivate() {
  // if (disposables) {
  //   disposables.forEach((item) => item.dispose());
  // }
  // disposables = [];
}
