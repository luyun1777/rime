--- 过滤器：顺序改为：单字 二字词 三字词 四字词 其他

local function single_char_first_filter(input)
	local l = {}
	for cand in input:iter() do
		if utf8.len(cand.text) == 1 then
			yield(cand)
		else
			table.insert(l, cand)
		end
	end

	local t = {}
	for _, cand in ipairs(l) do
		if utf8.len(cand.text) == 2 then
			yield(cand)
		else
			table.insert(t, cand)
		end
	end

	l = t
	t = {}
	for _, cand in ipairs(l) do
		if utf8.len(cand.text) == 3 then
			yield(cand)
		else
			table.insert(t, cand)
		end
	end

	l = t
	t = {}
	for _, cand in ipairs(l) do
		if utf8.len(cand.text) == 4 then
			yield(cand)
		else
			table.insert(t, cand)
		end
	end
	for _, cand in ipairs(t) do
		yield(cand)
	end
	l = nil
	t = nil
end

return single_char_first_filter
