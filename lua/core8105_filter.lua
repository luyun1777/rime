--- 只输出`core8105.dict.yaml` 中的常用汉字进行过滤
--- 通过选项 `charset_filter` 控制开关

local M = {}

--- see `http://www.unicode.org/charts/`
---@type CharsetRange[]
local charsets = {
  { name = '[部首增补]', first = 0x2E80, last = 0x2EFF },
  { name = '[康熙部首]', first = 0x2F00, last = 0x2FDF },
  { name = '[笔画]', first = 0x31C0, last = 0x31EF },
  { name = '[扩A]', first = 0x3400, last = 0x4DBF },
  { name = '[基本区]', first = 0x4E00, last = 0x9FFF },
  { name = '[CJK兼容表意]', first = 0xF900, last = 0xFAFF },
  { name = '[扩B]', first = 0x20000, last = 0x2A6DF },
  { name = '[扩C]', first = 0x2A700, last = 0x2B73F },
  { name = '[扩D]', first = 0x2B740, last = 0x2B81F },
  { name = '[扩E]', first = 0x2B820, last = 0x2CEAF },
  { name = '[扩F]', first = 0x2CEB0, last = 0x2EBEF },
  { name = '[扩I]', first = 0x2EBF0, last = 0x2EE5F },
  { name = '[兼补]', first = 0x2F800, last = 0x2FA1F },
  { name = '[扩G]', first = 0x30000, last = 0x3134F },
  { name = '[扩H]', first = 0x31350, last = 0x323AF },
  { name = '[扩J]', first = 0x323B0, last = 0x3347F },
}

--- 加载期校验：确保 `charsets` 严格按 `first` 升序，且每个区间 `first <= last`。
---
--- `is_cjk` 的二分查找依赖严格升序；区间无效会导致匹配错误。
---
---@local
--- do
---   for i = 1, #charsets do
---     local r = charsets[i]
---     assert(
---       r.first <= r.last,
---       string.format('charsets 无效区间: %s (first=0x%X > last=0x%X)', r.name, r.first, r.last)
---     )
---     if i > 1 then
---       assert(
---         r.first > charsets[i - 1].last,
---         string.format(
---           'charsets 未按 first 升序: %s (0x%X) 在 %s (0x%X) 之后',
---           r.name,
---           r.first,
---           charsets[i - 1].name,
---           charsets[i - 1].last
---         )
---       )
---     end
---   end
--- end

M.init = function(env)
  local ok, db = pcall(ReverseDb, 'build/core8105.reverse.bin')
  if ok and db then
    env.coredb = db -- 当此组件被载入时，打开反查库，并存入 `coredb` 中
  else
    env.coredb = nil
  end
  env._cjk_cache = {}
  env._cjk_cache_db = env.coredb
end

local utf8_char = utf8.char
local utf8_codes = utf8.codes
local floor = math.floor

---@param code integer 待查询的 Unicode 码位
---@return boolean
local function is_cjk(code)
  local left, right = 1, #charsets
  while left <= right do
    local mid = floor((left + right) / 2)
    local range = charsets[mid]
    if code < range.first then
      right = mid - 1
    elseif code > range.last then
      left = mid + 1
    else
      return true
    end
  end
  return false
end

--- 判断Uincode码位是否在过滤库中`core8105`
---@param code integer
---@param env any Rime 环境对象（含 engine / context 等）
---@return boolean
local function in_coredb(code, env)
  local coredb = env.coredb
  if coredb == nil then
    return true -- 库缺失时兜底：放行（可改为 false 表示全过滤）
  end
  if env._cjk_cache_db ~= coredb then -- coredb 实例变化时清缓存
    env._cjk_cache = {}
    env._cjk_cache_db = coredb
  end
  local cache = env._cjk_cache
  local hit = cache[code]
  if hit ~= nil then
    return hit
  end
  hit = (coredb:lookup(utf8_char(code)) ~= '')
  cache[code] = hit
  return hit
end

---@param text string
---@param option boolean
---@param env Env
---@return boolean
local function should_yield(text, option, env)
  if not option then
    return true
  end
  for _, code in utf8_codes(text) do
    if is_cjk(code) and not in_coredb(code, env) then
      return false
    end
  end
  return true
end

---@param input Translation
---@param env   Env
M.func = function(input, env)
  local on = env.engine.context:get_option('charset_filter')
  for cand in input:iter() do
    if should_yield(cand.text, on, env) then
      yield(cand)
    end
  end
end

M.fini = function(env)
  env._cjk_cache = nil
  env._cjk_cache_db = nil
end

return M
