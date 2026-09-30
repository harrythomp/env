vim.opt.termguicolors = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

vim.opt.signcolumn = "yes:1"

vim.opt.foldlevelstart = 99

vim.g.have_nerd_font = true

vim.opt.inccommand = 'split'

local function transparent_tabline()
    -- vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE", ctermbg = "NONE" })
    -- vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE", ctermbg = "NONE" })
end

transparent_tabline()
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = transparent_tabline,
})

vim.filetype.add({ extension = { templ = "templ" } })
