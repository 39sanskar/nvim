-- ================================================================================================
-- TITLE: NeoVim Keymaps
-- ABOUT: Quality-of-life keybindings for navigation, editing, buffers, splits, diagnostics & more
-- ================================================================================================

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core keymap function and options
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- =============================================================================
-- QUICK ACCESS & CONFIGURATION
-- =============================================================================

-- Keymap reloading utilities
vim.keymap.set("n", "<leader>rk", function()
    local keymaps_file = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"
    local success, err = pcall(vim.cmd, "source " .. keymaps_file)
    if success then
        print("Keymaps reloaded successfully!")
    else
        print("Error reloading keymaps: " .. err)
    end
end, { desc = "Reload keymaps" })

vim.keymap.set("n", "<leader>rc", function()
    local config_file = vim.fn.stdpath("config") .. "/init.lua"
    local success, err = pcall(vim.cmd, "source " .. config_file)
    if success then
        print("Config reloaded successfully!")
    else
        print("Error reloading config: " .. err)
    end
end, { desc = "Reload entire config" })


-- Reload Lazy plugins (proper way instead of full config reload)
keymap("n", "<leader>rl", "<cmd>Lazy reload<CR>", { desc = "Reload Lazy plugins" })
keymap("n", "<leader>rs", "<cmd>Lazy sync<CR>", { desc = "Sync Lazy plugins" })



-- =============================================================================
-- NAVIGATION IMPROVEMENTS
-- =============================================================================

-- Smart movement (respects line wrapping)
keymap("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })

keymap("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- Keep cursor centered during search and scrolling
keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- =============================================================================
-- SEARCH & HIGHLIGHTING
-- =============================================================================

-- Clear search highlights
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" }) -- Alternative

-- =============================================================================
-- TEXT EDITING & MANIPULATION
-- =============================================================================

-- Paste/delete without affecting clipboard register
keymap("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
keymap({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

-- Move lines and selections up/down
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting that keeps visual selection
keymap("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Join lines while keeping cursor position
keymap("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- =============================================================================
-- BUFFER MANAGEMENT
-- =============================================================================

-- Buffer navigation
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bq", ":bdelete<CR>", { desc = "Close buffer" })

-- General file operations
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================

-- Window navigation (Ctrl + hjkl)
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window splitting
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })

-- Window resizing (Arrow keys)
keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- =============================================================================
-- FILE EXPLORER
-- =============================================================================

-- Toggle NvimTree or Netrw
keymap("n", "<leader>e", function()
  -- Try to close Zen Mode first if open
  if package.loaded["zen-mode"] and require("zen-mode.view").is_open() then
    require("zen-mode").close()
  end

  -- Toggle NvimTree if available
  local nvim_tree_status, nvim_tree_api = pcall(require, "nvim-tree.api")
  if nvim_tree_status then
    if nvim_tree_api.tree.is_visible() then
      nvim_tree_api.tree.close()
    else
      nvim_tree_api.tree.open()
    end
  else
    -- Fallback to Netrw
    vim.cmd("Explore")
  end
end, { desc = "Toggle file explorer" })

-- Netrw alternatives (if using Netrw instead of NvimTree)
keymap("n", "<leader>HS", ":Hexplore<CR>", { desc = "Open Netrw in horizontal split" })
keymap("n", "<leader>VS", ":Vexplore<CR>", { desc = "Open Netrw in vertical split" })
keymap("n", "<leader>nt", ":Texplore<CR>", { desc = "Open Netrw in new tab" })
keymap("n", "<leader>wl", ":Lexplore<CR>", { desc = "Toggle left explorer window" })


-- =============================================================================
-- TAB MANAGEMENT
-- =============================================================================

-- Tab navigation
keymap("n", "L", ":tabn<CR>", { desc = "Next tab" })
keymap("n", "H", ":tabp<CR>", { desc = "Previous tab" })

-- Go to specific tabs (1-9)
for i = 1, 9 do
    keymap("n", "<leader>" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- =============================================================================
-- GIT INTEGRATION
-- =============================================================================

-- Git keymaps using gitsigns
keymap("n", "<leader>gg", function()
  local status_ok, gitsigns = pcall(require, "gitsigns")
  if status_ok then
    gitsigns.blame_line({ full = true })
  else
    print("Gitsigns not available")
  end
end, { desc = "Git blame line" })

keymap("n", "<leader>gB", function()
  local status_ok, gitsigns = pcall(require, "gitsigns")
  if status_ok then
    gitsigns.toggle_current_line_blame()
  else
    print("Gitsigns not available")
  end
end, { desc = "Toggle git blame" })

-- =============================================================================
-- DIAGNOSTICS & ERRORS
-- =============================================================================

-- Toggle diagnostics list for errors and warnings
local diagnostics_active = false
local diagnostics_augroup = vim.api.nvim_create_augroup("custom_diagnostics", { clear = true })

local function toggle_diagnostics()
    if diagnostics_active then
        -- Close the diagnostics float window
        vim.diagnostic.hide()
        vim.cmd("pclose")
        diagnostics_active = false
    else
        -- Open the diagnostics in a new window
        vim.diagnostic.setloclist()
        diagnostics_active = true

        -- Create an autocommand to allow copying to system clipboard from this window
        vim.api.nvim_create_autocmd("FileType", {
            group = diagnostics_augroup,
            pattern = "qf",
            callback = function()
                -- Enable copying to clipboard in the diagnostics window
                vim.opt_local.clipboard = "unnamedplus"

                -- Add a key mapping to close the window
                keymap("n", "q", ":pclose<CR>", { buffer = true, noremap = true, silent = true })
            end,
        })
    end
end

keymap("n", "<leader>xx", toggle_diagnostics, { desc = "Toggle diagnostics window" })

-- Additional diagnostic navigation
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
keymap("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Show diagnostic under cursor" })

-- =============================================================================
-- LANGUAGE-SPECIFIC
-- =============================================================================

-- Insert Go error check block
keymap("n", "<leader>qq", function()
  vim.api.nvim_put({
    "if err != nil {",
    '    log.Fatal("some error: ", err)',
    "}",
  }, "l", true, true)
end, { desc = "Insert Go err check" })

-- =============================================================================
-- INSERT MODE NAVIGATION
-- =============================================================================

-- Insert mode navigation with Insert key
keymap("i", "<Insert>", "<Right>", { desc = "Move right in insert mode" })
keymap("i", "<C-Insert>", "<Down>", { desc = "Move down in insert mode" })

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Copy full file path to system clipboard
keymap("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("File path copied to clipboard:", path)
end, { desc = "Copy full file path" })
