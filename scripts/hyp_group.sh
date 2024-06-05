#!/bin/zsh

# 设置默认值
epochs=100
spaces="buy sell"
num_days=180
start_date=$(date +"%Y%m%d")

# 函数：根据操作系统和天数设置起始日期
set_start_date () {
  os=$(uname)
  if [ "$os" = "Darwin" ]; then
    start_date=$(date -j -v-${num_days}d +"%Y%m%d")
  else
    start_date=$(date -d "${num_days} days ago" +"%Y%m%d")
  fi
}

# 获取起始日期
set_start_date

# 获取当前日期和时间范围
today=$(date +"%Y%m%d")
timerange="${start_date}-${today}"
download=0
jobs=0
lossf="ExpectancyHyperOptLoss"
random_state=$RANDOM
alt_config=""

# 获取 CPU 核心数
if [ "$(uname)" = "Darwin" ]; then
  num_cores=$(sysctl -n hw.ncpu)
else
  num_cores=$(nproc)
fi
min_cores=$((num_cores - 2))

# 函数：运行命令并输出结果
run_cmd () {
  cmd="${1}"
  echo "${cmd}"
  eval ${cmd}
}

# 函数：显示脚本的使用说明
show_usage () {
    script=$0
    cat << END

Usage: zsh $script [options] <group> <pattern>

[options]:  -c | --config      Specify an alternate config file (just name, not directory or extension)
            -d | --download    Downloads latest market data before running hyperopt. Default is ${download}
            -e | --epochs      Number of epochs to run. Default: ${epochs}
            -j | --jobs        Number of parallel jobs to run
            -l | --loss        Loss function to use (default: ${lossf})
            -n | --ndays       Number of days of backtesting. Defaults to ${num_days}
            -s | --spaces      Optimisation spaces (any of: buy, roi, trailing, stoploss, sell). Use quotes for multiple
            -t | --timeframe   Timeframe (YYYMMDD-[YYYMMDD]). Defaults to last ${num_days} days

<group>     Name of group (subdir or exchange)
<pattern>   The prefix of the strategy files. Example: "PCA" will process all strat files beginning with "PCA_"
            TIP: you can also specify the "*" wildcard, but you must enclose this in quotes
                 Example: "NNTC_*LSTM" will test all files that match that pattern.
                 Very useful if you updated a signal type, or a model architecture

END
}

# 函数：检查是否使用 zsh 运行脚本
check_shell () {
  is_zsh= ; : | is_zsh=1
  if [[ "${is_zsh}" != "1" ]]; then
    echo ""
    echo "ERR: Must use zsh for this script"
    exit 0
  fi
}

# 函数：输出信息到日志文件和终端
add_line () {
        echo "${1}" >> $logfile
        echo "${1}"
}

# 函数：运行 Hyperopt 优化并记录日志
run_hyperopt () {
    add_line "----------------------"
    add_line "${strat}"
    add_line "----------------------"
    add_line ""
    add_line "freqtrade hyperopt ${1}"
    add_line ""
    cmd="freqtrade hyperopt ${1} --no-color >> $logfile"
    eval ${cmd}
}

# 错误处理函数
die() { echo "$*" >&2; exit 2; }
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

# 检查是否使用 zsh
check_shell

# 解析命令行参数
while getopts c:d:e:j:l:n:s:t:-: OPT; do
  if [ "$OPT" = "-" ]; then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#$OPT}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    c | config )     needs_arg; alt_config="${OPTARG}" ;;
    d | download )   download=1 ;;
    e | epochs )     needs_arg; epochs="$OPTARG" ;;
    j | jobs )       needs_arg; jobs="$OPTARG" ;;
    l | loss )       needs_arg; lossf="$OPTARG" ;;
    n | ndays )      needs_arg; num_days="$OPTARG"; set_start_date; timerange="${start_date}-${today}" ;;
    s | spaces )     needs_arg; spaces="${OPTARG}" ;;
    t | timeframe )  needs_arg; timerange="$OPTARG" ;;
    \? )             show_usage; die "Illegal option --$OPT" ;;
    ??* )            show_usage; die "Illegal option --$OPT" ;;
    ? )              show_usage; die "Illegal option --$OPT" ;;
  esac
