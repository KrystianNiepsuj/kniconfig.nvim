return {
  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = '',
          declaration = '',
          expression = '',
          specifier = '',
          statement = '',
          ['template argument'] = '',
        },
        kind_icons = {
          Compound = '',
          Recovery = '',
          TranslationUnit = '',
          PackExpansion = '',
          TemplateTypeParm = '',
          TemplateTemplateParm = '',
          TemplateParamObject = '',
        },
      },
    },
  },
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Breakpoint Condition',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle Breakpoint',
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Run/Continue',
      },
      {
        '<leader>da',
        function()
          require('dap').continue { before = get_args }
        end,
        desc = 'Run with Args',
      },
      {
        '<leader>dC',
        function()
          require('dap').run_to_cursor()
        end,
        desc = 'Run to Cursor',
      },
      {
        '<leader>dg',
        function()
          require('dap').goto_()
        end,
        desc = 'Go to Line (No Execute)',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'Step Into',
      },
      {
        '<leader>dj',
        function()
          require('dap').down()
        end,
        desc = 'Down',
      },
      {
        '<leader>dk',
        function()
          require('dap').up()
        end,
        desc = 'Up',
      },
      {
        '<leader>dl',
        function()
          require('dap').run_last()
        end,
        desc = 'Run Last',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        desc = 'Step Out',
      },
      {
        '<leader>dO',
        function()
          require('dap').step_over()
        end,
        desc = 'Step Over',
      },
      {
        '<leader>dP',
        function()
          require('dap').pause()
        end,
        desc = 'Pause',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'Toggle REPL',
      },
      {
        '<leader>ds',
        function()
          require('dap').session()
        end,
        desc = 'Session',
      },
      {
        '<leader>dt',
        function()
          require('dap').terminate()
        end,
        desc = 'Terminate',
      },
      {
        '<leader>dw',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = 'Widgets',
      },
    },
    config = function()
      local dap = require 'dap'

      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
          args = { '--port', '${port}' },
        },
      }

      -- Auto-detect build command based on project files
      local function get_build_command()
        local cwd = vim.fn.getcwd()
        if vim.fn.filereadable(cwd .. '/Makefile') == 1 then
          return 'make'
        elseif vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
          return 'cmake --build build'
        elseif vim.fn.filereadable(cwd .. '/build.sh') == 1 then
          return './build.sh'
        end
        return nil
      end

      -- Store last used paths to avoid re-entering
      local last_program = nil
      local last_build_cmd = nil

      dap.configurations.c = {
        {
          name = 'Launch',
          type = 'codelldb',
          request = 'launch',
          program = function()
            local default = last_program or vim.fn.getcwd() .. '/'
            last_program = vim.fn.input('Path to executable: ', default, 'file')
            return last_program
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          stopAtEntry = false,
          terminal = 'integrated',
        },
        {
          name = 'Build and Launch',
          type = 'codelldb',
          request = 'launch',
          program = function()
            -- Get or prompt for build command
            local build_cmd = last_build_cmd or get_build_command()
            if not build_cmd then
              build_cmd = vim.fn.input('Build command: ', 'make', 'shellcmd')
              last_build_cmd = build_cmd
            end

            -- Build the project
            vim.notify('Running: ' .. build_cmd, vim.log.levels.INFO)
            local result = vim.fn.system(build_cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify('Build failed:\n' .. result, vim.log.levels.ERROR)
              return nil
            end
            vim.notify('Build succeeded', vim.log.levels.INFO)

            -- Get executable path
            local default = last_program or vim.fn.getcwd() .. '/'
            last_program = vim.fn.input('Path to executable: ', default, 'file')
            return last_program
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          stopAtEntry = false,
          terminal = 'integrated',
        },
      }

      dap.configurations.cpp = dap.configurations.c
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
  -- stylua: ignore
  keys = {
    { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
    { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "x"} },
  },
    opts = {
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'right',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
    },
    config = function(_, opts)
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup(opts)
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open {}
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close {}
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close {}
      end
    end,
  },
}
