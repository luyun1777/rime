--- 为候选词追加所属字符集注释（如 "[拉丁] [基本区]"），
--- 通过选项 `charset_comment_filter` 控制开关

local M = {}

--- 字符集区间定义。
---
--- 每个条目描述一个 Unicode 区块：
--- - `name`  : 显示在候选注释中的名称（含方括号）。
--- - `first` : 区间起始码位（含）。
--- - `last`  : 区间结束码位（含）。
---
---@class CharsetRange
---@field name  string  显示名称
---@field first integer 起始码位
---@field last  integer 结束码位
---
--- see `http://www.unicode.org/charts/`
--- 全部字符集区间，按 `first` 严格升序排列
---
---@type CharsetRange[]
local charsets = {
  { name = '[拉丁]', first = 0x0000, last = 0x007F }, -- 拉丁 (Basic Latin)
  { name = '[拉丁增补1]', first = 0x0080, last = 0x00FF }, -- 拉丁增补1 (Latin-1 Supplement)
  { name = '[拉丁扩A]', first = 0x0100, last = 0x017F }, -- 拉丁扩A (Latin Extended-A)
  { name = '[拉丁扩B]', first = 0x0180, last = 0x024F }, -- 拉丁扩B (Latin Extended-B)
  { name = '[音标]', first = 0x0250, last = 0x02AF }, -- 音标 (IPA Extensions)
  { name = '[间距修饰]', first = 0x02B0, last = 0x02FF }, -- 间距修饰 (Spacing Modifier Letters)
  { name = '[组合变音]', first = 0x0300, last = 0x036F }, -- 组合变音 (Combining Diacritical Marks)
  { name = '[希腊]', first = 0x0370, last = 0x03FF }, -- 希腊 (Greek and Coptic)
  { name = '[西里尔]', first = 0x0400, last = 0x04FF }, -- 西里尔 (Cyrillic)
  { name = '[西里尔增补]', first = 0x0500, last = 0x052F }, -- 西里尔增补 (Cyrillic Supplement)
  { name = '[亚美尼亚]', first = 0x0530, last = 0x058F }, -- 亚美尼亚 (Armenian)
  { name = '[希伯来]', first = 0x0590, last = 0x05FF }, -- 希伯来 (Hebrew)
  { name = '[阿拉伯]', first = 0x0600, last = 0x06FF }, -- 阿拉伯 (Arabic)
  { name = '[叙利亚]', first = 0x0700, last = 0x074F }, -- 叙利亚 (Syriac)
  { name = '[阿拉伯增补]', first = 0x0750, last = 0x077F }, -- 阿拉伯增补 (Arabic Supplement)
  { name = '[塔安那]', first = 0x0780, last = 0x07BF }, -- 塔安那 (Thaana)
  { name = '[恩科]', first = 0x07C0, last = 0x07FF }, -- 恩科 (NKo)
  { name = '[撒马利亚]', first = 0x0800, last = 0x083F }, -- 撒马利亚 (Samaritan)
  { name = '[曼达安]', first = 0x0840, last = 0x085F }, -- 曼达安 (Mandaic)
  { name = '[叙利亚增补]', first = 0x0860, last = 0x086F }, -- 叙利亚增补 (Syriac Supplement)
  { name = '[阿拉伯扩B]', first = 0x0870, last = 0x089F }, -- 阿拉伯扩B (Arabic Extended-B)
  { name = '[阿拉伯扩A]', first = 0x08A0, last = 0x08FF }, -- 阿拉伯扩A (Arabic Extended-A)
  { name = '[天城文]', first = 0x0900, last = 0x097F }, -- 天城文 (Devanagari)
  { name = '[孟加拉]', first = 0x0980, last = 0x09FF }, -- 孟加拉 (Bengali)
  { name = '[果鲁穆奇]', first = 0x0A00, last = 0x0A7F }, -- 果鲁穆奇 (Gurmukhi)
  { name = '[古吉拉特]', first = 0x0A80, last = 0x0AFF }, -- 古吉拉特 (Gujarati)
  { name = '[奥里亚]', first = 0x0B00, last = 0x0B7F }, -- 奥里亚 (Oriya)
  { name = '[泰米尔]', first = 0x0B80, last = 0x0BFF }, -- 泰米尔 (Tamil)
  { name = '[泰卢固]', first = 0x0C00, last = 0x0C7F }, -- 泰卢固 (Telugu)
  { name = '[卡纳达]', first = 0x0C80, last = 0x0CFF }, -- 卡纳达 (Kannada)
  { name = '[马拉雅拉姆]', first = 0x0D00, last = 0x0D7F }, -- 马拉雅拉姆 (Malayalam)
  { name = '[僧伽罗]', first = 0x0D80, last = 0x0DFF }, -- 僧伽罗 (Sinhala)
  { name = '[泰文]', first = 0x0E00, last = 0x0E7F }, -- 泰文 (Thai)
  { name = '[老挝]', first = 0x0E80, last = 0x0EFF }, -- 老挝 (Lao)
  { name = '[藏文]', first = 0x0F00, last = 0x0FFF }, -- 藏文 (Tibetan)
  { name = '[缅甸]', first = 0x1000, last = 0x109F }, -- 缅甸 (Myanmar)
  { name = '[格鲁吉亚]', first = 0x10A0, last = 0x10FF }, -- 格鲁吉亚 (Georgian)
  { name = '[韩文字母]', first = 0x1100, last = 0x11FF }, -- 韩文字母 (Hangul Jamo)
  { name = '[埃塞俄比亚]', first = 0x1200, last = 0x137F }, -- 埃塞俄比亚 (Ethiopic)
  { name = '[埃塞增补]', first = 0x1380, last = 0x139F }, -- 埃塞增补 (Ethiopic Supplement)
  { name = '[切罗基]', first = 0x13A0, last = 0x13FF }, -- 切罗基 (Cherokee)
  { name = '[加拿大土著音节]', first = 0x1400, last = 0x167F }, -- 加拿大土著音节 (Unified Canadian Aboriginal Syllabics)
  { name = '[欧甘]', first = 0x1680, last = 0x169F }, -- 欧甘 (Ogham)
  { name = '[卢恩]', first = 0x16A0, last = 0x16FF }, -- 卢恩 (Runic)
  { name = '[他加禄]', first = 0x1700, last = 0x171F }, -- 他加禄 (Tagalog)
  { name = '[哈努努奥]', first = 0x1720, last = 0x173F }, -- 哈努努奥 (Hanunoo)
  { name = '[布希德]', first = 0x1740, last = 0x175F }, -- 布希德 (Buhid)
  { name = '[塔格巴努瓦]', first = 0x1760, last = 0x177F }, -- 塔格巴努瓦 (Tagbanwa)
  { name = '[高棉]', first = 0x1780, last = 0x17FF }, -- 高棉 (Khmer)
  { name = '[蒙古]', first = 0x1800, last = 0x18AF }, -- 蒙古 (Mongolian)
  { name = '[加拿大土著音节扩]', first = 0x18B0, last = 0x18FF }, -- 加拿大土著音节扩 (Unified Canadian Aboriginal Syllabics Extended)
  { name = '[林布]', first = 0x1900, last = 0x194F }, -- 林布 (Limbu)
  { name = '[傣仂]', first = 0x1950, last = 0x197F }, -- 傣仂 (Tai Le)
  { name = '[新傣仂]', first = 0x1980, last = 0x19DF }, -- 新傣仂 (New Tai Lue)
  { name = '[高棉符号]', first = 0x19E0, last = 0x19FF }, -- 高棉符号 (Khmer Symbols)
  { name = '[布吉]', first = 0x1A00, last = 0x1A1F }, -- 布吉 (Buginese)
  { name = '[老傣文]', first = 0x1A20, last = 0x1AAF }, -- 老傣文 (Tai Tham)
  { name = '[组合变音扩展]', first = 0x1AB0, last = 0x1AFF }, -- 组合变音扩展 (Combining Diacritical Marks Extended)
  { name = '[巴厘]', first = 0x1B00, last = 0x1B7F }, -- 巴厘 (Balinese)
  { name = '[巽他]', first = 0x1B80, last = 0x1BBF }, -- 巽他 (Sundanese)
  { name = '[巴塔克]', first = 0x1BC0, last = 0x1BFF }, -- 巴塔克 (Batak)
  { name = '[雷布查]', first = 0x1C00, last = 0x1C4F }, -- 雷布查 (Lepcha)
  { name = '[奥尔奇基]', first = 0x1C50, last = 0x1C7F }, -- 奥尔奇基 (Ol Chiki)
  { name = '[西里尔扩C]', first = 0x1C80, last = 0x1C8F }, -- 西里尔扩C (Cyrillic Extended-C)
  { name = '[格鲁吉亚扩]', first = 0x1C90, last = 0x1CBF }, -- 格鲁吉亚扩 (Georgian Extended)
  { name = '[巽他增补]', first = 0x1CC0, last = 0x1CCF }, -- 巽他增补 (Sundanese Supplement)
  { name = '[吠陀扩展]', first = 0x1CD0, last = 0x1CFF }, -- 吠陀扩展 (Vedic Extensions)
  { name = '[音标扩展]', first = 0x1D00, last = 0x1D7F }, -- 音标扩展 (Phonetic Extensions)
  { name = '[音标扩展增补]', first = 0x1D80, last = 0x1DBF }, -- 音标扩展增补 (Phonetic Extensions Supplement)
  { name = '[组合变音增补]', first = 0x1DC0, last = 0x1DFF }, -- 组合变音增补 (Combining Diacritical Marks Supplement)
  { name = '[拉丁附加]', first = 0x1E00, last = 0x1EFF }, -- 拉丁附加 (Latin Extended Additional)
  { name = '[希腊扩展]', first = 0x1F00, last = 0x1FFF }, -- 希腊扩展 (Greek Extended)
  { name = '[通用标点]', first = 0x2000, last = 0x206F }, -- 通用标点 (General Punctuation)
  { name = '[上下标]', first = 0x2070, last = 0x209F }, -- 上下标 (Superscripts and Subscripts)
  { name = '[货币]', first = 0x20A0, last = 0x20CF }, -- 货币 (Currency Symbols)
  { name = '[符号变音]', first = 0x20D0, last = 0x20FF }, -- 符号变音 (Combining Diacritical Marks for Symbols)
  { name = '[类字母]', first = 0x2100, last = 0x214F }, -- 类字母 (Letterlike Symbols)
  { name = '[数字形式]', first = 0x2150, last = 0x218F }, -- 数字形式 (Number Forms)
  { name = '[箭头]', first = 0x2190, last = 0x21FF }, -- 箭头 (Arrows)
  { name = '[数学]', first = 0x2200, last = 0x22FF }, -- 数学 (Mathematical Operators)
  { name = '[杂项技术]', first = 0x2300, last = 0x23FF }, -- 杂项技术 (Miscellaneous Technical)
  { name = '[控制图符]', first = 0x2400, last = 0x243F }, -- 控制图符 (Control Pictures)
  { name = '[光学识别符]', first = 0x2440, last = 0x245F }, -- 光学识别符 (Optical Character Recognition(OCR))
  { name = '[圈字数字]', first = 0x2460, last = 0x24FF }, -- 圈字数字 (Enclosed Alphanumerics)
  { name = '[框画]', first = 0x2500, last = 0x257F }, -- 框画 (Box Drawing)
  { name = '[块元]', first = 0x2580, last = 0x259F }, -- 块元 (Block Elements)
  { name = '[几何]', first = 0x25A0, last = 0x25FF }, -- 几何 (Geometric Shapes)
  { name = '[杂项符号]', first = 0x2600, last = 0x26FF }, -- 杂项符号 (Miscellaneous Symbols)
  { name = '[装饰符]', first = 0x2700, last = 0x27BF }, -- 装饰符 (Dingbats)
  { name = '[数学A]', first = 0x27C0, last = 0x27EF }, -- 数学A (Miscellaneous Mathematical Symbols-A)
  { name = '[箭头A]', first = 0x27F0, last = 0x27FF }, -- 箭头A (Supplemental Arrows-A)
  { name = '[盲文]', first = 0x2800, last = 0x28FF }, -- 盲文 (Braille Patterns)
  { name = '[箭头B]', first = 0x2900, last = 0x297F }, -- 箭头B (Supplemental Arrows-B)
  { name = '[数学B]', first = 0x2980, last = 0x29FF }, -- 数学B (Miscellaneous Mathematical Symbols-B)
  { name = '[数学增补]', first = 0x2A00, last = 0x2AFF }, -- 数学增补 (Supplemental Mathematical Operators)
  { name = '[杂项箭头]', first = 0x2B00, last = 0x2BFF }, -- 杂项箭头 (Miscellaneous Symbols and Arrows)
  { name = '[格拉哥里]', first = 0x2C00, last = 0x2C5F }, -- 格拉哥里 (Glagolitic)
  { name = '[拉丁扩C]', first = 0x2C60, last = 0x2C7F }, -- 拉丁扩C (Latin Extended-C)
  { name = '[科普特]', first = 0x2C80, last = 0x2CFF }, -- 科普特 (Coptic)
  { name = '[格鲁吉亚增补]', first = 0x2D00, last = 0x2D2F }, -- 格鲁吉亚增补 (Georgian Supplement)
  { name = '[提非纳]', first = 0x2D30, last = 0x2D7F }, -- 提非纳 (Tifinagh)
  { name = '[埃塞扩]', first = 0x2D80, last = 0x2DDF }, -- 埃塞扩 (Ethiopic Extended)
  { name = '[西里尔扩A]', first = 0x2DE0, last = 0x2DFF }, -- 西里尔扩A (Cyrillic Extended-A)
  { name = '[标点增补]', first = 0x2E00, last = 0x2E7F }, -- 标点增补 (Supplemental Punctuation)
  { name = '[部首增补]', first = 0x2E80, last = 0x2EFF }, -- 部首增补 (CJK Radicals Supplement)
  { name = '[康熙部首]', first = 0x2F00, last = 0x2FDF }, -- 康熙部首 (Kangxi Radicals)
  { name = '[表意描述符]', first = 0x2FF0, last = 0x2FFF }, -- 表意描述符 (Ideographic Description Characters)
  { name = '[CJK标点]', first = 0x3000, last = 0x303F }, -- CJK标点 (CJK Symbols and Punctuation)
  { name = '[平假名]', first = 0x3040, last = 0x309F }, -- 平假名 (Hiragana)
  { name = '[片假名]', first = 0x30A0, last = 0x30FF }, -- 片假名 (Katakana)
  { name = '[注音]', first = 0x3100, last = 0x312F }, -- 注音 (Bopomofo)
  { name = '[韩文兼容字母]', first = 0x3130, last = 0x318F }, -- 韩文兼容字母 (Hangul Compatibility Jamo)
  { name = '[汉文训读]', first = 0x3190, last = 0x319F }, -- 汉文训读 (Kanbun)
  { name = '[注音扩展]', first = 0x31A0, last = 0x31BF }, -- 注音扩展 (Bopomofo Extended)
  { name = '[笔画]', first = 0x31C0, last = 0x31EF }, -- 笔画 (CJK Strokes)
  { name = '[片假名扩展]', first = 0x31F0, last = 0x31FF }, -- 片假名扩展 (Katakana Phonetic Extensions)
  { name = '[CJK圈字符]', first = 0x3200, last = 0x32FF }, -- 中日韩弧圈字符 (Enclosed CJK Letters and Months)
  { name = '[CJK兼容]', first = 0x3300, last = 0x33FF }, -- CJK兼容 (CJK Compatibility)
  { name = '[扩A]', first = 0x3400, last = 0x4DBF }, -- 扩A (CJK Unified Ideographs Extension A)
  { name = '[卦符]', first = 0x4DC0, last = 0x4DFF }, -- 卦符 (Yijing Hexagram Symbols)
  { name = '[基本区]', first = 0x4E00, last = 0x9FFF }, -- 基本区 (CJK Unified Ideographs)
  { name = '[彝文音节]', first = 0xA000, last = 0xA48F }, -- 彝文音节 (Yi Syllables)
  { name = '[彝文部首]', first = 0xA490, last = 0xA4CF }, -- 彝文部首 (Yi Radicals)
  { name = '[傈僳]', first = 0xA4D0, last = 0xA4FF }, -- 傈僳 (Lisu)
  { name = '[瓦伊]', first = 0xA500, last = 0xA63F }, -- 瓦伊 (Vai)
  { name = '[西里尔扩B]', first = 0xA640, last = 0xA69F }, -- 西里尔扩B (Cyrillic Extended-B)
  { name = '[巴姆]', first = 0xA6A0, last = 0xA6FF }, -- 巴姆 (Bamum)
  { name = '[修饰声调字母]', first = 0xA700, last = 0xA71F }, -- 修饰声调字母 (Modifier Tone Letters)
  { name = '[拉丁扩D]', first = 0xA720, last = 0xA7FF }, -- 拉丁扩D (Latin Extended-D)
  { name = '[锡尔赫提]', first = 0xA800, last = 0xA82F }, -- 锡尔赫提 (Syloti Nagri)
  { name = '[印度通用数字]', first = 0xA830, last = 0xA83F }, -- 印度通用数字 (Common Indic Number Forms)
  { name = '[八思巴]', first = 0xA840, last = 0xA87F }, -- 八思巴 (Phags-pa)
  { name = '[索拉什特拉]', first = 0xA880, last = 0xA8DF }, -- 索拉什特拉 (Saurashtra)
  { name = '[天城文扩]', first = 0xA8E0, last = 0xA8FF }, -- 天城文扩 (Devanagari Extended)
  { name = '[克耶李]', first = 0xA900, last = 0xA92F }, -- 克耶李 (Kayah Li)
  { name = '[勒姜]', first = 0xA930, last = 0xA95F }, -- 勒姜 (Rejang)
  { name = '[韩文字母扩A]', first = 0xA960, last = 0xA97F }, -- 韩文字母扩A (Hangul Jamo Extended-A)
  { name = '[爪哇]', first = 0xA980, last = 0xA9DF }, -- 爪哇 (Javanese)
  { name = '[缅甸扩B]', first = 0xA9E0, last = 0xA9FF }, -- 缅甸扩B (Myanmar Extended-B)
  { name = '[占文]', first = 0xAA00, last = 0xAA5F }, -- 占文 (Cham)
  { name = '[缅甸扩A]', first = 0xAA60, last = 0xAA7F }, -- 缅甸扩A (Myanmar Extended-A)
  { name = '[傣越]', first = 0xAA80, last = 0xAADF }, -- 傣越 (Tai Viet)
  { name = '[曼尼普尔扩]', first = 0xAAE0, last = 0xAAFF }, -- 曼尼普尔扩 (Meetei Mayek Extensions)
  { name = '[埃塞扩A]', first = 0xAB00, last = 0xAB2F }, -- 埃塞扩A (Ethiopic Extended-A)
  { name = '[拉丁扩E]', first = 0xAB30, last = 0xAB6F }, -- 拉丁扩E (Latin Extended-E)
  { name = '[切罗基增补]', first = 0xAB70, last = 0xABBF }, -- 切罗基增补 (Cherokee Supplement)
  { name = '[曼尼普尔]', first = 0xABC0, last = 0xABFF }, -- 曼尼普尔 (Meetei Mayek)
  { name = '[韩文音节]', first = 0xAC00, last = 0xD7AF }, -- 韩文音节 (Hangul Syllables)
  { name = '[韩文字母扩B]', first = 0xD7B0, last = 0xD7FF }, -- 韩文字母扩B (Hangul Jamo Extended-B)
  { name = '[高代理区]', first = 0xD800, last = 0xDB7F }, -- 高代理区 (High Surrogates)
  { name = '[高私用代理区]', first = 0xDB80, last = 0xDBFF }, -- 高私用代理区 (High Private Use Surrogates)
  { name = '[低代理区]', first = 0xDC00, last = 0xDFFF }, -- 低代理区 (Low Surrogates)
  { name = '[私用区]', first = 0xE000, last = 0xF8FF }, -- 私用区 (Private Use Area)
  { name = '[CJK兼容表意]', first = 0xF900, last = 0xFAFF }, -- CJK兼容表意 (CJK Compatibility Ideographs)
  { name = '[字母表达形式]', first = 0xFB00, last = 0xFB4F }, -- 字母表达形式 (Alphabetic Presentation Forms)
  { name = '[阿拉伯表意A]', first = 0xFB50, last = 0xFDFF }, -- 阿拉伯表意A (Arabic Presentation Forms-A)
  { name = '[变体选择]', first = 0xFE00, last = 0xFE0F }, -- 变体选择 (Variation Selectors)
  { name = '[竖排形]', first = 0xFE10, last = 0xFE1F }, -- 竖排形 (Vertical Forms)
  { name = '[组合半符]', first = 0xFE20, last = 0xFE2F }, -- 组合半符 (Combining Half Marks)
  { name = '[CJK兼容形式]', first = 0xFE30, last = 0xFE4F }, -- 中日韩兼容形式 (CJK Compatibility Forms)
  { name = '[小形式变体]', first = 0xFE50, last = 0xFE6F }, -- 小形式变体 (Small Form Variants)
  { name = '[阿拉伯表意B]', first = 0xFE70, last = 0xFEFF }, -- 阿拉伯表意B (Arabic Presentation Forms-B)
  { name = '[半全角]', first = 0xFF00, last = 0xFFEF }, -- 半全角 (Halfwidth and Fullwidth Forms)
  { name = '[特殊]', first = 0xFFF0, last = 0xFFFF }, -- 特殊 (Specials)
  { name = '[线形文字B音节]', first = 0x10000, last = 0x1007F }, -- 线形文字B音节 (Linear B Syllabary)
  { name = '[线形文字B表意]', first = 0x10080, last = 0x100FF }, -- 线形文字B表意 (Linear B Ideograms)
  { name = '[爱琴数字]', first = 0x10100, last = 0x1013F }, -- 爱琴数字 (Aegean Numbers)
  { name = '[希腊古数]', first = 0x10140, last = 0x1018F }, -- 希腊古数 (Ancient Greek Numbers)
  { name = '[古代符号]', first = 0x10190, last = 0x101CF }, -- 古代符号 (Ancient Symbols)
  { name = '[斐斯托斯圆盘]', first = 0x101D0, last = 0x101FF }, -- 斐斯托斯圆盘 (Phaistos Disc)
  { name = '[吕基亚]', first = 0x10280, last = 0x1029F }, -- 吕基亚 (Lycian)
  { name = '[卡利亚]', first = 0x102A0, last = 0x102DF }, -- 卡利亚 (Carian)
  { name = '[科普特闰日数字]', first = 0x102E0, last = 0x102FF }, -- 科普特闰日数字 (Coptic Epact Numbers)
  { name = '[古意大利]', first = 0x10300, last = 0x1032F }, -- 古意大利 (Old Italic)
  { name = '[哥特]', first = 0x10330, last = 0x1034F }, -- 哥特 (Gothic)
  { name = '[古彼尔姆]', first = 0x10350, last = 0x1037F }, -- 古彼尔姆 (Old Permic)
  { name = '[乌加里特]', first = 0x10380, last = 0x1039F }, -- 乌加里特 (Ugaritic)
  { name = '[古波斯]', first = 0x103A0, last = 0x103DF }, -- 古波斯 (Old Persian)
  { name = '[德塞雷特]', first = 0x10400, last = 0x1044F }, -- 德塞雷特 (Deseret)
  { name = '[萧伯纳]', first = 0x10450, last = 0x1047F }, -- 萧伯纳 (Shavian)
  { name = '[奥斯曼亚]', first = 0x10480, last = 0x104AF }, -- 奥斯曼亚 (Osmanya)
  { name = '[奥塞奇]', first = 0x104B0, last = 0x104FF }, -- 奥塞奇 (Osage)
  { name = '[爱尔巴桑]', first = 0x10500, last = 0x1052F }, -- 爱尔巴桑 (Elbasan)
  { name = '[高加索阿尔巴尼亚]', first = 0x10530, last = 0x1056F }, -- 高加索阿尔巴尼亚 (Caucasian Albanian)
  { name = '[维什库基]', first = 0x10570, last = 0x105BF }, -- 维什库基 (Vithkuqi)
  { name = '[托德里]', first = 0x105C0, last = 0x105FF }, -- 托德里 (Todhri)
  { name = '[线形文字A]', first = 0x10600, last = 0x1077F }, -- 线形文字A (Linear A)
  { name = '[拉丁扩F]', first = 0x10780, last = 0x107BF }, -- 拉丁扩F (Latin Extended-F)
  { name = '[塞浦路斯音节]', first = 0x10800, last = 0x1083F }, -- 塞浦路斯音节 (Cypriot Syllabary)
  { name = '[帝国阿拉米]', first = 0x10840, last = 0x1085F }, -- 帝国阿拉米 (Imperial Aramaic)
  { name = '[巴尔米拉]', first = 0x10860, last = 0x1087F }, -- 巴尔米拉 (Palmyrene)
  { name = '[纳巴泰]', first = 0x10880, last = 0x108AF }, -- 纳巴泰 (Nabataean)
  { name = '[哈特拉]', first = 0x108E0, last = 0x108FF }, -- 哈特拉 (Hatran)
  { name = '[腓尼基]', first = 0x10900, last = 0x1091F }, -- 腓尼基 (Phoenician)
  { name = '[吕底亚]', first = 0x10920, last = 0x1093F }, -- 吕底亚 (Lydian)
  { name = '[西代]', first = 0x10940, last = 0x1095F }, -- 西代 (Sidetic)
  { name = '[麦罗埃象形]', first = 0x10980, last = 0x1099F }, -- 麦罗埃象形 (Meroitic Hieroglyphs)
  { name = '[麦罗埃草书]', first = 0x109A0, last = 0x109FF }, -- 麦罗埃草书 (Meroitic Cursive)
  { name = '[佉卢文]', first = 0x10A00, last = 0x10A5F }, -- 佉卢文 (Kharoshthi)
  { name = '[古南阿拉伯]', first = 0x10A60, last = 0x10A7F }, -- 古南阿拉伯 (Old South Arabian)
  { name = '[古北阿拉伯]', first = 0x10A80, last = 0x10A9F }, -- 古北阿拉伯 (Old North Arabian)
  { name = '[摩尼教]', first = 0x10AC0, last = 0x10AFF }, -- 摩尼教 (Manichaean)
  { name = '[阿维斯陀]', first = 0x10B00, last = 0x10B3F }, -- 阿维斯陀 (Avestan)
  { name = '[碑铭帕提亚]', first = 0x10B40, last = 0x10B5F }, -- 碑铭帕提亚 (Inscriptional Parthian)
  { name = '[碑铭巴列维]', first = 0x10B60, last = 0x10B7F }, -- 碑铭巴列维 (Inscriptional Pahlavi)
  { name = '[圣咏巴列维]', first = 0x10B80, last = 0x10BAF }, -- 圣咏巴列维 (Psalter Pahlavi)
  { name = '[古突厥]', first = 0x10C00, last = 0x10C4F }, -- 古突厥 (Old Turkic)
  { name = '[古匈牙利]', first = 0x10C80, last = 0x10CFF }, -- 古匈牙利 (Old Hungarian)
  { name = '[哈乃斐罗兴亚]', first = 0x10D00, last = 0x10D3F }, -- 哈乃斐罗兴亚 (Hanifi Rohingya)
  { name = '[加莱]', first = 0x10D40, last = 0x10D8F }, -- 加莱 (Garay)
  { name = '[鲁米数字符号]', first = 0x10E60, last = 0x10E7F }, -- 鲁米数字符号 (Rumi Numeral Symbols)
  { name = '[雅兹迪]', first = 0x10E80, last = 0x10EBF }, -- 雅兹迪 (Yezidi)
  { name = '[阿拉伯扩C]', first = 0x10EC0, last = 0x10EFF }, -- 阿拉伯扩C (Arabic Extended-C)
  { name = '[古粟特]', first = 0x10F00, last = 0x10F2F }, -- 古粟特 (Old Sogdian)
  { name = '[粟特]', first = 0x10F30, last = 0x10F6F }, -- 粟特 (Sogdian)
  { name = '[古回鹘]', first = 0x10F70, last = 0x10FAF }, -- 古回鹘 (Old Uyghur)
  { name = '[花剌子模]', first = 0x10FB0, last = 0x10FDF }, -- 花剌子模 (Chorasmian)
  { name = '[埃利迈]', first = 0x10FE0, last = 0x10FFF }, -- 埃利迈 (Elymaic)
  { name = '[婆罗米]', first = 0x11000, last = 0x1107F }, -- 婆罗米 (Brahmi)
  { name = '[凯提]', first = 0x11080, last = 0x110CF }, -- 凯提 (Kaithi)
  { name = '[索拉松朋]', first = 0x110D0, last = 0x110FF }, -- 索拉松朋 (Sora Sompeng)
  { name = '[查克玛]', first = 0x11100, last = 0x1114F }, -- 查克玛 (Chakma)
  { name = '[马哈扎尼]', first = 0x11150, last = 0x1117F }, -- 马哈扎尼 (Mahajani)
  { name = '[沙拉达]', first = 0x11180, last = 0x111DF }, -- 沙拉达 (Sharada)
  { name = '[僧伽罗古数字]', first = 0x111E0, last = 0x111FF }, -- 僧伽罗古数字 (Sinhala Archaic Numbers)
  { name = '[霍伊基]', first = 0x11200, last = 0x1124F }, -- 霍伊基 (Khojki)
  { name = '[木尔坦]', first = 0x11280, last = 0x112AF }, -- 木尔坦 (Multani)
  { name = '[胡达瓦迪]', first = 0x112B0, last = 0x112FF }, -- 胡达瓦迪 (Khudawadi)
  { name = '[格兰塔]', first = 0x11300, last = 0x1137F }, -- 格兰塔 (Grantha)
  { name = '[图卢-提加拉利]', first = 0x11380, last = 0x113FF }, -- 图卢-提加拉利 (Tulu-Tigalari)
  { name = '[尼瓦]', first = 0x11400, last = 0x1147F }, -- 尼瓦 (Newa)
  { name = '[蒂尔胡塔]', first = 0x11480, last = 0x114DF }, -- 蒂尔胡塔 (Tirhuta)
  { name = '[悉昙]', first = 0x11580, last = 0x115FF }, -- 悉昙 (Siddham)
  { name = '[莫迪]', first = 0x11600, last = 0x1165F }, -- 莫迪 (Modi)
  { name = '[蒙古增补]', first = 0x11660, last = 0x1167F }, -- 蒙古增补 (Mongolian Supplement)
  { name = '[塔克里]', first = 0x11680, last = 0x116CF }, -- 塔克里 (Takri)
  { name = '[缅甸扩C]', first = 0x116D0, last = 0x116FF }, -- 缅甸扩C (Myanmar Extended-C)
  { name = '[阿洪姆]', first = 0x11700, last = 0x1174F }, -- 阿洪姆 (Ahom)
  { name = '[多格拉]', first = 0x11800, last = 0x1184F }, -- 多格拉 (Dogra)
  { name = '[瓦朗奇蒂]', first = 0x118A0, last = 0x118FF }, -- 瓦朗奇蒂 (Warang Citi)
  { name = '[迪维希阿库鲁]', first = 0x11900, last = 0x1195F }, -- 迪维希阿库鲁 (Dives Akuru)
  { name = '[南迪城文]', first = 0x119A0, last = 0x119FF }, -- 南迪城文 (Nandinagari)
  { name = '[扎纳巴扎尔方形]', first = 0x11A00, last = 0x11A4F }, -- 扎纳巴扎尔方形 (Zanabazar Square)
  { name = '[索永布]', first = 0x11A50, last = 0x11AAF }, -- 索永布 (Soyombo)
  { name = '[加拿大土著音节扩A]', first = 0x11AB0, last = 0x11ABF }, -- 加拿大土著音节扩A (Unified Canadian Aboriginal Syllabics Extended-A)
  { name = '[包清豪]', first = 0x11AC0, last = 0x11AFF }, -- 包清豪 (Pau Cin Hau)
  { name = '[天城文扩A]', first = 0x11B00, last = 0x11B5F }, -- 天城文扩A (Devanagari Extended-A)
  { name = '[沙拉达增补]', first = 0x11B60, last = 0x11B7F }, -- 沙拉达增补 (Sharada Supplement)
  { name = '[苏努瓦尔]', first = 0x11BC0, last = 0x11BFF }, -- 苏努瓦尔 (Sunuwar)
  { name = '[拜克舒基]', first = 0x11C00, last = 0x11C6F }, -- 拜克舒基 (Bhaiksuki)
  { name = '[玛尔钦]', first = 0x11C70, last = 0x11CBF }, -- 玛尔钦 (Marchen)
  { name = '[马萨拉姆贡迪]', first = 0x11D00, last = 0x11D5F }, -- 马萨拉姆贡迪 (Masaram Gondi)
  { name = '[贡贾拉贡迪]', first = 0x11D60, last = 0x11DAF }, -- 贡贾拉贡迪 (Gunjala Gondi)
  { name = '[托隆西基]', first = 0x11DB0, last = 0x11DEF }, -- 托隆西基 (Tolong Siki)
  { name = '[望加锡]', first = 0x11EE0, last = 0x11EFF }, -- 望加锡 (Makasar)
  { name = '[卡维]', first = 0x11F00, last = 0x11F5F }, -- 卡维 (Kawi)
  { name = '[傈僳增补]', first = 0x11FB0, last = 0x11FBF }, -- 傈僳增补 (Lisu Supplement)
  { name = '[泰米尔增补]', first = 0x11FC0, last = 0x11FFF }, -- 泰米尔增补 (Tamil Supplement)
  { name = '[楔形文字]', first = 0x12000, last = 0x123FF }, -- 楔形文字 (Cuneiform)
  { name = '[楔形数字标点]', first = 0x12400, last = 0x1247F }, -- 楔形数字标点 (Cuneiform Numbers and Punctuation)
  { name = '[早王朝楔形文字]', first = 0x12480, last = 0x1254F }, -- 早王朝楔形文字 (Early Dynastic Cuneiform)
  { name = '[塞浦路斯米诺斯]', first = 0x12F90, last = 0x12FFF }, -- 塞浦路斯米诺斯 (Cypro-Minoan)
  { name = '[埃及象形]', first = 0x13000, last = 0x1342F }, -- 埃及象形 (Egyptian Hieroglyphs)
  { name = '[埃及象形格式控制]', first = 0x13430, last = 0x1345F }, -- 埃及象形格式控制 (Egyptian Hieroglyph Format Controls)
  { name = '[埃及象形扩A]', first = 0x13460, last = 0x143FF }, -- 埃及象形扩A (Egyptian Hieroglyphs Extended-A)
  { name = '[安纳托利亚象形]', first = 0x14400, last = 0x1467F }, -- 安纳托利亚象形 (Anatolian Hieroglyphs)
  { name = '[古隆克玛]', first = 0x16100, last = 0x1613F }, -- 古隆克玛 (Gurung Khema)
  { name = '[巴姆增补]', first = 0x16800, last = 0x16A3F }, -- 巴姆增补 (Bamum Supplement)
  { name = '[莫罗]', first = 0x16A40, last = 0x16A6F }, -- 莫罗 (Mro)
  { name = '[唐萨]', first = 0x16A70, last = 0x16ACF }, -- 唐萨 (Tangsa)
  { name = '[巴萨瓦]', first = 0x16AD0, last = 0x16AFF }, -- 巴萨瓦 (Bassa Vah)
  { name = '[波拉德苗文]', first = 0x16B00, last = 0x16B8F }, -- 波拉德苗文 (Pahawh Hmong)
  { name = '[基拉特莱]', first = 0x16D40, last = 0x16D7F }, -- 基拉特莱 (Kirat Rai)
  { name = '[梅德法伊德林]', first = 0x16E40, last = 0x16E9F }, -- 梅德法伊德林 (Medefaidrin)
  { name = '[贝里亚埃尔费]', first = 0x16EA0, last = 0x16EDF }, -- 贝里亚埃尔费 (Beria Erfe)
  { name = '[苗文]', first = 0x16F00, last = 0x16F9F }, -- 苗文 (Miao)
  { name = '[表意符号]', first = 0x16FE0, last = 0x16FFF }, -- 表意符号和标点 (Ideographic Symbols and Punctuation)
  { name = '[西夏文]', first = 0x17000, last = 0x187FF }, -- 西夏文 (Tangut)
  { name = '[西夏部件]', first = 0x18800, last = 0x18AFF }, -- 西夏部件 (Tangut Components)
  { name = '[契丹小字]', first = 0x18B00, last = 0x18CFF }, -- 契丹小字 (Khitan Small Script)
  { name = '[西夏文增补]', first = 0x18D00, last = 0x18D7F }, -- 西夏文增补 (Tangut Supplement)
  { name = '[西夏部件增补]', first = 0x18D80, last = 0x18DFF }, -- 西夏部件增补 (Tangut Components Supplement)
  { name = '[假名扩B]', first = 0x1AFF0, last = 0x1AFFF }, -- 假名扩B (Kana Extended-B)
  { name = '[假名补充]', first = 0x1B000, last = 0x1B0FF }, -- 假名补充 (Kana Supplement)
  { name = '[假名扩A]', first = 0x1B100, last = 0x1B12F }, -- 假名扩A (Kana Extended-A)
  { name = '[小型日文假名扩展]', first = 0x1B130, last = 0x1B16F }, -- 小型日文假名扩展 (Small Kana Extension)
  { name = '[女书]', first = 0x1B170, last = 0x1B2FF }, -- 女书 (Nushu)
  { name = '[杜普洛伊速记]', first = 0x1BC00, last = 0x1BC9F }, -- 杜普洛伊速记 (Duployan)
  { name = '[速记格式控制]', first = 0x1BCA0, last = 0x1BCAF }, -- 速记格式控制 (Shorthand Format Controls)
  { name = '[旧式计算符增补]', first = 0x1CC00, last = 0x1CEBF }, -- 旧式计算符增补 (Symbols for Legacy Computing Supplement)
  { name = '[杂项符号增补]', first = 0x1CEC0, last = 0x1CEFF }, -- 杂项符号增补 (Miscellaneous Symbols Supplement)
  { name = '[兹纳缅尼记谱]', first = 0x1CF00, last = 0x1CFCF }, -- 兹纳缅尼记谱 (Znamenny Musical Notation)
  { name = '[拜占庭乐符]', first = 0x1D000, last = 0x1D0FF }, -- 拜占庭乐符 (Byzantine Musical Symbols)
  { name = '[音乐符号]', first = 0x1D100, last = 0x1D1FF }, -- 音乐符号 (Musical Symbols)
  { name = '[古希腊记谱]', first = 0x1D200, last = 0x1D24F }, -- 古希腊记谱 (Ancient Greek Musical Notation)
  { name = '[卡克托维克数字]', first = 0x1D2C0, last = 0x1D2DF }, -- 卡克托维克数字 (Kaktovik Numerals)
  { name = '[玛雅数字]', first = 0x1D2E0, last = 0x1D2FF }, -- 玛雅数字 (Mayan Numerals)
  { name = '[太玄经]', first = 0x1D300, last = 0x1D35F }, -- 太玄经 (Tai Xuan Jing Symbols)
  { name = '[算筹]', first = 0x1D360, last = 0x1D37F }, -- 算筹 (Counting Rod Numerals)
  { name = '[数学字母符号]', first = 0x1D400, last = 0x1D7FF }, -- 数学字母符号 (Mathematical Alphanumeric Symbols)
  { name = '[萨顿手语]', first = 0x1D800, last = 0x1DAAF }, -- 萨顿手语 (Sutton SignWriting)
  { name = '[拉丁扩G]', first = 0x1DF00, last = 0x1DFFF }, -- 拉丁扩G (Latin Extended-G)
  { name = '[格拉哥里增补]', first = 0x1E000, last = 0x1E02F }, -- 格拉哥里增补 (Glagolitic Supplement)
  { name = '[西里尔扩D]', first = 0x1E030, last = 0x1E08F }, -- 西里尔扩D (Cyrillic Extended-D)
  { name = '[尼扬亨苗文]', first = 0x1E100, last = 0x1E14F }, -- 尼扬亨苗文 (Nyiakeng Puachue Hmong)
  { name = '[托托]', first = 0x1E290, last = 0x1E2BF }, -- 托托 (Toto)
  { name = '[万乔]', first = 0x1E2C0, last = 0x1E2FF }, -- 万乔 (Wancho)
  { name = '[纳格蒙达里]', first = 0x1E4D0, last = 0x1E4FF }, -- 纳格蒙达里 (Nag Mundari)
  { name = '[奥尔奥纳尔]', first = 0x1E5D0, last = 0x1E5FF }, -- 奥尔奥纳尔 (Ol Onal)
  { name = '[泰约]', first = 0x1E6C0, last = 0x1E6FF }, -- 泰约 (Tai Yo)
  { name = '[埃塞扩B]', first = 0x1E7E0, last = 0x1E7FF }, -- 埃塞扩B (Ethiopic Extended-B)
  { name = '[门德基卡库]', first = 0x1E800, last = 0x1E8DF }, -- 门德基卡库 (Mende Kikakui)
  { name = '[阿德拉姆]', first = 0x1E900, last = 0x1E95F }, -- 阿德拉姆 (Adlam)
  { name = '[印度锡亚克数字]', first = 0x1EC70, last = 0x1ECBF }, -- 印度锡亚克数字 (Indic Siyaq Numbers)
  { name = '[奥斯曼锡亚克数字]', first = 0x1ED00, last = 0x1ED4F }, -- 奥斯曼锡亚克数字 (Ottoman Siyaq Numbers)
  { name = '[阿拉伯数学字母]', first = 0x1EE00, last = 0x1EEFF }, -- 阿拉伯数学字母 (Arabic Mathematical Alphabetic Symbols)
  { name = '[麻将]', first = 0x1F000, last = 0x1F02F }, -- 麻将 (Mahjong Tiles)
  { name = '[多米诺]', first = 0x1F030, last = 0x1F09F }, -- 多米诺 (Domino Tiles)
  { name = '[扑克]', first = 0x1F0A0, last = 0x1F0FF }, -- 扑克 (Playing Cards)
  { name = '[圈字增补]', first = 0x1F100, last = 0x1F1FF }, -- 圈字增补 (Enclosed Alphanumeric Supplement)
  { name = '[圈意增补]', first = 0x1F200, last = 0x1F2FF }, -- 圈意增补 (Enclosed Ideographic Supplement)
  { name = '[图形符号]', first = 0x1F300, last = 0x1F5FF }, -- 图形符号 (Miscellaneous Symbols and Pictographs)
  { name = '[表情]', first = 0x1F600, last = 0x1F64F }, -- 表情 (Emoticons)
  { name = '[装饰符2]', first = 0x1F650, last = 0x1F67F }, -- 装饰符2 (Ornamental Dingbats)
  { name = '[交通地图]', first = 0x1F680, last = 0x1F6FF }, -- 交通地图 (Transport and Map Symbols)
  { name = '[炼金]', first = 0x1F700, last = 0x1F77F }, -- 炼金 (Alchemical Symbols)
  { name = '[几何扩展]', first = 0x1F780, last = 0x1F7FF }, -- 几何扩展 (Geometric Shapes Extended)
  { name = '[箭头C]', first = 0x1F800, last = 0x1F8FF }, -- 箭头C (Supplemental Arrows-C)
  { name = '[增补图形]', first = 0x1F900, last = 0x1F9FF }, -- 增补图形 (Supplemental Symbols and Pictographs)
  { name = '[国际象棋]', first = 0x1FA00, last = 0x1FA6F }, -- 国际象棋 (Chess Symbols)
  { name = '[图形扩A]', first = 0x1FA70, last = 0x1FAFF }, -- 图形扩A (Symbols and Pictographs Extended-A)
  { name = '[旧式计算符]', first = 0x1FB00, last = 0x1FBFF }, -- 旧式计算符 (Symbols for Legacy Computing)
  { name = '[扩B]', first = 0x20000, last = 0x2A6DF }, -- 扩B (CJK Unified Ideographs Extension B)
  { name = '[扩C]', first = 0x2A700, last = 0x2B73F }, -- 扩C (CJK Unified Ideographs Extension C)
  { name = '[扩D]', first = 0x2B740, last = 0x2B81F }, -- 扩D (CJK Unified Ideographs Extension D)
  { name = '[扩E]', first = 0x2B820, last = 0x2CEAF }, -- 扩E (CJK Unified Ideographs Extension E)
  { name = '[扩F]', first = 0x2CEB0, last = 0x2EBEF }, -- 扩F (CJK Unified Ideographs Extension F)
  { name = '[扩I]', first = 0x2EBF0, last = 0x2EE5F }, -- 扩I (CJK Unified Ideographs Extension I)
  { name = '[兼补]', first = 0x2F800, last = 0x2FA1F }, -- 兼补 (CJK Compatibility Ideographs Supplement)
  { name = '[扩G]', first = 0x30000, last = 0x3134F }, -- 扩G (CJK Unified Ideographs Extension G)
  { name = '[扩H]', first = 0x31350, last = 0x323AF }, -- 扩H (CJK Unified Ideographs Extension H)
  { name = '[扩J]', first = 0x323B0, last = 0x3347F }, -- 扩J (CJK Unified Ideographs Extension J)
  { name = '[篆书]', first = 0x3D000, last = 0x3FC3F }, -- 篆书 (Small Seal )
  { name = '[标签]', first = 0xE0000, last = 0xE007F }, -- 标签 (Tags)
  { name = '[变体增补]', first = 0xE0100, last = 0xE01EF }, -- 变体增补 (Variation Selectors Supplement)
  { name = '[私用区补充A]', first = 0xF0000, last = 0xFFFFF }, -- 私用区补充A (Supplementary Private Use Area-A)
  { name = '[私用区补充B]', first = 0x100000, last = 0x10FFFF }, -- 私用区补充B (Supplementary Private Use Area-B)
}

