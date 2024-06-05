#!/bin/zsh

# 运行单个策略的 hyperopt

# 函数：显示使用说明
show_usage () {
    script=$(basename $0)
    cat << END

用法: zsh $script [options] <group> <strategy>

[options]:  -c | --config      配置文件路径 (默认: user_data/strategies/<group>/config_<group>.json)
            -e | --epochs      运行的 epochs 数。默认 100
            -j | --jobs        并行作业的数量
            -l | --loss        使用的损失函数 (默认 WeightedProfitHyperOptLoss)
                 --leveraged   使用 'leveraged' 配置文件
            -n | --ndays       回测的天数。默认 30
            -s | --spaces      优化空间 (买入，ROI，追踪止损，止损，卖出)
                 --short       使用 'short' 配置文件
            -t | --timeframe   时间范围 (YYYMMDD-[YYYMMDD])。默认最近 30 天

<group>  子组（例如 NNTC）或交易所名称（binanceus，coinbasepro，kucoin 等）

<strategy>  策略名称

END
}

# 默认值

# 可用的损失函数选项
loss="WeightedProfitHyperOptLoss"
#loss="WinHyperOptLoss"

clean=0
epochs=100
jarg=""
config_file=""
short=0
leveraged=0

spaces="buy sell"

num_days=30
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

timerange="${start_date}-"

# 错误处理函数
die() { echo "$*" >&2; exit 2; }  # 打印错误信息并退出
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

# 解析命令行参数
while getopts :c:e:j:l:n:s:t:-: OPT; do
  if [ "$OPT" = "-" ]; then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#$OPT}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    c | config )     needs_arg; config_file="$OPTARG" ;;
    e | epochs )     needs_arg; epochs="$OPTARG" ;;
    l | loss )       needs_arg; loss="$OPTARG" ;;
        leveraged )  leveraged=1 ;;
    j | jobs )       needs_arg; jarg="-j $OPTARG" ;;
    n | ndays )      needs_arg; num_days="$OPTARG"; set_start_date; timerange="${start_date}-${today}" ;;
    s | spaces )     needs_arg; spaces="${OPTARG}" ;;
        short )      short=1 ;;
    t | timeframe )  needs_arg; timerange="$OPTARG" ;;
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
config_dir="${strat_dir}/config"
group_dir="${strat_dir}/${group}"
strat_file="${group_dir}/${strategy}.py"

# 检查是否为交易所
exchange_list=$(freqtrade list-exchanges -1)
if [[ "${exchange_list[@]}" =~ $group ]]; then
  echo "检测到交易所 (${group}) - 使用传统模式"
  exchange="_${group}"
  config_dir="${group_dir}"
else
  exchange=""
fi

# 设置配置文件路径
if [[ $short -ne 0 ]] ; then
    config_file="${config_dir}/config${exchange}_short.json"
fi

if [[ $leveraged -ne 0 ]] ; then
    config_file="${config_dir}/config${exchange}_leveraged.json"
fi

if [ -z "${config_file}" ] ; then
  config_file="${config_dir}/config${exchange}.json"
fi

# 检查配置文件是否存在
if [ ! -f ${config_file} ]; then
    echo ""
    echo "未找到配置文件：${config_file}"
    echo "（也许可以尝试使用 -c 选项？）"
    echo ""
    exit 0
fi

# 检查策略目录是否存在
if [ ! -d ${group_dir} ]; then
    echo ""
    echo "未找到策略目录：${group_dir}"
    echo ""
    exit 0
fi

# 检查策略文件是否存在
if [ ! -f  ${strat_file} ]; then
    echo "未找到策略文件：${strat_file}"
    exit 0
fi

# 提取时间范围的开始和结束日期
start=$(echo $timerange | cut -d "-" -f 1)
end=$(echo $timerange | cut -d "-" -f 2)
if [ -z "$end" ]; then
  end="$(date "+%Y%m%d")"
fi
timerange="${start}-${end}"

# 计算时间差
zmodload zsh/datetime
diff=$(( ( $(strftime -r %Y%m%d "$end") - $(strftime -r %Y%m%d "$start") ) / 86400 ))

# 根据天数设置最小交易次数
min_trades=$((diff * 2))

echo ""
echo "使用配置文件：${config_file} 和策略目录：${group_dir}"
echo ""

# 设置 PYTHONPATH
oldpath=${PYTHONPATH}
export PYTHONPATH="./${group_dir}:./${strat_dir}:${PYTHONPATH}"

hypfile="${group_dir}/${strategy}.json"

# 如果设置了清理选项，删除任何 hyperopt 文件
if [ ${clean} -eq 1 ]; then
  if [ -f $hypfile ]; then
    echo "删除 $hypfile"
    rm $hypfile
  fi
fi

# 打印当前日期
today=`date`
echo $today
echo "优化策略：$strategy 组：$group..."

# 设置并运行 hyperopt 命令
args="${jarg} --spaces ${spaces} --hyperopt-loss ${loss} --timerange=${timerange} --epochs ${epochs} \
    -c ${config_file} --strategy-path ${group_dir}  \
    -s ${strategy} --min-trades ${min_trades} "
cmd="freqtrade hyperopt ${args} --no-color"

cat << END

${cmd}

END
eval ${cmd}

echo ""

# 恢复 PYTHONPATH
export PYTHONPATH="${oldpath}"
