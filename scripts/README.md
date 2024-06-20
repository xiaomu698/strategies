| Script                          | Description                                                                                                                              |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|cleanup.sh	|删除 user_data 子目录（如 hyperopt、backtesting、plots 等）中的旧文件。默认情况下，删除30天以上的文件。|
|download.sh	|下载一个交易所的蜡烛图数据。默认下载所有交易所的数据。|
|test_strat.sh	|测试指定交易所的单个策略。|
|hyp_strat.sh	|对指定交易所的单个策略运行超参数优化。|
|dryrun_strat.sh	|在指定交易所上对策略进行模拟运行，处理PYTHONPATH、db-url等配置。|
|run_strat.sh	|在指定交易所上实时运行策略，处理PYTHONPATH、db-url等配置。|
|test_group.sh	|测试一组策略并总结结果。支持使用通配符，非常实用。|
|hyp_group.sh	|对一组策略运行超参数优化（支持使用通配符）。|
|SummariseTestResults.py	|总结 test_group.sh（或任何回测文件）的输出结果。注意：这是Python脚本，不是Shell脚本。|
|SummariseHyperOptTestResults.py	|总结 hyp_group.sh（或任何超参数优化输出）的结果。|
|ShowTestResults.py	Summarise*.py |脚本将结果保存为JSON文件。此脚本以表格形式显示这些结果。|
