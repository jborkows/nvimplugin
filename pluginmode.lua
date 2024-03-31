local logger = require("plenary.log"):new()
logger.level = "debug"
local pluginModeGroup = vim.api.nvim_create_augroup("plugin-mode-jb", { clear = true })

local M = {}
vim.api.nvim_create_user_command("PluginMode", function()
	logger.debug(vim.api.nvim_buf_get_name(0))
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = pluginModeGroup,
		buffer = 0,
		callback = function()
			vim.schedule(function()
				logger.debug("Save completed")
				vim.cmd { cmd = "source", args = {"%"}}
				logger.debug("Reloaded ->" .. vim.api.nvim_buf_get_name(0))
			end)
		end
	})
end, {})

return M
