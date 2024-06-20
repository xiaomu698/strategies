|Script	|Description|
|cleanup.sh	|删除 user_data 子目录（如 hyperopt、backtesting、plots 等）中的旧文件。默认情况下，删除30天以上的文件。|
|download.sh	|下载一个交易所的蜡烛图数据。默认下载所有交易所的数据。|
|test_strat.sh	|测试指定交易所的单个策略。|
|hyp_strat.sh	|对指定交易所的单个策略运行超参数优化。|
|dryrun_strat.sh	|在指定交易所上对策略进行模拟运行，|处理PYTHONPATH、db-url等配置。|
|run_strat.sh	|在指定交易所上实时运行策略，处理PYTHONPATH、db-url等配置。|
|test_group.sh	|测试一组策略并总结结果。支持使用通配符，非常实用。|
|hyp_group.sh	|对一组策略运行超参数优化（支持使用通配符）。|
|SummariseTestResults.py	|总结 test_group.sh（或任何回测文件）的输出结果。注意：这是Python脚本，不是Shell脚本。|
|SummariseHyperOptTestResults.py	|总结 hyp_group.sh（或任何超参数优化输出）的结果。|
|ShowTestResults.py	Summarise*.py |脚本将结果保存为JSON文件。此脚本以表格形式显示这些结果。|
指定 -h 选项以获取帮助。

请注意，大多数脚本都假设在交易所目录中存在一个配置文件，文件名格式为：
config_<exchange>.json（例如 config_binanceus.json）。

run_strat.sh 和 dryrun_strat.sh 脚本期望使用一个“真实”的配置文件，该文件应指定volume filters等。

我为每个交易所提供参考配置文件（在每个交易所文件夹中）。这些文件使用静态pairlists，因为VolumePairlist不适用于回测或超参数优化。
要生成候选pairlist，使用如下命令：
freqtrade test-pairlist -c <config>
其中 <config> 是用于实时或模拟运行的“真实”配置文件。
该命令将生成通过过滤器的交易对列表。然后你可以将该列表复制到你的测试配置文件中。
记得将单引号（'）改为双引号（"）。

我发现每隔几周需要刷新一次列表。

Short Trading
做空需要使用单独的配置文件，并且（目前）使用静态pairlists。
脚本已更新为接受 --short 参数，这将使用配置文件
config_<exchange>_short.json，该文件必须在交易所目录中。

请注意，下载和超参数优化针对基于做空的策略会非常慢。
