/**
 * Model-Scoped AGENTS.md Extension
 *
 * Loads model-specific context files based on the active model.
 * Configure via .pi/model-agents.json or ~/.pi/agent/model-agents.json
 *
 * Config format:
 * {
 *   "mappings": [
 *     { "pattern": "claude-*", "file": ".pi/agents/claude.md" },
 *     { "pattern": "gpt-4o", "file": ".pi/agents/openai.md" },
 *     { "pattern": "kimi-*", "provider": "moonshot", "file": "~/.pi/agent/agents/kimi.md" }
 *   ],
 *   "defaultFile": ".pi/agents/default.md"
 * }
 */

import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import type { ExtensionAPI, Model } from "@mariozechner/pi-coding-agent";

interface ModelMapping {
	pattern: string;
	provider?: string;
	file: string;
}

interface Config {
	mappings?: ModelMapping[];
	defaultFile?: string;
}

function loadConfig(cwd: string): Config {
	const configs: Config[] = [];

	// Load from global config
	const globalConfigPath = path.join(os.homedir(), ".pi/agent/model-agents.json");
	if (fs.existsSync(globalConfigPath)) {
		try {
			const content = fs.readFileSync(globalConfigPath, "utf-8");
			configs.push(JSON.parse(content));
		} catch (e) {
			console.error(`[model-agents] Failed to load global config: ${e}`);
		}
	}

	// Load from project config (overrides/extends global)
	const projectConfigPath = path.join(cwd, ".pi/model-agents.json");
	if (fs.existsSync(projectConfigPath)) {
		try {
			const content = fs.readFileSync(projectConfigPath, "utf-8");
			configs.push(JSON.parse(content));
		} catch (e) {
			console.error(`[model-agents] Failed to load project config: ${e}`);
		}
	}

	// Merge configs (project overrides global for same patterns)
	const merged: Config = { mappings: [], defaultFile: undefined };
	for (const config of configs) {
		if (config.mappings) {
			// Later configs take precedence for same pattern
			const existingPatterns = new Set(merged.mappings!.map((m) => m.pattern));
			for (const mapping of config.mappings) {
				if (!existingPatterns.has(mapping.pattern)) {
					merged.mappings!.push(mapping);
				}
			}
		}
		if (config.defaultFile && !merged.defaultFile) {
			merged.defaultFile = config.defaultFile;
		}
	}

	return merged;
}

function expandPath(filePath: string, cwd: string): string {
	if (filePath.startsWith("~/")) {
		return path.join(os.homedir(), filePath.slice(2));
	}
	if (path.isAbsolute(filePath)) {
		return filePath;
	}
	return path.join(cwd, filePath);
}

function matchesModel(mapping: ModelMapping, model: Model): boolean {
	const modelId = model.id.toLowerCase();
	const provider = model.provider.toLowerCase();
	const pattern = mapping.pattern.toLowerCase();

	// Check provider if specified
	if (mapping.provider && mapping.provider.toLowerCase() !== provider) {
		return false;
	}

	// Simple wildcard matching (* matches any characters)
	const regex = new RegExp("^" + pattern.replace(/\*/g, ".*") + "$");
	return regex.test(modelId);
}

function findMatchingFile(config: Config, model: Model, cwd: string): string | null {
	// Find first matching mapping
	for (const mapping of config.mappings || []) {
		if (matchesModel(mapping, model)) {
			const fullPath = expandPath(mapping.file, cwd);
			if (fs.existsSync(fullPath)) {
				return fullPath;
			}
			console.error(`[model-agents] Configured file not found: ${fullPath}`);
		}
	}

	// Fall back to default file
	if (config.defaultFile) {
		const defaultPath = expandPath(config.defaultFile, cwd);
		if (fs.existsSync(defaultPath)) {
			return defaultPath;
		}
	}

	return null;
}

export default function (pi: ExtensionAPI) {
	let config: Config = {};
	let currentModel: Model | null = null;
	let lastLoadedFile: string | null = null;

	pi.on("session_start", async (_event, ctx) => {
		config = loadConfig(ctx.cwd);
		const mappingCount = config.mappings?.length || 0;
		if (mappingCount > 0) {
			ctx.ui.notify(`Model-agents: ${mappingCount} mapping(s) loaded`, "info");
		}
	});

	pi.on("model_select", async (event, ctx) => {
		currentModel = event.model;
		const file = findMatchingFile(config, event.model, ctx.cwd);

		if (file && file !== lastLoadedFile) {
			lastLoadedFile = file;
			const relativePath = path.relative(ctx.cwd, file);
			ctx.ui.notify(`Model context: ${relativePath}`, "info");
		}
	});

	pi.on("before_agent_start", async (event, ctx) => {
		if (!currentModel) return;

		const file = findMatchingFile(config, currentModel, ctx.cwd);
		if (!file) return;

		try {
			const content = fs.readFileSync(file, "utf-8");
			const relativePath = path.relative(ctx.cwd, file);

			return {
				systemPrompt:
					event.systemPrompt +
					`\n\n## Model-Specific Context (${relativePath})\n\n${content}`,
			};
		} catch (e) {
			console.error(`[model-agents] Failed to read ${file}: ${e}`);
		}
	});
}