--- 加载期校验：确保 `charsets` 严格按 `first` 升序，且每个区间 `first <= last`。
---
--- `upper_bound` 的二分查找依赖严格升序；区间无效会导致匹配错误。
---
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

local utf8_codes = utf8.codes
local utf8_codepoint = utf8.codepoint
local utf8_len = utf8.len
local floor = math.floor

--- 二分查找：返回满足 charsets [idx].first <= code 的最大 idx
---@param  code integer 待查询的 Unicode 码位
---@return integer idx  满足条件的最大索引；`0` 表示小于所有区间起点
local function upper_bound(code)
  local left, right = 1, #charsets
  while left <= right do
    local mid = floor((left + right) / 2)
    if charsets[mid].first <= code then
      left = mid + 1
    else
      right = mid - 1
    end
  end
  return right
end

--- 挂在 env 上的缓存状态结构：
---   char_cache   : table<integer, string|boolean>   单字符 code -> name（false 表示无匹配）
---   char_cache_n : integer                          已缓存的字符数
---   text_cache   : table<string, string>          候选文本 text -> names
---   text_cache_n : integer                          已缓存的文本数

---@class CharsetCommentCache
---@field char_cache   table<integer, string|boolean>
---@field char_cache_n integer
---@field text_cache   table<string, string>
---@field text_cache_n integer

