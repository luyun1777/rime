-- Unicode
-- 复制自： https://github.com/shewer/librime-lua-script/blob/main/lua/component/unicode.lua
-- 示例：输入 `U62fc` 得到 `拼`

-- 触发前缀 `U`
local rv_var = "^(U+%x+)$"

local function unicode_translator(input, seg)
	if string.match(input, rv_var) ~= nil then
		local ucodestr = input:gsub("^(%a+)", "")
		local code = tonumber(ucodestr, 16)
		if code > 0x10FFFF then
			yield(Candidate("unicode", seg.start, seg._end, "数值超限！", ""))
			return
		end
		yield(Candidate("unicode", seg.start, seg._end, utf8.char(code), string.format("U%x", code)))
		if code < 0x10000 then
			for i = 0, 15 do
				yield(
					Candidate(
						"unicode",
						seg.start,
						seg._end,
						utf8.char(code * 16 + i),
						string.format("U%x~%x", code, i)
					)
				)
			end
		end
	end
end

return unicode_translator
