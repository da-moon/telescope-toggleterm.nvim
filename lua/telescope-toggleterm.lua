local M = {}
M.setup = function(opts) require('config').setup(opts) end
M.actions = require('lib.actions')
return M
