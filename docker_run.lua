local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')

local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local utils = require('telescope.previewers.utils')

local logger = require("plenary.log"):new()
local plenary = require('plenary')
logger.level = "debug"
local M={}
M._make_docker_command = function(args)
    local job_opts = {
        command = 'docker',
        args = vim.tbl_flatten { args, '--format', 'json' },
    }
    logger.info('Running job', job_opts)
    local job = plenary.job:new(job_opts):sync()
    logger.info('Ran job', vim.inspect(job))
    return job
end

M.docker_images = function(opts)
    pickers
        .new(opts, {
            finder = finders.new_dynamic({
                fn = function()
                    return M._make_docker_command { 'images' }
                end,

                entry_maker = function(entry)
                    local image = vim.json.decode(entry)
                    logger.debug('Calling entry maker', image)
                    if image then
                        return {
                            value = image,
                            display = image.Repository,
                            ordinal = image.Repository,
                        }
                    end
                end,
            }),

            sorter = config.generic_sorter(opts),

            previewer = previewers.new_buffer_previewer({
                title = 'Image Details',
                define_preview = function(self, entry)
                    local formatted = {
                        '# ' .. entry.display,
                        '',
                        '*ID*: ' .. entry.value.ID,
                        '*Tag*: ' .. entry.value.Tag,
                        '*Containers*: ' .. entry.value.Containers,
                        '*Digest*: ' .. entry.value.Digest,
                        '',
                        '*CreatedAt*: ' .. entry.value.CreatedAt,
                        '*CreatedSince*: ' .. entry.value.CreatedSince,
                        '',
                        '*SharedSize*: ' .. entry.value.SharedSize,
                        '*Size*: ' .. entry.value.Size,
                        '*UniqueSize*: ' .. entry.value.UniqueSize,
                        '*VirtualSize*: ' .. entry.value.VirtualSize,
                    }
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, formatted)
                    utils.highlighter(self.state.bufnr, 'markdown')
                end,
            }),

            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    logger.debug('Selected', selection)
                    local command = {
                        'edit',
                        'term://docker',
                        'run',
                        '-it',
						'--rm',
                        selection.value.Repository,
                    }
                    logger.debug('Running', command)
                    vim.cmd(vim.fn.join(command, ' '))
                end)
                return true
            end,
        })
        :find()
end



M.docker_images()

return M