done
shift $((OPTIND-1))

# 检查参数数量
if [[ $# -ne 2 ]] ; then
  echo ""
  echo "ERR: Missing argument(s)"
  echo ""
  show_usage
  exit 0
fi

# 设置变量
group=$1
pattern=$2

strat_dir="user_data/strategies"
config_dir="${strat_dir}/config"
group_dir="${strat_dir}/${group}"
logfile="hyp_${group}_${pattern:gs/*/}.log"

# 设置配置文件路径
if [[ -n ${alt_config} ]]; then
  config_file="${config_dir}/${alt_config}.json"
else
  config_file="${config_dir}/config.json"
fi

# 检查配置文件是否存在
if [ ! -f ${config_file} ];then
    echo "config file not found: ${config_file}"
    exit 0
fi

# 检查策略目录是否存在
if [ ! -d ${group_dir} ]; then
    echo "Strategy dir not found: ${group_dir}"
    exit 0
fi

# 查找匹配的策略文件
strat_list=()
for file in ${group_dir}/${pattern}.py; do
  if [[ -f "$file" ]]; then
    strat_list+=($(basename "$file" .py))
  fi
done

num_files=${#strat_list[@]}
if [[ $num_files -eq 0 ]]; then
  echo "ERR: no strategy files found for pattern: ${pattern}"
  exit 0
fi

# 计算最小交易数
start=$(echo $timerange | cut -d "-" -f 1)
end=$(echo $timerange | cut -d "-" -f 2)
if [ -z "$end" ];then
  end="$(date "+%Y%m%d")"
fi
timerange="${start}-${end}"

# 计算时间差
zmodload zsh/datetime
diff=$(( ( $(strftime -r %Y%m%d "$end") - $(strftime -r %Y%m%d "$start") ) / 86400 ))

# 设置最小交易数
min_trades=$((diff * 2))

# 初始化日志文件
echo "" >$logfile
add_line ""
today=`date`
add_line "============================================="
add_line "Running hyperopt for group: ${group}..."
add_line "Date/time: ${today}"
add_line "Time range: ${timerange}"
add_line "Config file: ${config_file}"
add_line "Strategy dir: ${group_dir}"
add_line ""

# 设置 PYTHONPATH
oldpath=${PYTHONPATH}
export PYTHONPATH="./${group_dir}:./${strat_dir}:${PYTHONPATH}"

# 设置环境变量以忽略 TensorFlow 警告
export TF_CPP_MIN_LOG_LEVEL=2

# 下载最新数据（如果需要）
if [ ${download} -eq 1 ];then
    add_line "Downloading latest data..."
    run_cmd "freqtrade download-data  -t 5m --timerange=${timerange} -c ${config_file}"
fi

# 设置并行作业参数
jarg=""
if [ ${jobs} -gt 0 ];then
    jarg="-j ${jobs}"
else
  # 对于 kucoin，减少并行作业数
    if [ "$group" = "kucoin" ]; then
      jarg="-j ${min_cores}"
    fi
fi

# 设置 hyperopt 参数
hargs=" -c ${config_file} ${jarg} --strategy-path ${group_dir} --timerange=${timerange} --hyperopt-loss ${lossf}"
hargs="${hargs} --random-state ${random_state}"

# 运行每个策略的 Hyperopt
for strat in ${strat_list}; do
  add_line ""

  args="${hargs} --epochs ${epochs} --space ${spaces} -s ${strat} --min-trades ${min_trades} "
  run_hyperopt ${args}
done

# 运行汇总结果的脚本
echo ""
python user_data/strategies/scripts/SummariseHyperOptResults.py ${logfile}
echo ""

echo ""
echo "Full output is in file: ${logfile}:"
echo ""

# 恢复 PYTHONPATH
export PYTHONPATH="${oldpath}"
