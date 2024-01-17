return { -- this table overrides highlights in all themes
  -- Normal = { bg = "#000000" },
  --  -- set highlight group for any theme
  -- the key is the name of the colorscheme or init
  -- the init key will apply to all colorschemes
    -- apply highlight group to all colorschemes (include the default_theme)
      -- set the transparency for all of these highlight groups
  Normal = { bg = "NONE", ctermbg = "NONE" },
  NormalNC = { bg = "NONE", ctermbg = "NONE" },
  CursorColumn = { cterm = {}, ctermbg = "NONE", ctermfg = "NONE" },
  CursorLine = { cterm = {}, ctermbg = "NONE", ctermfg = "NONE" },
  CursorLineNr = { cterm = {}, ctermbg = "NONE", ctermfg = "NONE" },
  LineNr = {},
  SignColumn = {},
  StatusLine = {},
  NeoTreeNormal = { bg = "NONE", ctermbg = "NONE" },
  NeoTreeNormalNC = { bg = "NONE", ctermbg = "NONE" },


}
