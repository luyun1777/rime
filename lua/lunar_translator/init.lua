local lunarDate = require("lunar_translator.lunarDate")
local lunarGz = require("lunar_translator.lunarGz")
local lunarJq = require("lunar_translator.lunarJq")
local rv_var = {
	nl_var = "nl", -- 输入当前农历关键字
	jq_var = "jq", -- 输入节气关键字
	nl_var_wubi86 = "pedl", -- 五笔输入当前农历关键字
	jq_var_wubi86 = "abrn", -- 五笔输入节气关键字
	nl_var_tiger = "lzvq", -- 虎码输入农历关键字
	jq_var_tiger = "wtxs", -- 虎码输入节气关键字
}

-- 当前农历时间
local function lunar_translator(input, seg, env)
	local schema_id = env.engine.schema.schema_id -- 获取方案id
	local keyword = schema_id == "wubi86" and rv_var["nl_var_wubi86"]
		or (schema_id == "tiger" and rv_var["nl_var_tiger"] or rv_var["nl_var"])
	if input == keyword then
		local t1, t2 = lunarDate.Date2LunarDate(os.date("%Y%m%d"))
		local lunars = {
			{ t1 .. JQtest(os.date("%Y%m%d")), "〔公历⇉农历〕" },
			{ t1 .. lunarGz.GetLunarSichen(os.date("%H"), 1), "〔公历⇉农历〕" },
			{ t2 .. JQtest(os.date("%Y%m%d")), "〔公历⇉农历〕" },
			{ t2 .. lunarGz.GetLunarSichen(os.date("%H"), 1), "〔公历⇉农历〕" },
			{ lunarGz.LunarGzl(os.date("%Y%m%d%H")), "〔公历⇉干支〕" },
			{ lunarDate.LunarDate2Date(os.date("%Y%m%d"), 0), "〔农历⇉公历〕" },
		}
		local leapDate = { lunarDate.LunarDate2Date(os.date("%Y%m%d"), 1) .. "（闰）", "〔农历⇉公历〕" }
		if string.match(leapDate[1], "^(%d+)") ~= nil then
			table.insert(lunars, leapDate)
		end
		for i = 1, #lunars do
			yield(Candidate(keyword, seg.start, seg._end, lunars[i][1], lunars[i][2]))
		end
		lunars = nil
	end
end

-- 列出当年余下的节气
local function jq_translator(input, seg, env)
	local schema_id = env.engine.schema.schema_id -- 获取方案id
	local keyword = schema_id == "wubi86" and rv_var["jq_var_wubi86"]
		or (schema_id == "tiger" and rv_var["jq_var_tiger"] or rv_var["jq_var"])

	-- local schema_name=env.engine.schema.schema_name         -- 获取方案名称
	if input == keyword then
		local jqs = lunarJq.GetNowTimeJq(os.date("%Y%m%d"))
		for i = 1, #jqs do
			yield(Candidate(keyword, seg.start, seg._end, jqs[i], "〔节气〕"))
		end
		jqs = nil
	end
end

-- 农历查询
local function queryLunar_translator(input, seg) --以任意大写字母(除R、U)开头引导反查农历日期，日期位数不足会以当前日期补全。
	local str, lunar
	if string.match(input, "^([A-QS-TV-Y]+%d+)$") ~= nil then
		str = input:gsub("^(%a+)", "")
		if string.match(str, "^(20)%d%d+$") ~= nil or string.match(str, "^(19)%d%d+$") ~= nil then
			lunar = lunarDate.QueryLunarInfo(str)
			if #lunar > 0 then
				for i = 1, #lunar do
					yield(Candidate(input, seg.start, seg._end, lunar[i][1], lunar[i][2]))
				end
			end
		end
	end
end

local function translator(input, seg, env)
	lunar_translator(input, seg, env)
	jq_translator(input, seg, env)
	queryLunar_translator(input, seg)
end

return translator
