#!/bin/bash

# 运行策略的 dry run。处理 Python 路径、数据库规格、配置文件等。

script=$0

# 函数：显示使用说明
show_usage () {
    cat << END

用法: zsh $script [options] <group> <strategy>

[options]:  -k | --keep-db    保存现有数据库。默认会删除
            -l | --leveraged  使用 'leveraged' 配置文件
            -p | --port       端口号（用于命名）。可选
            -s | --short      使用 'short' 配置文件。可选

<group>  子组（例如 NNTC）或交易所名称（binanceus，coinbasepro，kucoin 等）

<strategy>  策略名称

如果指定了端口，则脚本将查找 config.json 和 config_<port>.json

如果指定了 short，则脚本将查找 config_short.json

如果指定了 leveraged，则脚本将查找 config_leveraged.json

END
}

# 函数：运行命令并输出结果
run_cmd() {
  cmd="${1}"
  echo "${cmd}"
  eval ${cmd}
}

# 默认值
keep_db=0
port=""
short=0
leveraged=0

# 错误处理函数
die() { echo "$*" >&2; exit 2; }  # 打印错误信息并退出
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

# 解析命令行参数
while getopts klp:s-: OPT; do
  if [ "$OPT" = "-" ]; then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#$OPT}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    k | keep-db )    keep_db=1 ;;
    l | leveraged )  leveraged=1 ;;
    p | port )       needs_arg; port="_$OPTARG" ;;
    s | short )      short=1 ;;
    ??* )            show_usage; die "Illegal option --$OPT" ;;  # 非法长选项
    ? )              show_usage; die "Illegal option --$OPT" ;;  # 非法短选项
  esac
done
shift $((OPTIND-1)) # 移除已解析的选项和参数

# 检查是否提供了必要的参数
if [[ $# -ne 2 ]] ; then
  echo "错误：缺少参数"
  show_usage
  exit 0
fi

group=$1
strategy=$2

strat_dir="user_data/strategies"
group_dir="${strat_dir}/${group}"
base_config="config.json"
port_config="config${port}.json"
db_url="tradesv3${port}.dryrun.sqlite"

# 检查是否为交易所
exchange_list=$(freqtrade list-exchanges -1)
if [[ "${exchange_list[@]}" =~ $group ]]; then
  echo "检测到交易所 (${group}) - 使用传统模式"
  base_config="config_${group}.json"
  port_config="config_${group}${port}.json"
  db_url="tradesv3_${group}${port}.dryrun.sqlite"
fi

# 设置配置文件路径
if [ ${short} -eq 1 ]; then
  base_config=$(echo "${base_config}" | sed "s/.json/_short.json/g")
fi

if [[ leveraged -ne 0 ]] ; then
  base_config=$(echo "${base_config}" | sed "s/.json/_leveraged.json/g")
fi

# 检查配置文件是否存在
if [ ! -f ${base_config} ]; then
    echo "未找到基本配置文件：${base_config}"
    exit 0
fi

if [ ! -f ${port_config} ]; then
    echo "未找到端口配置文件：${port_config}"
    exit 0
fi

# 检查策略目录是否存在
if [ ! -d ${group_dir} ]; then
    echo "未找到策略目录：${group_dir}"
    exit 0
fi

echo ""
echo "使用配置文件：${base_config} 和策略目录：${group_dir}"
echo ""

# 设置 PYTHONPATH
oldpath=${PYTHONPATH}
export PYTHONPATH="./${group_dir}:./${strat_dir}:${PYTHONPATH}"

# 删除之前的 dry run 数据库，除非指定保留
if [ ${keep_db} -ne 1 ]; then
  if [ -f ${db_url} ]; then
    echo "删除 ${db_url}"
    rm ${db_url}
  fi
fi

# 设置配置文件链（如果指定了端口）
if [[ ${port} == "" ]]; then
  config="${base_config}"
else
  config="${base_config} -c ${port_config}"
fi

today=`date`

cmd="freqtrade trade --dry-run -c ${config}  --db-url sqlite:///${db_url} --strategy-path ${group_dir} -s ${strategy}"

cat << END

-------------------------
$today    Dry-run strategy:$strategy for group:$group...
-------------------------

END

run_cmd "${cmd}"

echo -en "\007" # beep
echo ""

# 恢复 PYTHONPATH
export PYTHONPATH="${oldpath}"