--- 缓存容量上限
local CHAR_CACHE_MAX = 8192 ---@type integer 单字符缓存容量上限
local TEXT_CACHE_MAX = 2048 ---@type integer 候选文本缓存容量上限

--- 清空表中约一半条目，返回修剪后的剩余计数
---@param tbl table 目标缓存表
---@param count integer 当前条目计数
---@return integer 修剪后的剩余计数
local function prune_half(tbl, count)
  local target = floor(count / 2)
  if target <= 0 then
    return count
  end
  local removed = 0
  for k in pairs(tbl) do
    tbl[k] = nil
    removed = removed + 1
    if removed >= target then
      break
    end
  end
  return count - removed
end

---@param cache CharsetCommentCache
---@param code integer 待查询的 Unicode 码位
---@return string | false name 单个 code 所属字符集名；无匹配返回 false
local function lookup_char(cache, code)
  local name = cache.char_cache[code]
  if name ~= nil then
    return name
  end

  local idx = upper_bound(code)
  local charset = charsets[idx]
  if charset and code <= charset.last then
    name = charset.name
  else
    name = false
  end

  if cache.char_cache_n >= CHAR_CACHE_MAX then
    cache.char_cache_n = prune_half(cache.char_cache, cache.char_cache_n)
  end
  if cache.char_cache[code] == nil then
    cache.char_cache_n = cache.char_cache_n + 1
  end
  cache.char_cache[code] = name
  return name
