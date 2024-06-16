项目原地址:https://github.com/nateemma/strategies
对项目进行修改和更新修复BUG，适配binance

|策略|描述|备注|
|-------|-------|-------|
|NNPredict_*	|使用神经网络方法预测价格变化|无|
|Anomaly*|用于识别买入/卖出的异常检测算法。|Anomaly.py 是主要逻辑，Anomaly_*.py包含算法|
|NNTC_*	|神经网络三位一体分类器 - 预测持有/买入/卖出事件的方法|无|
|TSPredict|时间序列预测 |无

**NNPredict
|策略|描述|
| Attention         | self-Attention (Transformer Attention) |
| AdditiveAttention | Additive-Attention                     |
| CNN               | Convolutional Neural Network           |
| Ensemble          | Ensemble/Stack of several Classifiers  |
| GRU               | Gated Recurrent Unit                   |
| LSTM              | Long-Short Term Memory (basic)         |
| LSTM2             | Two-tier LSTM                          |
| LSTM3             | Convolutional/LSTM Combo               |
| MLP               | Multi-Layer Perceptron                 |
| Multihead         | Multihead Self-Attention               |
| TCN               | Temporal Convolutional Network         |
| Transformer       | Transformer                            |
| Wavenet           | Simplified Wavenet                     |
| Wavenet2          | Full Wavenet                           |


回测命令
zsh user_data/strategies/scripts/download.sh binanceus
zsh user_data/strategies/scripts/download.sh binance
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_Transformer
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_LSTM


