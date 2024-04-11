-- 日期时间

local M = {}
local number = { "〇", "一", "二", "三", "四", "五", "六", "七", "八", "九" }

-- 年天数判断
local function IsLeap(y)
	local year = tonumber(y)
	if not year then
		return nil
	end
	if math.fmod(year, 400) ~= 0 and math.fmod(year, 4) == 0 or math.fmod(year, 400) == 0 then
		return 366
	else
		return 365
	end
end

local function toUp(text)
	for i, v in ipairs(number) do
		text = text:gsub(i - 1, v)
	end
	return text
end

local function getUpDate()
	local m = tonumber(os.date("%m"))
	local d = tonumber(os.date("%d"))

	local year = toUp(os.date("%Y"))
	local month = toUp(tostring(m))
	if m == 10 then
		month = "十"
	elseif m > 10 then
		month = month:gsub("^一", "十")
	end
	local date = toUp(tostring(d))
	if d == 10 then
		date = "十"
	elseif d % 10 == 0 then
		date = date:gsub("〇", "十")
	elseif d > 10 and d < 20 then
		-- common hanzi's lenth is 3 in UTF-8
		date = "十" .. date:sub(4)
	elseif d > 20 then
		date = date:sub(1, 3) .. "十" .. date:sub(4)
	end
	return year .. "年" .. month .. "月" .. date .. "日"
end

function M.init(env)
	local config = env.engine.schema.config
	env.name_space = env.name_space:gsub("^*", "")
	M.date = config:get_string(env.name_space .. "/date") or "date"
	M.time = config:get_string(env.name_space .. "/time") or "time"
	M.week = config:get_string(env.name_space .. "/week") or "week"
	M.datetime = config:get_string(env.name_space .. "/datetime") or "dati"
end

function M.func(input, seg)
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
	if input == M.date then
		local dates = {
			tostring(os.date("%Y年%m月%d日", os.time())):gsub("年0", "年"):gsub("月0", "月"),
			os.date("%Y-%m-%d", os.time()),
			getUpDate(),
			getUpDate():gsub("(.+月).+日", "%1"),
			os.date("%Y/%m/%d", os.time()),
		}
		-- Candidate(type, start, end, text, comment)
		for _, date in ipairs(dates) do
			yield(Candidate(input, seg.start, seg._end, date, "〔日期〕"))
		end

	-- 时间
	elseif input == M.time then
		local times = {
			os.date("%H:%M:%S"),
			os.date("%H:%M"),
		}
		for _, time in ipairs(times) do
			yield(Candidate(input, seg.start, seg._end, time, "〔时间〕"))
		end

	-- 星期
	elseif input == M.week then
		local week_tab = { "日", "一", "二", "三", "四", "五", "六" }
		local week_ = week_tab[tonumber(os.date("%w", os.time()) + 1)]
		local weeks = {
			"星期" .. week_,
			"周" .. week_,
			"礼拜" .. week_,
		}
		-- Candidate(type, start, end, text, comment)
		for _, week in ipairs(weeks) do
			yield(Candidate(input, seg.start, seg._end, week, "〔星期〕"))
		end

	-- 日期和时间
	elseif input == M.datetime then
		local datetimes = {
			tostring(os.date("%Y年%m月%d日 %H时%M分%S秒", os.time()))
				:gsub("年0", "年")
				:gsub("月0", "月")
				:gsub("日 0", "日 ")
				:gsub("时0", "时")
				:gsub("分0", "分"),
			os.date("%Y-%m-%d %H:%M:%S", os.time()),
			os.date("%Y-%m-%d 第%W周"),
			os.date("%Y-%m-%d｜%j/" .. IsLeap(os.date("%Y"))),
		}
		for _, time in ipairs(datetimes) do
			yield(Candidate(input, seg.start, seg._end, time, "〔日期&时间〕"))
		end
	end
end

return M