end

---@param cache CharsetCommentCache
---@param text string 候选文本
---@return string name 字符集名标注串（按首次出现顺序、去重，空格分隔；可能为空串）
local function match_charsets(cache, text)
  local len = utf8_len(text)
  if len == 0 then
    return ''
  end
  if len == 1 then
    local name = lookup_char(cache, utf8_codepoint(text))
    return name or '' -- name 是 string 或 false
  end

  local cached = cache.text_cache[text]
  if cached ~= nil then
    return cached
  end

  local seen, names = {}, {}
  for _, code in utf8_codes(text) do
    local name = lookup_char(cache, code)
    if name and not seen[name] then
      seen[name] = true -- 去重
      names[#names + 1] = name
    end
  end

  local suffix = table.concat(names, ' ')

  if cache.text_cache_n >= TEXT_CACHE_MAX then
    cache.text_cache_n = prune_half(cache.text_cache, cache.text_cache_n)
  end
  if cache.text_cache[text] == nil then
    cache.text_cache_n = cache.text_cache_n + 1
  end
  cache.text_cache[text] = suffix
  return suffix
end

---@param env Env
M.init = function(env)
  ---@diagnostic disable-next-line: inject-field
  env._charset_comment_cache = { char_cache = {}, char_cache_n = 0, text_cache = {}, text_cache_n = 0 }
end

---@param input Translation
---@param env   Env
---@note `cand:get_genuine()` 返回未修饰的原始候选对象。若你使用的
---       librime-lua 版本中该赋值不生效，可改为 `cand.comment = ...`。
M.func = function(input, env)
  local on = env.engine.context:get_option('charset_comment_filter')
  ---@diagnostic disable-next-line: undefined-field
  local cache = env._charset_comment_cache ---@type CharsetCommentCache
  for cand in input:iter() do
    if on then
      local suffix = match_charsets(cache, cand.text)
      local comment = cand.comment or ''
      cand:get_genuine().comment = (comment ~= '' and comment .. ' ' or '') .. suffix
    end
    yield(cand)
  end
end

M.fini = function(env)
  env._charset_comment_cache = nil
end

return M
