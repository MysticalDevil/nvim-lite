local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<space>", "<nop>", opts)

-- Magic search logic from nvim
local enable_magic_search = true
if enable_magic_search then
  keymap({ "n", "v" }, "/", "/\\v", { remap = false, silent = false })
else
  keymap({ "n", "v" }, "/", "/", { remap = false, silent = false })
end

keymap("i", "<C-b>", "<ESC>^i", { desc = "Begging of line" })
keymap("i", "<C-e>", "<End>", { desc = "End of line" })
keymap("i", "<C-h>", "<Left>", { desc = "Move left" })
keymap("i", "<C-l>", "<Right>", { desc = "Move right" })
keymap("i", "<C-j>", "<Down>", { desc = "Move down" })
keymap("i", "<C-k>", "<Up>", { desc = "Move up" })

keymap("n", "<Esc>", "<cmd> noh <CR>", { desc = "Clear highlights" })
keymap("n", "<C-d>", "10j", { desc = "Ten lines down" })
keymap("n", "<C-u>", "10k", { desc = "Ten lines up" })

keymap("n", "<C-h>", "<C-w>h", { desc = "Window left" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Window right" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Window down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Window up" })

keymap("n", "<leader><leader>n", "<cmd> set nu! <CR>", { desc = "Toggle line number" })
keymap("n", "<leader><leader>rn", "<cmd> set rnu! <CR>", { desc = "Toggle relative number" })

keymap("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })
keymap("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
keymap("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
keymap("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })

keymap("n", "<leader>bf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

keymap("n", "<leader>bn", "<cmd> enew <CR>", { desc = "New buffer" })

keymap("n", "<leader>wv", ":vsp<CR>", { desc = "Split window vertically" })
keymap("n", "<leader>wh", ":sp<CR>", { desc = "Split window horizontally" })
keymap("n", "<leader>wc", "<C-w>c", { desc = "Close picked split window" })
keymap("n", "<leader>wo", "<C-w>o", { desc = "Close other split window" })
keymap("n", "<leader>w,", ":vertical resize -10<CR>", { desc = "Reduce vertical window size" })
keymap("n", "<leader>w.", ":vertical resize +10<CR>", { desc = "Increase vertical window size" })
keymap("n", "<leader>wj", ":horizontal resize -5<CR>", { desc = "Reduce horizontal window size" })
keymap("n", "<leader>wk", ":horizontal resize +5<CR>", { desc = "Increase vertical window size" })
keymap("n", "<leader>w=", "<C-w>=", { desc = "Make split windows equal in size" })

keymap("n", "<leader><Tab>s", "<cmd>tab split<CR>", { desc = "Split window use tab" })
keymap("n", "<leader><Tab>h", "<cmd>tabprev<CR>", { desc = "Switch to previous tab" })
keymap("n", "<leader><Tab>j", "<cmd>tabnext<CR>", { desc = "Switch to next tab" })
keymap("n", "<leader><Tab>f", "<cmd>tabfirst<CR>", { desc = "Switch to first tab" })
keymap("n", "<leader><Tab>l", "<cmd>tablast<CR>", { desc = "Switch to last tab" })
keymap("n", "<leader><Tab>c", "<cmd>tabclose<CR>", { desc = "Close tab" })

keymap("n", "zo", "<CMD>foldopen<CR>", { desc = "Open fold" })
keymap("n", "zc", "<CMD>foldclose<CR>", { desc = "Close fold" })

keymap("t", "<ESC>", "<C-\\><C-n>", { desc = "Back to normal mode" })
keymap("t", "<C-x>", vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), { desc = "Escape terminal mode" })

keymap("v", "<C-j>", "5j", { desc = "Five lines down" })
keymap("v", "<C-k>", "5k", { desc = "Five lines up" })
keymap("v", "<C-d>", "10j", { desc = "Ten lines down" })
keymap("v", "<C-u>", "10k", { desc = "Ten lines up" })
keymap("v", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
keymap("v", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })
keymap("v", "<", "<gv", { desc = "Indent line" })
keymap("v", ">", ">gv", { desc = "Indent line" })

keymap("x", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })
keymap("x", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
keymap("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { silent = true, desc = "Dont copy replaced text" })
