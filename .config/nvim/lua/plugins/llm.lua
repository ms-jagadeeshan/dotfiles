return {
  {
    "ggml-org/llama.vim",
    init = function()
      vim.g.llama_config = {
        auto_fim = true,
        endpoint = "http://127.0.0.1:8081/infill",
        -- n_suffix = 128,
      }
    end,
  },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -- Recommended/example keymaps.
      vim.keymap.set(
        { "n", "x" },
        "<C-a>",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        { desc = "Ask opencode" }
      )
      vim.keymap.set(
        { "n", "x" },
        "<C-x>",
        function() require("opencode").select() end,
        { desc = "Execute opencode action…" }
      )
      vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

      vim.keymap.set(
        { "n", "x" },
        "go",
        function() return require("opencode").operator "@this " end,
        { expr = true, desc = "Add range to opencode" }
      )
      vim.keymap.set(
        "n",
        "goo",
        function() return require("opencode").operator "@this " .. "_" end,
        { expr = true, desc = "Add line to opencode" }
      )

      vim.keymap.set(
        "n",
        "<S-C-u>",
        function() require("opencode").command "session.half.page.up" end,
        { desc = "opencode half page up" }
      )
      vim.keymap.set(
        "n",
        "<S-C-d>",
        function() require("opencode").command "session.half.page.down" end,
        { desc = "opencode half page down" }
      )

      -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  },
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- this file can contain specific instructions for your project
      instructions_file = "avante.md",
      -- for example
      provider = "llamacpp",
      providers = {
        ollama = {
          model = "qwen2.5-coder:3b",
          -- is_env_set = require("avante.providers.ollama").check_endpoint_alive,
        },
        llamacpp = {
          __inherited_from = "ollama",
          endpoint = "http://127.0.0.1:8081",
          model = "ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
