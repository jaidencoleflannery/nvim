-- empty keybind leader
vim.g.mapleader = " "

-- initialize plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath
	})
end
vim.opt.rtp:prepend(lazypath)

-- load basic configuration
require("options")

require("lazy").setup({
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
})

-- mason manages developer tools like lsps and linters
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "omnisharp" },
})

local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

local function omnisharp_cmd()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
  local candidates = {
    mason_bin .. "OmniSharp",   -- common on mac/linux
    mason_bin .. "omnisharp",   -- sometimes
  }
  for _, p in ipairs(candidates) do
    if vim.fn.executable(p) == 1 then
      return { p, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) }
    end
  end
  return nil
end

-- spin up omnisharp (c# lsp)
lspconfig.omnisharp.setup({
  cmd = omnisharp_cmd(),
  root_dir = util.root_pattern("*.sln", "*.csproj", ".git"),
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
})

-- basic ui configuration
vim.opt.termguicolors = true

-- load theme
require("colors.terminal").setup()
vim.cmd.colorscheme("terminal")

-- keymaps
vim.keymap.set("n", "ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })

-- control configuration
vim.opt.tabstop = 4         -- size of a hard tabstop (ts)
vim.opt.shiftwidth = 4      -- size of an indentation (sw)
vim.opt.expandtab = true    -- use spaces instead of tab characters (et)
vim.opt.softtabstop = 4     -- number of spaces a <Tab> counts for in Insert mode (sts)
