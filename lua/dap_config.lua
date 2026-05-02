local mason_dap = require("mason-nvim-dap")
local dap = require("dap")
local ui = require("dapui")
local dap_virtual_text = require("nvim-dap-virtual-text")

-- Dap Virtual Text
dap_virtual_text.setup()

mason_dap.setup({
    ensure_installed = { "codelldb", "firefox", },
    automatic_installation = true,
    handlers = {
        function(config)
            require("mason-nvim-dap").default_setup(config)
        end,
    },
})

local get_executable = function()
    local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
    if local_config then
        local config = local_config()
        return vim.fn.getcwd() .. '/' .. config.executable
    else
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end
end

local get_args = function()
    local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
    if local_config then
        local config = local_config()
        return vim.split(config.args, ' +', { trimempty = true })
    else
        return vim.split(vim.fn.input('Args: '), ' +', { trimempty = true })
    end
end

local get_addr = function()
    local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
    local uri = ""
    if local_config then
        local config = local_config()
        if config.remote_addr then
            uri = config.remote_addr
        end
    end
    if uri == "" then
        uri = vim.fn.input('[host]:port : ')
    end
    if uri:find('^%d+$') == 1 then
        uri = 'localhost:' .. uri
    elseif uri:find(':', nil, true) == 1 then
        uri = 'localhost' .. uri
    end
    return uri
end

-- Configurations
dap.configurations = {
    cpp = {
        {
            name = 'LLDB: Launch',
            type = 'codelldb',
            request = 'launch',
            program = get_executable,
            cwd = function()
                return vim.fn.getcwd()
            end,
            args = get_args,
            console = 'integratedTerminal',
        },
        {
            name = 'Attach to gdbserver (port)',
            type = 'cppdbg',
            request = 'launch',
            MIMode = 'gdb',
            miDebuggerServerAddress = get_addr,
            miDebuggerPath = vim.fn.exepath('gdb'),
            cwd = '${workspaceFolder}',
            args = get_args,
            program = get_executable,
        },
    },
    firefox = {
        {
            name = 'Firefox: Debug',
            type = 'firefox',
            request = 'launch',
            reAttach = true,
            url = function()
                return vim.fn.input('Url to debug : ')
            end,
            webRoot = '${workspaceFolder}',
            firefoxExecutable = vim.fn.exepath('firefox'),
        },
    }
}

-- Dap UI

ui.setup()

vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

dap.listeners.before.attach.dapui_config = function()
    ui.open()
end
dap.listeners.before.launch.dapui_config = function()
    ui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    ui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    ui.close()
end

-- setup hotkeys
local keymap = vim.keymap

keymap.set("n", "<F5>", function()
    local dap = require("dap")
    if dap.session() == nil then
        local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
        if local_config then
            local config = local_config()
            if config.build_command then
                vim.fn.execute(config.build_command)
            end
        end
    end

    dap.continue()
end, {
    desc = "continue"
})
keymap.set("n", "<F9>", function()
    require("dap").toggle_breakpoint()
end, {
    desc = "toggle breakpoint",
})
keymap.set("n", "<F10>", function()
    require("dap").step_over()
end, {
    desc = "step over"
})
keymap.set("n", "<F11>", function()
    require("dap").step_into()
end, {
    desc = "step into"
})
keymap.set("n", "<S-F11>", function()
    require("dap").step_out()
end, {
    desc = "step out of"
})
keymap.set("n", "<leader>dq", function()
    require("dap").terminate()
    require("dapui").close()
    require("nvim-dap-virtual-text").toggle()
end, {
    desc = "quit debugger"
})

