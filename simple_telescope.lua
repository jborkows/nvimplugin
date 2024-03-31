local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local previewers = require('telescope.previewers')
local utils = require('telescope.previewers.utils')

local logger = require("plenary.log"):new()
logger.level = "debug"
local M = {
	show = function(opts)
		pickers.new(opts, {
			prompt_title = 'Simple Telescope',
			finder = finders.new_table {
				results = {
					{ name = 'one',   some = { 'A', 'B', 'C' } },
					{ name = 'two',   some = { 'A', 'C' } },
					{ name = 'three', some = { 'A', 'B', } },
					{ name = 'four',  some = {} },
				},

				entry_maker = function(entry)
					if not entry then
						return
					end
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name .. ':' .. table.concat(entry.some, ': '),
					}
				end,
			},
			sorter = config.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local failed = pcall(function()
						local selection = actions.get_selected_entry()
						logger.debug('Selected: ' .. selection)
					end)
					if failed then
						logger.debug('Failed to get selected entry')
					end
					actions.close(prompt_bufnr)
				end)
				return true
			end,
			previewer = previewers.new_buffer_previewer({
				title = 'My details',
				define_preview = function(self, entry)
					if not entry then
						return
					end
					local searcher = entry.value
					if not searcher.name then
						return
					end
					local formatted = {
						'# ' .. searcher.name,
						'',
						'*ID*: ' .. searcher.name,
						'*Tags*: ' .. table.concat(searcher.some, ', '),
					}
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, formatted)
					utils.highlighter(self.state.bufnr, 'markdown')
				end,
			}),
		}):find()
	end
}


M.show()

return M
