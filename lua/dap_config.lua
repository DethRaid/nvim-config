local mason_dap = require("mason-nvim-dap")
local dap = require("dap")
local ui = require("dapui")
local dap_virtual_text = require("nvim-dap-virtual-text")

-- Dap Virtual Text
dap_virtual_text.setup()

mason_dap.setup({
	ensure_installed = { "codelldb" },
	automatic_installation = true,
	handlers = {
		function(config)
			require("mason-nvim-dap").default_setup(config)
		end,
	},
})

-- Configurations
dap.configurations = {
	cpp = {
        {
	    	name = 'LLDB: Launch',
	    	type = 'codelldb',
	    	request = 'launch',
	    	program = function()
                local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
                if local_config then
                    local config = local_config()
                    return vim.fn.getcwd() .. '/' .. config.executable
                else
	    		    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end
	    	end,
	    	cwd = '${workspaceFolder}',
	    	stopOnEntry = false,
	    	args = {},
	    	console = 'integratedTerminal',
	    },
	    {
	    	name = 'LLDB: Launch (args)',
	    	type = 'codelldb',
	    	request = 'launch',
	    	program = function()
                local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
                if local_config then
                    local config = local_config()
                    return vim.fn.getcwd() .. '/' .. config.executable
                else
	    		    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end
	    	end,
	    	cwd = '${workspaceFolder}',
	    	stopOnEntry = false,
	    	args = function()
                local local_config = loadfile(vim.fn.getcwd() .. '/' .. 'launch.lua')
                if local_config then
                    local config = local_config()
                    return vim.split(config.args, ' +', { trimempty = true })
                else
	    		    return vim.split(vim.fn.input('Args: '), ' +', { trimempty = true })
                end
	    	end,
	    	console = 'integratedTerminal',
	    },
	},
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
    require("dap").continue()
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

