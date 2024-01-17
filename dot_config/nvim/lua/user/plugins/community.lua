return {
	-- Add the community repository of plugin specifications
	"AstroNvim/astrocommunity",
	-- example of imporing a plugin, comment out to use it or add your own
	-- available plugins can be found at https://github.com/AstroNvim/astrocommunity

	{ import = "astrocommunity.colorscheme.catppuccin" },
	{ import = "astrocommunity.pack.rust" },
	{ import = "astrocommunity.pack.typescript" },
	{
		"mfussenegger/nvim-dap",
		ft = { "ts", "js", "tsx", "jsx" },
		enabled = true,
		dependencies = {
			{
				"mxsdev/nvim-dap-vscode-js",
				opts = { debugger_cmd = { "js-debug-adapter" }, adapters = { "pwa-node" } },
			},
			{ "theHamsta/nvim-dap-virtual-text", config = true },
			{ "rcarriga/nvim-dap-ui", config = true },
		},
		config = function()
			local dap = require("dap")
			local attach_node = {
				type = "pwa-node",
				name = "Attach to Node",
				request = "attach",
				address = "127.0.0.1",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			}

			local launch_nest = {
				type = "pwa-node",
				request = "launch",
				name = "NestJS: Launch",
				program = "${workspaceFolder}/src/server.js",
				cwd = "${workspaceFolder}",
				skipFiles = {
					"<node_internals>/**",
				},
				sourceMaps = true,
				resolveSourceMapLocations = {
					"${workspaceFolder}/**",
					"!**/node_modules/**",
				},
				protocol = "inspector",
				console = "integratedTerminal",
				port = 3000,
				-- args = { "start", "--watch", "--debug" },
				env = {
					NODE_ENV = "dev",
				},
				outFiles = {
					"${workspaceFolder}/dist/server.js",
				},
				sourceMapPathOverrides = {
					["webpack:///./src/*"] = "${workspaceFolder}/src/*",
					["webpack:///src/*"] = "${workspaceFolder}/src/*",
					["webpack:///*"] = "*",
				},
			}

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "9229",
				executable = {
					command = "js-debug-adapter",
					args = { "9229" },
				},
			}

			dap.configurations.javascript = {
				attach_node,
				launch_nest,
			}
			dap.configurations.typescript = {
				attach_node,
				launch_nest,
			}
		end,
	},
	{ import = "astrocommunity.pack.json" },
	{ import = "astrocommunity.pack.lua" },
	{ import = "astrocommunity.pack.tailwindcss" },
	{ import = "astrocommunity.completion.copilot-lua" },
	{
		"copilot.lua",
		opts = {
			suggestion = {
				keymap = {
					accept = "<C-l>",
					accept_word = false,
					accept_line = false,
					next = "[[",
					prev = "]]",
					dismiss = "<C-/>",
				},
			},
		},
	},
	-- { import = "astrocommunity.completion.copilot-lua-cmp" },
}
