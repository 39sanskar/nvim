-- ================================================================================================
-- TITLE: Mason & LSP Configuration
-- ABOUT: Setup LSP servers with Mason and configure keymaps
-- ================================================================================================

return {
  -- Plugin specification for Lazy
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  event = "BufReadPre", -- Load when opening files
  build = ":MasonUpdate", -- Runs MasonUpdate when the plugin is installed/updated
  config = function()
    -- Import our LSP utility functions
    local lsp_utils = require("utils.lsp")

    -- Setup Mason (plugin manager for LSP servers)
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        },
      },
    })

    -- Get LSP capabilities enhanced for completion
    local capabilities = lsp_utils.get_capabilities()

    -- Configure mason-lspconfig (connects Mason with lspconfig)
    require("mason-lspconfig").setup({
      automatic_installation = true, -- Auto-install LSP servers
      ensure_installed = {}, -- List specific servers to always install (empty = install as needed)
      handlers = {
        -- Default handler for all LSP servers
        function(server_name)
          -- Setup each LSP server with our custom on_attach function
          -- 🚫 Skip Java completely
          if server_name == "jdtls" then
            return
          end
          
          require("lspconfig")[server_name].setup({
            on_attach = lsp_utils.on_attach, -- Our custom keymaps and config
            capabilities = capabilities,     -- Enhanced completion capabilities
          })
        end,
      },
    })

    -- Optional: Add a command to check active LSP clients
    vim.api.nvim_create_user_command("LspInfo", function()
      local clients = vim.lsp.get_active_clients()
      if #clients == 0 then
        print("No active LSP clients")
        return
      end

      print("Active LSP clients:")
      for _, client in ipairs(clients) do
        print("  - " .. client.name .. " (ID: " .. client.id .. ")")
      end
    end, { desc = "Show active LSP clients" })
  end
}

