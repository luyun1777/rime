--- 过滤器：只显示单字

local function single_char_only(input, env)
	local on = env.engine.context:get_option("single_char_only") --开关状态
	for cand in input:iter() do
		if on then
			if utf8.len(cand.text) == 1 then
				yield(cand)
			end
		else
			yield(cand)
		end
	end
end

return single_char_only
