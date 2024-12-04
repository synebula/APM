#!/usr/bin/env bash

# 判断文件是否存在内容。用法：is_configured 'keyword' file;
is_configured() {
  lines=$(cat $2 | grep $1)
  if [ -n "$lines" ]; then
    return 0
  fi
  return 1
}

# 解析 INI 文件，获取指定 section 下的所有项（不包括 section 标题），同时处理键值对中的空格
parse_ini_section() {
    local ini=$1
    local section=$2
    local in_section=0

    # 使用 awk 解析文件，处理键值对中的空格
    awk -v section="$section" '
        # 忽略空行和注释行
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*;/ { next }
        /^[[:space:]]*#/ { next }
        
        # 遇到 section 标题时，根据是否匹配目标 section 来控制解析状态
        /^\[.*\]/ {
            # 如果遇到目标节标题，开启解析
            if ($0 == "[" section "]") {
                in_section = 1
            } else {
                in_section = 0
            }
        }
        # 如果在目标 section 内，且不是节标题，打印键值对
        in_section && $1 !~ /^\[/ && $1 != "" && $1 !~ /^\s*#/ {
            # 使用正则表达式去除键和值两边的空格，并输出键值对
            print $1
        }
    ' "$ini"
}
