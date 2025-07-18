-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
	"AstroNvim/astrocommunity",
	{ import = "astrocommunity.pack.lua" },
	-- import/override with your plugins folder
	{ import = "astrocommunity.colorscheme.catppuccin" },
	{ import = "astrocommunity.pack.rust" },
	{ import = "astrocommunity.pack.typescript" },
	{ import = "astrocommunity.pack.lua" },
	{ import = "astrocommunity.pack.kotlin" },
	{ import = "astrocommunity.pack.java" },
	{ import = "astrocommunity.recipes.vscode-icons" },
	{ import = "astrocommunity.recipes.telescope-nvim-snacks" },
	{ import = "astrocommunity.note-taking.obsidian-nvim" },
}
