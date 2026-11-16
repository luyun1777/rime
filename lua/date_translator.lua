local M = {}

local numbers = { '〇', '一', '二', '三', '四', '五', '六', '七', '八', '九' }

function M.init(env)
  local config = env.engine.schema.config
  env.name_space = env.name_space:gsub('^*', '')
  env._date = config:get_string(env.name_space .. '/date') or 'date'
  env._time = config:get_string(env.name_space .. '/time') or 'time'
  env._week = config:get_string(env.name_space .. '/week') or 'week'
  env._datetime = config:get_string(env.name_space .. '/datetime') or 'dati'
end

-- 年天数判断
---@param year integer
---@return integer year
local function IsLeap(year)
  if (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0 then
    return 366
  else
    return 365
  end
end

---@param date string?
---@return string
local function CnDate_translator(date)
  date = date or tostring(os.date('%Y%m%d'))
  local t
  local text = ''
  for i = 1, #date do
    t = numbers[tonumber(date:sub(i, i)) + 1]
    if i == 5 and t ~= '〇' then
      t = '年十'
    elseif i == 5 and t == '〇' then
      t = '年'
    end
    if i == 6 and t ~= '〇' then
      t = t .. '月'
    elseif i == 6 and t == '〇' then
      t = '月'
    end
    if i == 7 and tonumber(date:sub(7, 7)) > 1 then
      t = t .. '十'
    elseif i == 7 and t == '〇' then
      t = ''
    elseif i == 7 and tonumber(date:sub(7, 7)) == 1 then
      t = '十'
    end
    if i == 8 and t ~= '〇' then
      t = t .. '日'
    elseif i == 8 and t == '〇' then
      t = '日'
    end
    text = text .. t
  end
  return text
end

function M.func(input, seg, env)
  -------------------------------------------------------------
  --[[
	--%a 星期简称，如Wed	%A 星期全称，如Wednesday
	--%b 月份简称，如Sep	%B 月份全称，如September
	--%c 日期时间格式 (e.g., 09/16/98 23:48:10)
	--%d 一个月的第几天 [01-31]	%j 一年的第几天
	--%H 24小时制 [00-23]	%I 12小时制 [01-12]
	--%M 分钟 [00-59]	%m 月份 (09) [01-12]
	--%p 上午/下午 (pm or am)
	--%S 秒 (10) [00-61]
	--%w 星期的第几天 [0-6 = Sunday-Saturday]	%W 一年的第几周
	--%x 日期格式 (e.g., 09/16/98)	%X 时间格式 (e.g., 23:48:10)
	--%Y 年份全称 (1998)	%y 年份简称 [00-99]
	--%% 百分号
	--os.date() 把时间戳转化成可显示的时间字符串
	--os.time ([table])
--]]
  ----------------------------------------------------------------
  -- 日期
  if input == env._date then
    local now = os.date('*t')
    local cnadidates = {
      string.format('%d年%d月%d日', now.year, now.month, now.day),
      os.date('%Y-%m-%d'),
      CnDate_translator(),
      CnDate_translator():gsub('(.+月).+日', '%1'),
      os.date('%Y/%m/%d'),
    }
    for _, candidate in ipairs(cnadidates) do
      yield(Candidate('date', seg.start, seg._end, candidate, '〔日期〕'))
    end

  -- 时间
  elseif input == env._time then
    local now = os.date('*t')
    local candidates = {
      string.format('%d:%d', now.hour, now.min),
      os.date('%H:%M:%S'),
      string.format('%d点%d分', now.hour, now.min),
      os.date('%H时%M分%S秒'),
    }
    for _, candidate in ipairs(candidates) do
      yield(Candidate('time', seg.start, seg._end, candidate, '〔时间〕'))
    end

  -- 星期
  elseif input == env._week then
    local week_tab = { '日', '一', '二', '三', '四', '五', '六' }
    local week = week_tab[tonumber(os.date('%w') + 1)]
    local candidates = {
      '星期' .. week,
      '周' .. week,
      '礼拜' .. week,
    }
    for _, candidate in ipairs(candidates) do
      yield(Candidate('week', seg.start, seg._end, candidate, '〔星期〕'))
    end

  -- 日期和时间
  elseif input == env._datetime then
    local now = os.date('*t')
    local candidates = {
      string.format('%d年%d月%d日 %d时%d分%d秒', now.year, now.month, now.day, now.hour, now.min, now.sec),
      os.date('%Y-%m-%d｜%j/' .. IsLeap(now.year)),
      os.date('%Y-%m-%d 第%W周'),
      os.date('%Y-%m-%d %H:%M:%S'),
    }
    for _, cnadidate in ipairs(candidates) do
      yield(Candidate('datetime', seg.start, seg._end, cnadidate, '〔日期&时间〕'))
    end
  end
end

return M
