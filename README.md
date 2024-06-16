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

# NNTC信号类型对照表

以下是本项目中使用的各种信号类型及其描述：

| SignalType          | 描述                                                                                            |
|---------------------|-------------------------------------------------------------------------------------------------|
| Bollinger_Width     | 基于布林带宽度                                                                                  |
| DWT                 | 基于收盘价的离散小波变换（DWT）。比较滚动版本和前瞻版本的DWT差异                                |
| DWT2                | 检测前瞻DWT中的局部最小值和最大值                                                               |
| Fisher_Bollinger    | 费舍尔/威廉姆斯比率和布林带距离                                                                  |
| Fisher_Williams     | 费舍尔/威廉姆斯比率                                                                             |
| High_Low            | 检测最近窗口的高点/低点                                                                         |
| Jump                | 检测大幅跳水或跳涨                                                                              |
| MACD                | 经典的MACD交叉                                                                                   |
| MACD2               | 检测MACD直方图的低点和高点                                                                      |
| MACD3               | 检测MACD直方图的统计高/低区域                                                                   |
| Money_Flow          | 查金资金流量指标（MFI）                                                                         |
| Min_Max             | 检测过去和未来窗口的最小值和最大值                                                              |
| N_Sequence          | 检测长时间的连续上涨/下跌                                                                       |
| Oversold            | 使用多种超卖/超买指标                                                                           |
| Profit              | 检测利润/亏损的跳跃                                                                             |
| Peaks_Valleys       | 检测价格的峰值和谷值                                                                            |
| Stochastic          | 使用快速D/快速K随机指标                                                                         |
| Swing               | 检测价格的统计大波动                                                                            |

# NNTC神经网络分类器类型对照表

以下是本项目中使用的各种神经网络分类器类型及其全称、全称翻译和描述：

| NNTClassifierType  | 全称                            | 全称翻译                                    | 描述                                              |
|--------------------|---------------------------------|---------------------------------------------|---------------------------------------------------|
| Attention          | self-Attention (Transformer Attention) | 自注意力（Transformer注意力）              | 一种用于计算输入序列各部分相互依赖关系的机制，用于增强序列建模。 |
| AdditiveAttention  | Additive-Attention              | 加性注意力                                  | 通过学习加权求和不同的输入特征来选择性关注相关信息。          |
| CNN                | Convolutional Neural Network     | 卷积神经网络                                | 用于图像和视频处理的神经网络，通过卷积层提取空间特征。       |
| Ensemble           | Ensemble/Stack of several Classifiers | 集成/多分类器堆叠                           | 多个模型组合以提高整体性能，通常通过投票或加权平均。         |
| GRU                | Gated Recurrent Unit             | 门控循环单元                                | 一种改进的循环神经网络，具有门控机制，解决长序列中的梯度消失问题。 |
| LSTM               | Long-Short Term Memory (basic)   | 长短期记忆网络（基础版）                    | 一种循环神经网络，通过记忆细胞和门控机制来保持长期依赖关系。  |
| LSTM2              | Two-tier LSTM                    | 双层长短期记忆网络                          | 两层堆叠的LSTM，用于更深层次的序列建模。                 |
| LSTM3              | Convolutional/LSTM Combo         | 卷积/长短期记忆网络组合                     | 结合卷积层和LSTM层，用于提取时空特征。                  |
| MLP                | Multi-Layer Perceptron           | 多层感知器                                  | 基本的全连接神经网络，用于分类和回归任务。               |
| Multihead          | Multihead Self-Attention         | 多头自注意力                                | 多头自注意力机制，通过并行计算多个注意力来增强模型的表达能力。 |
| TCN                | Temporal Convolutional Network   | 时序卷积网络                                | 用于序列建模的卷积神经网络，具有较长的感受野。            |
| Transformer        | Transformer                      | Transformer                                | 无需循环结构，通过注意力机制并行处理序列数据的模型。        |
| Wavenet            | Simplified Wavenet               | 简化版Wavenet                              | 用于生成音频信号的卷积神经网络，具有因果卷积结构。         |
| Wavenet2           | Full Wavenet                     | 完整版Wavenet                              | 完整版的Wavenet，具有更复杂的结构和更多的层。             |

请根据上表中的分类器类型对各模型进行了解和使用。

回测命令
zsh user_data/strategies/scripts/download.sh binanceus
zsh user_data/strategies/scripts/download.sh binance
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_Transformer
zsh user_data/strategies/scripts/test_strat.sh -n 30 NNPredict NNPredict_LSTM


