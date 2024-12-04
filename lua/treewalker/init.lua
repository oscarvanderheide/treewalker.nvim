local node_util = require('treewalker.node_util')
local getters = require('treewalker.getters')
local util = require('treewalker.util')
local ops = require('treewalker.ops')
local walker_tree = require('treewalker.walker_tree')

local M = {}

---@return nil
local function move_out()
  local node = getters.get_node()
  -- local target = getters.get_direct_ancestor(node)
  local target = node:parent()

  if target then
    ops.jump(target)
  end
end

---@return nil
local function move_in()
  local node = getters.get_node()
  -- local target = getters.get_descendant(node)
  local target = node.children[1]

  if target then
    ops.jump(target)
  end
end

---@param line string
---@return integer
local function get_indent(line)
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

---@return nil
local function move_up()
  local current_lnum = vim.fn.line(".")
  local current_line = vim.api.nvim_buf_get_lines(0, current_lnum - 1, current_lnum, false)[1]
  util.log(current_line .. " indentation: " .. get_indent(current_line))

  -- local node = getters.get_node()
  -- -- local target = getters.get_prev(node)
  -- local target = node:prev_sibling()

  -- if target then
  --   ops.jump(target)
  -- end
end

---@param line string
---@return string
local function get_indentation_str(line)
  -- Find the first non-whitespace character in the line
  local i = 1
  while i <= #line do
    if line:sub(i, i) ~= " " and line:sub(i, i) ~= "\t" then break end
    i = i + 1
  end

  -- If no non-whitespace characters were found, return an empty string
  if i == #line + 1 then return "" end

  -- Return the substring from the beginning to the first non-whitespace character
  return line:sub(1, i - 1)
end

---@param lnum integer
local function get_line(lnum)
  return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
end

---@return nil
local function move_down()
  -- Take lnum, give next lnum / node with same indentation
  ---@param current_lnum integer
  ---@return integer | nil, TSNode | nil
  local function get_next_jump_candidate(current_lnum)
    local current_line = get_line(current_lnum)
    local current_indentation = get_indent(current_line)
    local next_lnum = current_lnum + 1
    local max_lnum = vim.api.nvim_buf_line_count(0)
    if next_lnum > max_lnum then return end
    local node_candidate = vim.treesitter.get_node({ pos = { next_lnum - 2, current_indentation } })
    return next_lnum, node_candidate
  end

  local current_lnum = vim.fn.line(".")
  local current_indent = get_indent(get_line(current_lnum))

  local candidate_lnum, candidate = get_next_jump_candidate(current_lnum)
  local candidate_line = ""
  local candidate_indent = get_indent(candidate_line)

  -- Skip unwanted nodes
  while candidate_lnum and candidate do
    if
        node_util.is_jump_target(candidate)
        and candidate_line ~= ""
        and candidate_indent == current_indent
    then
      break
    else
      candidate_line = get_line(candidate_lnum)
      candidate_lnum, candidate = get_next_jump_candidate(candidate_lnum)
      candidate_indent = get_indent(candidate_line)
    end
  end

  -- Ultimate failure
  if not candidate_lnum or not candidate then
    return util.log("no next candidate")
  end

  util.log("dest: [L " ..
  candidate_lnum .. "]: |" .. candidate_line .. "| [" .. vim.inspect(node_util.range(candidate)) .. "]")

  vim.api.nvim_win_set_cursor(0, { candidate_lnum - 1, 0 })
  vim.cmd('normal! ^')
  ops.highlight(node_util.range(candidate))
end

function M.up() move_up() end

function M.down() move_down() end

function M.left() move_out() end

function M.right() move_in() end

return M

-- -- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- -- you can also put some validation here for those.
-- local config = {}
-- M.config = config
-- M.setup = function(args)
--   M.config = vim.tbl_deep_extend("force", M.config, args or {})
-- end
