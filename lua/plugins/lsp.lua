-- LSP Configuration & Plugins
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      },
      { "j-hui/fidget.nvim" },
      "folke/neodev.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "stevearc/conform.nvim",
      "elixir-tools/elixir-tools.nvim"
    },
    config = function()
      -- Set up Mason before anything else
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          'jsonls',
          'tailwindcss',
          'cssls',
          'html',
          'svelte',
          "prismals",
          "astro"
        },
        automatic_installation = true,
      })

      -- Neodev setup before LSP config
      require("neodev").setup()

      -- Turn on LSP status information
      require("fidget").setup({
        -- sources = {
        --   ["null-ls"] = { ignore = true, },
        -- },
        -- window = {
        --   blend = 0,
        -- },
      })

      -- Set up cool signs for diagnostics
      local icons = require("core.icons")
      local signs = {
        Error = icons.diagnostics.Error,
        Warn = icons.diagnostics.Warning,
        Hint = icons.diagnostics.Hint,
        Info = icons.diagnostics.Information,
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Diagnostic config
      local config = {
        virtual_text = { prefix = "●" },
        signs = { active = signs, },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      }
      vim.diagnostic.config(config)

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

      vim.lsp.handlers["textDocument/signatureHelp"] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

      vim.lsp.handlers["textDocument/publishDiagnostics"] =
          vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            underline = true,
            update_in_insert = true,
            virtual_text = { spacing = 4, prefix = "●" },
            severity_sort = true,
          })

      local on_attach = function(_, bufnr)
        local lsp_map = require("helpers.keys").lsp_map

        local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
        if
            filetype == "typescript"
            or filetype == "typescriptreact"
            or filetype == "typescript.tsx"
            or filetype == "javascript"
            or filetype == "javascriptreact"
        then
          lsp_map("gd", require("typescript-tools.api").go_to_source_definition, bufnr)
        else
          lsp_map("gd", vim.lsp.buf.definition, bufnr)
        end

        lsp_map("K", vim.lsp.buf.hover, bufnr)

        lsp_map("gT", vim.lsp.buf.type_definition, bufnr)
        lsp_map("gD", vim.lsp.buf.declaration, bufnr)
        lsp_map("gi", vim.lsp.buf.implementation, bufnr)
        lsp_map("gr", vim.lsp.buf.references, bufnr)

        lsp_map("<leader>cs", vim.lsp.buf.signature_help, bufnr)
        lsp_map("<leader>cr", vim.lsp.buf.rename, bufnr)
        lsp_map("<leader>cl", vim.lsp.codelens.run, bufnr)
        vim.keymap.set({ "n", "x", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })

        lsp_map("<leader>i", vim.lsp.buf.incoming_calls, bufnr)
        lsp_map("<leader>o", vim.lsp.buf.outgoing_calls, bufnr)
        lsp_map(
          "<leader>ff",
          function()
            require("conform").format({
              bufnr = bufnr,
              async = true,
              lsp_fallback = true,
            })
          end,
          bufnr
        )

        lsp_map("[d", vim.diagnostic.goto_prev, bufnr)
        lsp_map("]d", vim.diagnostic.goto_next, bufnr)
        lsp_map("<leader>vd", vim.diagnostic.open_float, bufnr)
      end

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)


      local lsps = {
        'jsonls',
        'tailwindcss',
        'cssls',
        'html',
        'svelte',
        "prismals",
        "astro",
        "ocamllsp",
        "pylsp",
        "gleam",
        "marksman"
      }
      for _, lsp in ipairs(lsps) do
        require("lspconfig")[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities
        })
      end

      require("lspconfig")["lua_ls"].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      })

      require("typescript-tools").setup({
        on_attach = on_attach,
        settings = { publish_diagnostic_on = "insert_leave" },
      })

      require("lspconfig")["rust_analyzer"].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { "rustup", "run", "nightly", "rust-analyzer" },
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
          },
        },
      })

      require("elixir").setup({
        elixirls = { on_attach = on_attach },
      })

      vim.g.haskell_tools = {
        ---@type ToolsOpts
        tools = {
          hover = { enable = false },
        },
        ---@type HaskellLspClientOpts
        hls = {
          on_attach = on_attach
        },
        ---@type HTDapOpts
        dap = {},
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").formatters.stylish_haskell = {
        inherit = false,
        command = "stylish-haskell",
        args = { "$FILENAME" },
        stdin = true,
      }

      require("conform").setup({
        log_level = vim.log.levels.TRACE,
        formatters_by_ft = {
          ["javascript"] = { { "prettierd", "prettier" } },
          ["javascriptreact"] = { { "prettierd", "prettier" } },
          ["typescript"] = { { "prettierd", "prettier" } },
          ["typescriptreact"] = { { "prettierd", "prettier" } },
          ["vue"] = { { "prettierd", "prettier" } },
          ["css"] = { { "prettierd", "prettier" } },
          ["scss"] = { { "prettierd", "prettier" } },
          ["less"] = { { "prettierd", "prettier" } },
          ["html"] = { { "prettierd", "prettier" } },
          ["json"] = { { "prettierd", "prettier" } },
          ["jsonc"] = { { "prettierd", "prettier" } },
          ["yaml"] = { { "prettierd", "prettier" } },
          -- ["markdown"] = { { "prettierd", "prettier" } },
          -- ["markdown.mdx"] = { { "prettierd", "prettier" } },
          ["graphql"] = { { "prettierd", "prettier" } },
          ["handlebars"] = { { "prettierd", "prettier" } },
          -- ["haskell"] = { "fourmolu", "stylish_haskell" }
          ["haskell"] = { "fourmolu" },
          python = { "ruff_format", "ruff_fix" },
        },
      }
      )
    end
  },
  { 'dmmulroy/ts-error-translator.nvim', config = true },
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3', -- Recommended
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  }
}
