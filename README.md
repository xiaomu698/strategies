项目原地址:https://github.com/nateemma/strategies
对项目进行修改和更新修复BUG，适配binance

|策略|描述|备注|
|-------|-------|-------|
|NNPredict_*	|使用神经网络方法预测价格变化|无|
|Anomaly*|用于识别买入/卖出的异常检测算法。|Anomaly.py 是主要逻辑，Anomaly_*.py包含算法|
|NNTC_*	|神经网络三位一体分类器 - 预测持有/买入/卖出事件的方法|无|
|TSPredict|时间序列预测 |无


*NNPredict
| 缩写           | 全称                            | 全称翻译                                    | 描述                                              |
|----------------|---------------------------------|---------------------------------------------|---------------------------------------------------|
| Attention      | self-Attention (Transformer Attention) | 自注意力（Transformer注意力）              | 一种用于计算输入序列各部分相互依赖关系的机制，用于增强序列建模。 |
| AdditiveAttention | Additive-Attention              | 加性注意力                                  | 通过学习加权求和不同的输入特征来选择性关注相关信息。          |
| CNN            | Convolutional Neural Network     | 卷积神经网络                                | 用于图像和视频处理的神经网络，通过卷积层提取空间特征。       |
| Ensemble       | Ensemble/Stack of several Classifiers | 集成/多分类器堆叠                           | 多个模型组合以提高整体性能，通常通过投票或加权平均。         |
| GRU            | Gated Recurrent Unit             | 门控循环单元                                | 一种改进的循环神经网络，具有门控机制，解决长序列中的梯度消失问题。 |
| LSTM           | Long-Short Term Memory (basic)   | 长短期记忆网络（基础版）                    | 一种循环神经网络，通过记忆细胞和门控机制来保持长期依赖关系。  |
| LSTM2          | Two-tier LSTM                    | 双层长短期记忆网络                          | 两层堆叠的LSTM，用于更深层次的序列建模。                 |
| LSTM3          | Convolutional/LSTM Combo         | 卷积/长短期记忆网络组合                     | 结合卷积层和LSTM层，用于提取时空特征。                  |
| MLP            | Multi-Layer Perceptron           | 多层感知器                                  | 基本的全连接神经网络，用于分类和回归任务。               |
| Multihead      | Multihead Self-Attention         | 多头自注意力                                | 多头自注意力机制，通过并行计算多个注意力来增强模型的表达能力。 |
| TCN            | Temporal Convolutional Network   | 时序卷积网络                                | 用于序列建模的卷积神经网络，具有较长的感受野。            |
| Transformer    | Transformer                      | Transformer                                | 无需循环结构，通过注意力机制并行处理序列数据的模型。        |
| Wavenet        | Simplified Wavenet               | 简化版Wavenet                              | 用于生成音频信号的卷积神经网络，具有因果卷积结构。         |
| Wavenet2       | Full Wavenet                     | 完整版Wavenet 


回测命令
zsh user_data/strategies/scripts/download.sh binanceus
zsh user_data/strategies/scripts/download.sh binance
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_Transformer
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_LSTM


