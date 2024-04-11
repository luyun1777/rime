-- Rime Lua 扩展 https://github.com/hchunhui/librime-lua
-- 文档 https://github.com/hchunhui/librime-lua/wiki/Scripting

-- I. translators:

-- 输出当前日期、时间、农历等
date_translator = require("date_translator")
lunar_translator = require("lunar_translator")

-- select_character, 以词定字
select_character = require("select_character")

-- calculator_translator, 用lua计算表达式的值
-- 須在方案增加 `"recognizer/patterns/expression": "^=.*$"`
calculator_translator = require("calculator_translator")

-- Unicode 內碼轉譯（輸出任意Unicode字符） `U` 触发  16 进制
unicode_translator = require("unicode_translator")

-- 数字、金额大写
number_translator = require("number_translator")

-- II. filters:

-- single_char_first_filter, 重排候选字，使得单字在先
single_char_first_filter = require("single_char_first_filter")

-- single_char_only, 只保留单字
single_char_only = require("single_char_only")

-- reverse_lookup_filter: 依地球拼音为候选项加上带调拼音的注释
reverse_lookup_filter = require("reverse_lookup_filter")

-- charset_filter: 滤除含 CJK 扩展汉字的候选项
-- charset_comment_filter: 为候选项加上其所属字符集的注释
charset_filter = require("charset_filter").filter
charset_comment_filter = require("charset_filter").comment_filter
