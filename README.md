项目原地址:https://github.com/nateemma/strategies
对项目进行修改和更新修复BUG，适配binance

|策略|描述|备注|
|-------|-------|-------|
NNPredict_*	|Uses neural network approaches to predict price changes|无|




回测命令
zsh user_data/strategies/scripts/download.sh binanceus
zsh user_data/strategies/scripts/download.sh binance
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_Transformer
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_LSTM


