-- use mason-lspconfig to configure LSP installations
return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    automatic_installation = true,
    ensure_installed = {
      "html",
      "jsonls",
      "tsserver",
      "yamlls",
      "rust_analyzer"
    },
  },
}
