local M = {}

local function read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end
  return table.concat(lines, "\n")
end

local function json_decode(str)
  local ok, obj = pcall(vim.json.decode, str)
  if ok then
    return obj
  end
  return nil
end

local function write_log()
  local stamp = os.date("%Y%m%d-%H%M%S")
  local log_dir = vim.fn.expand("~/.cache")
  local log_file = log_dir .. "/nvim-debug-" .. stamp .. ".log"
  vim.fn.mkdir(log_dir, "p")

  local lines = {}
  local function add(s)
    lines[#lines + 1] = s
  end

  local v = vim.version()
  add("== NVIM DEBUG ==")
  add("timestamp: " .. stamp)
  add("nvim: " .. (v.major or 0) .. "." .. (v.minor or 0) .. "." .. (v.patch or 0))
  add("has_nvim_011: " .. tostring(vim.fn.has("nvim-0.11") == 1))
  add("")

  add("== ENV ==")
  add("TERM=" .. (vim.env.TERM or ""))
  add("COLORTERM=" .. (vim.env.COLORTERM or ""))
  add("LANG=" .. (vim.env.LANG or ""))
  add("LC_ALL=" .. (vim.env.LC_ALL or ""))
  add("")

  add("== OPTIONS ==")
  add("encoding=" .. vim.o.encoding)
  add("ambiwidth=" .. vim.o.ambiwidth)
  add("termguicolors=" .. tostring(vim.o.termguicolors))
  local ok_screenpos, screenpos = pcall(vim.fn.screenpos, 0, vim.fn.line("."), vim.fn.col("."))
  if ok_screenpos and screenpos and screenpos.row then
    add("screenpos=" .. screenpos.row .. "," .. screenpos.col)
  else
    add("screenpos=unavailable")
  end
  local ok_screen_cursor, screen_cursor = pcall(vim.api.nvim__get_screen_cursor)
  if ok_screen_cursor and screen_cursor and screen_cursor[1] and screen_cursor[2] then
    add("screen_cursor=" .. screen_cursor[1] .. "," .. screen_cursor[2])
  else
    add("screen_cursor=unavailable")
  end
  add("")

  add("== LAZY LOCK ==")
  local lock_path = vim.fn.expand("~/.config/nvim/lazy-lock.json")
  local lock_raw = read_file(lock_path)
  if lock_raw then
    local obj = json_decode(lock_raw)
    if obj then
      for _, name in ipairs({ "lazy.nvim", "snacks.nvim", "LazyVim" }) do
        local commit = obj[name] and obj[name].commit or "missing"
        add(name .. ": " .. commit)
      end
    else
      add("lazy-lock.json: parse failed")
    end
  else
    add("lazy-lock.json: missing")
  end

  vim.fn.writefile(lines, log_file)
  return log_file
end

function M.setup()
  vim.api.nvim_create_user_command("NvimDebugLog", function()
    local path = write_log()
    vim.notify("Wrote: " .. path)
  end, {})
end

return M
