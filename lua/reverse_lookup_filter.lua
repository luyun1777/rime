-- reverse_lookup_filter: 依地球拼音为候选项加上带调拼音的注释

local function xform_py(input)
	if input == "" then
		return ""
	end
	input = string.gsub(input, "([aeiou])(ng?)([1234])", "%1%3%2")
	input = string.gsub(input, "([aeiou])(r)([1234])", "%1%3%2")
	input = string.gsub(input, "([aeo])([iuo])([1234])", "%1%3%2")
	input = string.gsub(input, "a1", "ā")
	input = string.gsub(input, "a2", "á")
	input = string.gsub(input, "a3", "ǎ")
	input = string.gsub(input, "a4", "à")
	input = string.gsub(input, "e1", "ē")
	input = string.gsub(input, "e2", "é")
	input = string.gsub(input, "e3", "ě")
	input = string.gsub(input, "e4", "è")
	input = string.gsub(input, "o1", "ō")
	input = string.gsub(input, "o2", "ó")
	input = string.gsub(input, "o3", "ǒ")
	input = string.gsub(input, "o4", "ò")
	input = string.gsub(input, "i1", "ī")
	input = string.gsub(input, "i2", "í")
	input = string.gsub(input, "i3", "ǐ")
	input = string.gsub(input, "i4", "ì")
	input = string.gsub(input, "u1", "ū")
	input = string.gsub(input, "u2", "ú")
	input = string.gsub(input, "u3", "ǔ")
	input = string.gsub(input, "u4", "ù")
	input = string.gsub(input, "v1", "ǖ")
	input = string.gsub(input, "v2", "ǘ")
	input = string.gsub(input, "v3", "ǚ")
	input = string.gsub(input, "v4", "ǜ")
	input = string.gsub(input, "([nljqxy])v", "%1ü")
	input = string.gsub(input, "eh[0-5]?", "ê")
	input = string.gsub(input, "([a-z]+)[0-5]", "%1")
	return input
end

local function reverse_lookup_filter(input, env)
	for cand in input:iter() do
		cand:get_genuine().comment = cand.comment .. " " .. xform_py(env.pydb:lookup(cand.text))
		yield(cand)
	end
end

local function init(env)
	env.pydb = ReverseDb("build/terra_pinyin.reverse.bin")
end

return { init = init, func = reverse_lookup_filter }
