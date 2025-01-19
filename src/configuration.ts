import { workspace, WorkspaceConfiguration } from "vscode";

export const namespace = "jaive-turkey";

/**
 * Returns the path to the Jai executable, as configured in the user's settings.
 * If no valid executable is configured (e.g. empty string), returns "jai".
 *
 * @param config The user's WorkspaceConfiguration. Defaults to the global vscode configuration.
 * @returns The path to the Jai executable.
 */
export function getJaiExecutable(
  config: WorkspaceConfiguration = workspace.getConfiguration(namespace),
): string {
  return returnDefaultIfUndefined(config.get<string>("executable"), "jai")
    .trim();
}

function returnDefaultIfUndefined(value: any, defaultValue: any) {
  if (value === undefined) {
    return defaultValue;
  }
  return value;
}
