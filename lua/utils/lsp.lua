-- ================================================================================================
-- TITLE: LSP Configuration Utility
-- ABOUT: Centralized LSP on_attach function with keymaps and DAP integration
-- AUTHOR: Your Neovim Configuration
-- ================================================================================================

-- Disable ONLY jdtls progress notifications (FINAL FIX)
vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)

    -- Ignore jdtls spam (Validate documents, Publish Diagnostics, etc.)
    if client and client.name == "jdtls" then
        return
    end

    -- fallback: do nothing for others as well (silent)
end

-- OPTIONAL: comment this if you want normal notifications
-- vim.notify = function() end

local M = {}

-- Enhanced LSP keymappings
-- This function is called when an LSP client attaches to a buffer
-- It sets up all the keymaps and configurations for that specific buffer
M.on_attach = function(event)
    -- Get the client object from the event data
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
        print("LSP: No client found for attachment")
        return
    end
    
    -- Get buffer number from event
    local bufnr = event.buf
    
    -- Setup keymap function and options
    local keymap = vim.keymap.set
    local opts = {
        noremap = true,  -- Prevent recursive mapping
        silent = true,   -- Don't print the command to the command line
        buffer = bufnr,  -- Restrict the keymap to the current buffer only
    }

    -- ============================================================================
    -- LSP KEYMAPS WITH ENHANCED UI PLUGINS
    -- ============================================================================

    -- Check if Lspsaga plugin is available for enhanced UI experience
    local has_lspsaga, _ = pcall(require, "lspsaga")
    
    if has_lspsaga then
        -- Lspsaga enhanced keymaps (better UI and UX)
        keymap("n", "<leader>gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- Peek at definition in popup
        keymap("n", "<leader>gD", "<cmd>Lspsaga goto_definition<CR>", opts) -- Go to definition
        keymap("n", "<leader>gS", "<cmd>vsplit | Lspsaga goto_definition<CR>", opts) -- Definition in vertical split
        keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- Code actions menu with preview
        keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- Rename symbol with preview
        keymap("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- Show line diagnostics in float
        keymap("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- Show cursor diagnostics
        keymap("n", "<leader>pd", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- Jump to previous diagnostic
        keymap("n", "<leader>nd", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- Jump to next diagnostic
        keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- Hover documentation with enhanced display
    else
        -- Fallback to native LSP keymaps when Lspsaga is not available
        
        -- Navigation keymaps
        keymap('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        keymap('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        keymap('n', 'gr', vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
        keymap('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        keymap('n', 'gt', vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

        -- Documentation and help
        keymap('n', 'K', vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show hover documentation" }))
        keymap('n', '<C-k>', vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Show signature help" }))

        -- Code actions and refactoring
        keymap('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
        keymap('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
        keymap('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, vim.tbl_extend("force", opts, { desc = "Format document" }))
    end

    -- ============================================================================
    -- FUZZY FINDING WITH FZF-LUA (IF AVAILABLE)
    -- ============================================================================

    -- FzfLua keymaps for enhanced searching capabilities
    local has_fzf_lua, _ = pcall(require, "fzf-lua")
    if has_fzf_lua then
        keymap("n", "<leader>fd", "<cmd>FzfLua lsp_finder<CR>", opts) -- LSP Finder (definition + references)
        keymap("n", "<leader>fr", "<cmd>FzfLua lsp_references<CR>", opts) -- Show all references to the symbol
        keymap("n", "<leader>ft", "<cmd>FzfLua lsp_typedefs<CR>", opts) -- Jump to type definition
        keymap("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", opts) -- Symbols in current file
        keymap("n", "<leader>fw", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts) -- Symbols across workspace
        keymap("n", "<leader>fi", "<cmd>FzfLua lsp_implementations<CR>", opts) -- Go to implementation
    end

    -- ============================================================================
    -- WORKSPACE MANAGEMENT
    -- ============================================================================

    -- Workspace folder management keymaps
    keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
    keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
    keymap('n', '<leader>wl', function()
        -- Print list of workspace folders to command line for debugging
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))

    -- ============================================================================
    -- LANGUAGE-SPECIFIC FEATURES
    -- ============================================================================

    -- Order Imports feature (supported by some language servers like TypeScript, Go)
    -- Checks if the current LSP client supports the organizeImports code action
    if client.supports_method and client:supports_method("textDocument/codeAction") then
        keymap("n", "<leader>oi", function()
            -- Execute organize imports code action
            vim.lsp.buf.code_action({
                context = {
                    only = { "source.organizeImports" },  -- Only perform organize imports action
                    diagnostics = {},  -- No specific diagnostics needed
                },
                apply = true,  -- Apply the action immediately
                bufnr = bufnr,  -- Apply to current buffer
            })
            -- Format the document after organizing imports for consistency
            vim.defer_fn(function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end, 50) -- Small delay (50ms) to ensure imports are organized first
        end, opts)
    end

    -- ============================================================================
    -- DEBUGGING WITH DAP (DEBUG ADAPTER PROTOCOL)
    -- ============================================================================

    -- DAP keymaps specifically for Rust debugging (rust-analyzer)
    -- Only activate when using rust-analyzer LSP client
    if client.name == "rust_analyzer" then
        -- Check if DAP plugin is available
        local has_dap, dap = pcall(require, "dap")
        if has_dap then
            -- Debugging control keymaps
            keymap("n", "<leader>dc", dap.continue, opts) -- Continue / Start debugging session
            keymap("n", "<leader>do", dap.step_over, opts) -- Step over current line
            keymap("n", "<leader>di", dap.step_into, opts) -- Step into function call
            keymap("n", "<leader>du", dap.step_out, opts) -- Step out of current function
            keymap("n", "<leader>db", dap.toggle_breakpoint, opts) -- Toggle breakpoint at cursor
            keymap("n", "<leader>dr", dap.repl.open, opts) -- Open DAP REPL for interactive debugging
        else
            print("DAP not available - debugging features disabled")
        end
    end
    
    -- Print success message for debugging
    print("LSP attached successfully for client: " .. client.name .. " (Buffer: " .. bufnr .. ")")
end

-- ============================================================================
-- LSP CAPABILITIES FOR COMPLETION ENGINES
-- ============================================================================

-- Get LSP capabilities enhanced for nvim-cmp completion engine
-- This ensures that completion engines work properly with LSP features
M.get_capabilities = function()
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        -- Return capabilities enhanced for cmp completion
        return cmp_nvim_lsp.default_capabilities()
    else
        -- Fallback to basic LSP capabilities if cmp is not available
        print("nvim-cmp not found, using basic LSP capabilities")
        return vim.lsp.protocol.make_client_capabilities()
    end
end


return M




