--- 将候选字顺序改为：单字->二字-> 三字->四字->其他，对魔法字符引导的候选不处理
--- 采用局部窗口排序，兼顾递增与输入跟手

local M = {}

local utf8_len = utf8.len
local LIMIT = 128 -- 仅对前 `LIMIT` 个候选词进行严格排序，超出部分直接透传

---@param input Translation
---@param env Env
M.func = function(input, env)
  local text = env.engine.context.input
  -- 魔法字符（大写字母 / 符号引导）下的候选多为字母、符号或特殊内容，故直接透传。
  -- 注意：如果大写字母在方案中有正常用途，建议改为精确匹配，如 '^[NRU/]'
  if text:match('^[%u/]') then
    for cand in input:iter() do
      yield(cand)
    end
    return -- 透传完毕后直接返回，避免执行后续逻辑
  end

  local rest, lens = {}, {} -- 使用紧凑数组存储非单字，避免索引空洞
  local rest_count, total_count = 0, 0

  for cand in input:iter() do -- 第一遍：单字直接出，其余收进 rest，长度记入 lens
    total_count = total_count + 1
    if total_count > LIMIT then
      yield(cand) -- 超出窗口的候选词，直接透传，保持原有顺序，打破阻塞
    else
      local len = utf8_len(cand.text) or 1 -- 非法 UTF-8 按单字处理
      if len == 1 then
        yield(cand)
      else
        rest_count = rest_count + 1
        rest[rest_count] = cand
        lens[rest_count] = len
      end
    end
  end

  for want = 2, 4 do -- 后四遍：读取，按 2、3、4字词、其他 顺序吐出（仅处理窗口内的数据）
    for i = 1, rest_count do
      if lens[i] == want then
        yield(rest[i])
      end
    end
  end

  for i = 1, rest_count do -- 处理窗口内长度大于 4，  异常字符已按单字处理
    local len = lens[i]
    if len > 4 then
      yield(rest[i])
    end
  end
end

return M
