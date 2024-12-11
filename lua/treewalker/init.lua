local nodes = require('treewalker.nodes')
local getters = require('treewalker.getters')
local util = require('treewalker.util')
local ops = require('treewalker.ops')

local M = {}

---@alias Dir "up" | "down"

---@param lnum integer
local function get_line(lnum)
  return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
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

-- Take lnum, give next lnum / node with same indentation
---@param current_lnum integer
---@param dir Dir
---@return integer | nil, TSNode | nil
local function get_next_jump_candidate(current_lnum, dir)
  local next_lnum
  if dir == "up" then
    next_lnum = current_lnum - 1
  else
    next_lnum = current_lnum + 1
  end
  local max_lnum = vim.api.nvim_buf_line_count(0)
  if next_lnum > max_lnum or next_lnum <= 0 then return end
  local current_line = get_line(current_lnum)
  local current_indentation = get_indent(current_line)
  local node_candidate = vim.treesitter.get_node({ pos = { next_lnum - 1, current_indentation } })
  return next_lnum, node_candidate
end

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

---@param lnum integer
---@param line string
---@param candidate TSNode
---@param prefix string
---@return nil
local function log(lnum, line, candidate, prefix)
  util.log(
    prefix .. ": [L " .. lnum .. "] |" .. line .. "| [" .. candidate:type() .. "]" ..vim.inspect(nodes.range(candidate))
  )

end

-- Skip unwanted nodes
-- TODO this should not jump to other functions
---@param dir Dir
---@param lnum integer
---@param indent integer
---@return integer | nil, string | nil, TSNode | nil
local function get_next_vertical_target_at_same_indent(dir, lnum, indent)
  local candidate_lnum, candidate = get_next_jump_candidate(lnum, dir)
  local candidate_line = ""
  local candidate_indent = get_indent(candidate_line)

  while candidate_lnum and candidate do
    if
        nodes.is_jump_target(candidate) -- only node types we consider jump targets
        and candidate_line ~= "" -- no empty lines
        and candidate_indent == indent -- stay at current indent level
    then
      break -- use most recent assignment below
    else
      candidate_line = get_line(candidate_lnum)
      candidate_lnum, candidate = get_next_jump_candidate(candidate_lnum, dir)
      candidate_indent = get_indent(candidate_line)
    end
  end

  return candidate_lnum, candidate_line, candidate
end

---@return nil
local function move_up()
  local current_lnum = vim.fn.line(".")
  local current_indent = get_indent(get_line(current_lnum))

  --- Get next target, if one is found
  local candidate_lnum, candidate_line, candidate = get_next_vertical_target_at_same_indent("up", current_lnum, current_indent)

  -- Ultimate failure
  if not candidate_lnum or not candidate_line or not candidate then
    return util.log("no next candidate")
  end

  log(candidate_lnum, candidate_line, candidate, "move_up dest")
  ops.jump(candidate_lnum + 1, candidate)
end

---@return nil
local function move_down()
  local current_lnum = vim.fn.line(".")
  local current_indent = get_indent(get_line(current_lnum))

  --- Get next target, if one is found
  local candidate_lnum, candidate_line, candidate = get_next_vertical_target_at_same_indent("down", current_lnum, current_indent)

  -- Ultimate failure
  if not candidate_lnum or not candidate_line or not candidate then
    return util.log("no next candidate")
  end

  log(candidate_lnum, candidate_line, candidate, "move_down dest")
  ops.jump(candidate_lnum - 1, candidate)
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
