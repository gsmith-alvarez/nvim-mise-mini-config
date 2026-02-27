--- [[ Mini.nvim: Notify ]]
--- Replaces vim.notify with a modern notification system.
local mini_notify = require('mini.notify')
mini_notify.setup()
vim.notify = mini_notify.make_notify()