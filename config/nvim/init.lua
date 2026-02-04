-----------------------------------------------------------
-- 基础设置
-----------------------------------------------------------
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
-- vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"

-----------------------------------------------------------
-- Lazy.nvim 插件管理器（官方主流）
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
 vim.fn.system({
   "git", "clone", "--filter=blob:none",
   "https://github.com/folke/lazy.nvim.git",
   "--branch=stable", lazypath
 })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- 插件列表
-----------------------------------------------------------
require("lazy").setup({

 -- 主题
 {
   "folke/tokyonight.nvim",
   lazy = false,
   priority = 1000,
   config = function()
     vim.cmd("colorscheme tokyonight")
   end,
 },

 -- 文件树
 {
   "nvim-tree/nvim-tree.lua",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("nvim-tree").setup({})
     vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
   end,
 },

 -- 模糊搜索
 {
   "nvim-telescope/telescope.nvim",
   dependencies = { "nvim-lua/plenary.nvim" },
   config = function()
     local builtin = require("telescope.builtin")
     vim.keymap.set("n", "<leader>ff", builtin.find_files)
     vim.keymap.set("n", "<leader>fg", builtin.live_grep)
     vim.keymap.set("n", "<leader>fb", builtin.buffers)
   end,
 },

 -- 状态栏
 {
   "nvim-lualine/lualine.nvim",
   config = function()
     require("lualine").setup({ options = { theme = "tokyonight" } })
   end,
 },

})

-----------------------------------------------------------
-- 常用快捷键
-----------------------------------------------------------
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

