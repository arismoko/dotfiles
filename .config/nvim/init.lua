if vim.env.DEVPOD == "true" then
  vim.g.clipboard = "osc52"
end

require("config.lazy")

if vim.env.DEVPOD == "true" then
  vim.opt.clipboard = "unnamedplus"
end
