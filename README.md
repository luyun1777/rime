## My Rime Config

## 简介

本库是 [Rime](https://rime.im/) 输入法的一个 98、86 版五笔输入配置方案

### 方案支持：

1. 五笔98，词库来源[98wb](http://98wb.ysepan.com/)
2. 五笔86，词库来源 [rime-wubi](https://gitee.com/hi-coder/rime-wubi/)

### 初次安装

1. 下载官方 [Rime 小狼毫版本安装包](https://rime.im/download/)，并安装到目标机器
2. 下载本方案，将所有文件覆盖到 **Rime** 的用户目录下（注意备份原有配置）
3. 打开 **font** 文件夹，安装其中的 **98WB-0.otf、黑体字根.ttf** 字体
4. 重新部署 **Rime**，就可以打字了

## 使用说明

### 1. 快捷键

| 快捷键                                                       | 功能                                                         |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| <kbd>ctrl</kbd> + <kbd>grave</kbd> \| <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>grave</kbd> | 菜单项, `grave`表示<kbd>`</kbd>键                            |
| <kbd>ctrl</kbd> + <kbd>.</kbd>                               | 中英文标点切换                                               |
| <kbd>shift</kbd> + <kbd>space</kbd>                          | 全角半角切换                                                 |
| <kbd>ctrl</kbd> + <kbd>u</kbd>                               | 字符分区提示与隐藏                                           |
| <kbd>ctrl</kbd> + <kbd>o</kbd>                               | 简体转繁体切换                                               |
| <kbd>ctrl</kbd> + <kbd>shift</kbd> + <kbd>O</kbd>            | 繁体转简体切换                                               |
| <kbd>ctrl</kbd> + <kbd>h</kbd>                               | [自定义字集过滤](https://github.com/iDvel/rime-ice/blob/main/cn_dicts/8105.dict.yaml) |
| <kbd>ctrl</kbd> + <kbd>d</kbd>                               | 字词开关                                                     |
| <kbd>ctrl</kbd> + <kbd>j</kbd>                               | 拆分显示与隐藏                                               |
| <kbd>ctrl</kbd> + <kbd>p</kbd>                               | 拼音（词组）反查                                             |
| <kbd>ctrl</kbd> + <kbd>i</kbd>                               | emoji开关                                                    |
| <kbd>ctrl</kbd> + <kbd>y</kbd>                               | 显示单字的Unicode编码开关                                    |

> 默认以地球拼音反查显示单字的读音，若要显示词组的读音，可使用快捷键<kbd>ctrl</kbd>+<kbd>p</kbd>（使用opencc配置）
>
> 上表除前三项外，快捷键仅在打字时生效（即有候选项时）

### 2. 功能按键

1. 二三候选键 :<kbd>;</kbd> <kbd>'</kbd>
2. 翻页键：<kbd>-</kbd> <kbd>=</kbd>

### 3. 临时拼音输入

- 在忘了某字的五笔编码时，<kbd>z</kbd>键可以进入五笔临时拼音输入模式，并可反查五笔编码

### 4. 以下功能需`librime-lua`

1. 以`U` 开头输入任意 Unicode 字符

2. 以除`U` 外的任意大写字母开头将小写数字转化为中文大写数字，并可以进行公历、农历查询

3. 以词定字：`[` 选择词的首字，`]` 选中词的末字

4. 以`=` 开头可用做临时计算器

5. 输出统 `时间`、`日期` 、`星期`、`农历`和`节气`

| 编码                            | 说明               |
| ------------------------------- | ------------------ |
| date                            | 输出当天日期       |
| time                            | 输出当前时间       |
| dati                            | 输出当前日期和时间 |
| week                            | 输出当前星期       |
| pedl（五笔86）\| pede（五笔98） | 农历干支信息查看   |
| abrn（五笔86）\| abrt（五笔98） | 二十四节气信息查看 |

### 5. 其他说明

1. 默认开启回车清码
2. 默认候选竖排，候选数为 3
