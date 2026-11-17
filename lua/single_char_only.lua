--- 只输出单字，但魔法字符引导的候选不过滤
--- 通过选项 `single_char_only` 控制开关

local M = {}

local utf8_len = utf8.len

---@param input Translation
---@param env Env
M.func = function(input, env)
  local ctx = env.engine.context
  local on = ctx:get_option('single_char_only')
  if not on or ctx.input:match('^[%u/]') then
    for cand in input:iter() do
      yield(cand)
    end
    return
  end
  for cand in input:iter() do
    if utf8_len(cand.text) == 1 then
      yield(cand)
    end
  end
end

return M
