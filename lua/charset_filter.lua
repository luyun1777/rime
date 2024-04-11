--[[
charset_filter: 滤除含 CJK 扩展汉字的候选项
charset_comment_filter: 为候选项加上其所属字符集的注释
--]]

local charset = {
	["CJK"] = { first = 0x4E00, last = 0x9FFF },
	["ExtA"] = { first = 0x3400, last = 0x4DBF },
	["ExtB"] = { first = 0x20000, last = 0x2A6DF },
	["ExtC"] = { first = 0x2A700, last = 0x2B73F },
	["ExtD"] = { first = 0x2B740, last = 0x2B81F },
	["ExtE"] = { first = 0x2B820, last = 0x2CEAF },
	["ExtF"] = { first = 0x2CEB0, last = 0x2EBEF },
	["Compat"] = { first = 0x2F800, last = 0x2FA1F },
}

local function exists(single_filter, text)
	for i in utf8.codes(text) do
		local c = utf8.codepoint(text, i)
		if not single_filter(c) then
			return false
		end
	end
	return true
end

local function is_charset(s)
	return function(c)
		return c >= charset[s].first and c <= charset[s].last
	end
end

local function is_cjk_ext(c)
	return is_charset("ExtA")(c)
		or is_charset("ExtB")(c)
		or is_charset("ExtC")(c)
		or is_charset("ExtD")(c)
		or is_charset("ExtE")(c)
		or is_charset("ExtF")(c)
		or is_charset("Compat")(c)
end

local function charset_filter(input)
	for cand in input:iter() do
		if not exists(is_cjk_ext, cand.text) then
			yield(cand)
		end
	end
end

local function charset_comment_filter(input)
	for cand in input:iter() do
		for s, r in pairs(charset) do
			if exists(is_charset(s), cand.text) then
				cand:get_genuine().comment = cand.comment .. " " .. s
				break
			end
		end
		yield(cand)
	end
end

return {
	filter = charset_filter,
	comment_filter = charset_comment_filter,
}
