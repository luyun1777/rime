local M = {}

local utf8_len = utf8.len

--- 过滤器：只显示单字
---@param input Translation
---@param env Env
M.func = function(input, env)
  local on = env.engine.context:get_option('single_char_only')
  for cand in input:iter() do
    if not on or utf8_len(cand.text) == 1 then
      yield(cand)
    end
  end
end

return M
