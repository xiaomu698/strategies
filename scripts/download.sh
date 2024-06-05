#!/bin/zsh

# 设置环境变量以忽略 TensorFlow 警告
export TF_CPP_MIN_LOG_LEVEL=2

# 交易所列表，确保 kucoin 在最后，因为它相对较慢
declare -a list=("binanceus" "binance" "ftx" "kucoin")

# 函数：运行命令并输出结果
run_cmd() {
  cmd="${1}"
  echo "${cmd}"
  eval ${cmd}
  if [ $? -ne 0 ]; then
    echo "Error: Command failed - ${cmd}"
    exit 1
  fi
}

# 函数：显示脚本的使用说明
show_usage () {
    script=$(basename $0)
    cat << END

该脚本用于下载历史数据

用法: zsh $script [options] [<exchange>]

[options]:  -h | --help       打印此帮助信息
            -l | --leveraged  使用 'leveraged' 配置文件。可选
            -n | --ndays      回测的天数。默认值为 ${num_days}
            -s | --short      使用 'short' 配置文件。可选

<exchange>  交易所名称 (binanceus, kucoin, 等等)。可选

END
}

# 设置默认值
num_days=180
start_date=$(date +"%Y%m%d")

# 函数：根据操作系统和天数设置起始日期
set_start_date () {
  os=$(uname)
  if [ "$os" = "Darwin" ]; then
    start_date=$(date -j -v-${num_days}d +"%Y%m%d")
  else
    start_date=$(date -d "${num_days} days ago " +"%Y%m%d")
  fi
}

# 获取起始日期
set_start_date

# 获取当前日期和时间范围
today=$(date +"%Y%m%d")
timerange="${start_date}-${today}"

# 固定参数
fixed_args="-t 5m"
short=0
leveraged=0

# 错误处理函数
die() { echo "$*" >&2; exit 2; }
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

# 解析命令行参数
while getopts hln:s-: OPT; do
  if [ "$OPT" = "-" ]; then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#$OPT}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    h | help )       show_usage; exit 0 ;;
    l | leveraged )  leveraged=1 ;;
    n | ndays )      needs_arg; num_days="$OPTARG"; set_start_date; timerange="${start_date}-${today}" ;;
    s | short )      short=1 ;;
    ??* )            show_usage; die "Illegal option --$OPT" ;;
    ? )              show_usage; die "Illegal option --$OPT" ;;
  esac
done
shift $((OPTIND-1))

# 检查是否指定了交易所
if [[ $# -gt 0 ]] ; then
  echo "运行交易所: ${1}"
  list=(${1})
fi

# 遍历交易所列表并下载数据
for exchange in "${list[@]}"; do
  echo ""
  echo "${exchange}"
  echo ""

  strat_dir="user_data/strategies/${exchange}"
  config_dir="user_data/strategies/config"
  config_file="${config_dir}/config.json"

  # 如果使用短期配置文件
  if [ ${short} -eq 1 ]; then
    fixed_args="--trading-mode futures ${fixed_args}"
    config_file="${strat_dir}/config_${exchange}_short.json"
  fi

  # 如果使用杠杆配置文件
  if [ ${leveraged} -eq 1 ]; then
    config_file="${strat_dir}/config_${exchange}_leveraged.json"
  fi

  run_cmd "freqtrade download-data -c ${config_file} --timerange=${timerange} ${fixed_args}"
  run_cmd "freqtrade download-data -c ${config_file} --timerange=${timerange} ${fixed_args} -p BTC/USD BTC/USDT"
done
