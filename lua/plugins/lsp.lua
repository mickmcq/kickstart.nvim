return {

  { -- for lsp features in code cells / embedded code
    'jmbuhr/otter.nvim',
    dev = false,
    ft = { 'quarto', 'markdown', 'rmd' },
    dependencies = {
      {
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
      },
    },
    opts = {},
  },

  { -- Mason loads deferred (after startup) so it doesn't block opening files.
    -- Tools are already installed; this just lets `:Mason` work and re-checks
    -- ensure_installed in the background.
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog', 'MasonUpdate', 'MasonToolsInstall', 'MasonToolsUpdate' },
    event = 'VeryLazy',
    dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    config = function()
      require('mason').setup {}
      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua-language-server',
          'bash-language-server',
          'css-lsp',
          'html-lsp',
          'json-lsp',
          'haskell-language-server',
          'pyright',
          'r-languageserver',
          'texlab',
          'dotls',
          'svelte-language-server',
          'typescript-language-server',
          'yaml-language-server',
          'clangd',
          'emmet-ls',
          'sqlls',
          'black',
          'stylua',
          'shfmt',
          'isort',
          'tree-sitter-cli',
          'jupytext',
        },
      }
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspStart', 'LspStop', 'LspRestart' },
    dependencies = {
      { 'williamboman/mason-lspconfig.nvim' },
      { -- nice loading notifications
        -- PERF: but can slow down startup
        'j-hui/fidget.nvim',
        enabled = false,
        opts = {},
      },
      {
        {
          'folke/lazydev.nvim',
          ft = 'lua', -- only load on lua files
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
          },
        },
        { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
      },
      { 'folke/neoconf.nvim', opts = {}, enabled = false },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, 'LSP client not found')

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          map('gd', vim.lsp.buf.definition, '[g]o to [d]efinition')
          map('gD', vim.lsp.buf.type_definition, '[g]o to type [D]efinition')
          map('<leader>lq', vim.diagnostic.setqflist, '[l]sp diagnostic [q]uickfix')
        end,
      })

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }

      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      -- capabilities.textDocument.completion.completionItem.snippetSupport = true
      local capabilities = require('blink.cmp').get_lsp_capabilities({}, true)

      -- also needs:
      -- $home/.config/marksman/config.toml :
      -- [core]
      -- markdown.file_extensions = ["md", "markdown", "qmd"]
      -- lspconfig.marksman.setup {
      --   capabilities = capabilities,
      --   filetypes = { 'markdown', 'quarto' },
      --   root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
      -- }

      -- Optional: your shared defaults (merged into every server)
      vim.lsp.config('*', {
        capabilities = capabilities,   -- e.g. from cmp_nvim_lsp
        on_attach = on_attach,         -- your keymaps, etc.
      })

      vim.lsp.config('cssls', {
      capabilities = capabilities,
      flags = lsp_flags,
    })

    vim.lsp.enable('cssls')


      -- lspconfig.html.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      -- lspconfig.emmet_language_server.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      vim.lsp.config('svelte', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('svelte')

        vim.lsp.config('yamlls', {
          capabilities = capabilities,
          flags = lsp_flags,
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
                url = '',
              },
            },
          },
        })

      vim.lsp.enable('yamlls')

      vim.lsp.config('jsonls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('jsonls')

      vim.lsp.config('texlab', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('texlab')

      vim.lsp.config('dotls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('dotls')

      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'js', 'javascript', 'typescript', 'ojs' },
      })

      vim.lsp.enable('ts_ls')

      -- NOTE: Quarto resource path lookup is now lazy to avoid blocking startup
      -- It will be computed on first use when lua_ls attaches
      local quarto_resource_path_cache = nil
      local function get_quarto_resource_path()
        if quarto_resource_path_cache ~= nil then
          return quarto_resource_path_cache
        end
        local function strsplit(s, delimiter)
          local result = {}
          for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
            table.insert(result, match)
          end
          return result
        end
        local ok, handle = pcall(io.popen, 'quarto --paths 2>/dev/null', 'r')
        if not ok or not handle then
          quarto_resource_path_cache = false
          return false
        end
        local s = handle:read '*a'
        handle:close()
        local path = strsplit(s or '', '\n')[2]
        quarto_resource_path_cache = path or false
        return quarto_resource_path_cache
      end

      -- Defer quarto path lookup - lua_ls works fine without it initially
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            runtime = {
              version = 'LuaJIT',
              -- plugin = lua_plugin_paths, -- handled by lazydev
            },
            diagnostics = {
              disable = { 'trailing-space' },
            },
            workspace = {
              -- library = lua_library_files, -- handled by lazydev
              checkThirdParty = false,
            },
            doc = {
              privateName = { '^_' },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.enable('lua_ls')

      vim.lsp.config('vimls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('vimls')

      vim.lsp.config('julials', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('julials')

      vim.lsp.config('bashls', {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'sh', 'bash' },
      })

      vim.lsp.enable('bashls')

      -- Add additional languages here.
      -- See `:h lspconfig-all` for the configuration.
      -- Like e.g. Haskell:
      -- lspconfig.hls.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   filetypes = { 'haskell', 'lhaskell', 'cabal' },
      -- }

      vim.lsp.config('clangd', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('clangd')

      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.enable('rust_analyzer')

      -- r_language_server (Neovim 0.11+)
      vim.lsp.config('r_language_server', {
        -- Keep Quarto handled by otter: only attach to R/Rmd/Rmarkdown buffers
        filetypes = { 'r', 'rmd', 'rmarkdown', 'quarto' },

        -- If you had flags before, they still work here
        flags = lsp_flags,

        -- Project root detection (common for R projects)
        -- Neovim will derive root_dir from these markers via vim.fs.root()
        root_markers = { '.Rproj', 'DESCRIPTION', '.git' },

        -- Server settings (same as your old config)
        settings = {
          r = {
            lsp = {
              rich_documentation = true,
              -- keep other r_language_server settings here if you use them
            },
          },
        },

        -- Optional: explicit command if you need it (usually auto-detected)
        -- cmd = { vim.fn.exepath('R'), '--slave', '-e', 'languageserver::run()' },

        -- Optional: start for single-file scripts not in a project
        single_file_support = true,
      })

      -- Enable it (will attach automatically on matching filetypes)
      vim.lsp.enable('r_language_server')


      -- lspconfig.ruff_lsp.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      -- Too lags on linux for python projects
      -- because pyright and nvim both create too many watchers otherwise
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Define/extend a server’s config (optional)
      vim.lsp.config('pyright', {
        -- e.g. capabilities, settings, root markers, etc.
        settings = { python = { analysis = { typeCheckingMode = "basic" } } },
        -- You can let Nvim find the project root using markers:
        root_markers = { 'pyproject.toml', 'setup.py', '.git' },
      })

      -- Enable the server for its filetypes
      vim.lsp.enable('pyright')

    end,
  },
}
