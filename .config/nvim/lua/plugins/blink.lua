return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }
      opts.keymap["<C-d>"] = { "select_next", "fallback" }
      opts.keymap["<C-u>"] = { "select_prev", "fallback" }
      return opts
    end,
  },
}
