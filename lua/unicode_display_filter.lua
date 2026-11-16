--- 给候选项填加 16进制 Unicode 代码注释
--- 通过选项 `udpf_switch` 控制开关。

local M = {}

local utf8_codes = utf8.codes

---@param text string
---@return string
local function ucode(text)
  if not text or #text < 1 then
    return ''
  end
  local parts = {}
  for _, code in utf8_codes(text) do
    table.insert(parts, string.format('U%04X', code))
  end
  return ' [' .. table.concat(parts, ' ') .. ']'
end

---@param input Translation
---@param env Env
M.func = function(input, env)
  local on = env.engine.context:get_option('udpf_switch')
  for cand in input:iter() do
    if on then
      cand:get_genuine().comment = cand.comment .. ucode(cand.text)
    end
    yield(cand)
  end
end

return M
