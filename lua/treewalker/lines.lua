local M = {}

---@param lnum integer
function M.get_line(lnum)
  return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
end

---@param line string
---@return integer
function M.get_indent(line)
  local tabwidth = vim.opt.tabstop:get()
  local count = 1 -- 1 indexed
  for i = 1, #line do
    local c = line:sub(i, i)
    if c == "\t" then
      count = math.floor((count + tabwidth) / tabwidth) * tabwidth
    elseif c == " " then
      count = count + 1
    else
      break
    end
  end
  return count
end

return M
