# VLFeat —— 计算机视觉特征库

[English](README.md) | **简体中文**

> 版本 0.9.21

VLFeat 是一个开源库，实现了多种常用的计算机视觉算法，专注于图像理解以及局部特征的提取与匹配。
支持的算法包括 Fisher 向量、VLAD、SIFT、MSER、k-means、层次 k-means、凝聚式信息瓶颈、
SLIC 超像素、Quick Shift 超像素、大规模 SVM 训练等。
该库使用 C 语言编写，以兼顾效率与兼容性，同时提供 MATLAB 接口以方便使用，并附有详细文档。
支持 Windows、Mac OS X 和 Linux。

VLFeat 采用 BSD 许可证发布（参见 `COPYING` 文件）。

文档[可在线查阅](http://www.vlfeat.org/index.html)，也随库一同提供，位于 `doc/index.html`。
另请参阅：

* [在 MATLAB 中使用](http://www.vlfeat.org/install-matlab.html)
* [使用命令行工具](http://www.vlfeat.org/install-shell.html)
* [使用 C API](http://www.vlfeat.org/install-c.html)
* [从源码编译](http://www.vlfeat.org/compiling.html)

## Syslab MLang 快速入门

要将 VLFeat 用作 Syslab MLang 工具箱，请从[此处](https://github.com/Suzhou-Tongyuan/vlfeat/archive/refs/heads/master.zip)
下载指定的 VLFeat 压缩包并解压。
启动 Syslab，运行构建脚本：

    > run <VLFEATROOT>/build_vlfeat_mlang

然后运行 VLFeat 初始化命令：

    > run <VLFEATROOT>/toolbox/vl_setup

其中，`<VLFEATROOT>` 应替换为解压后得到的 VLFeat 目录路径。
此时可通过以下命令依次运行所有 VLFeat 演示：

    > vl_demo

如需查看各个演示，请使用 `edit vl_demo` 打开并编辑该文件。

## MATLAB 快速入门

要将 VLFeat 用作 MATLAB 工具箱，请下载最新的 VLFeat
[二进制包](http://www.vlfeat.org/download/)。注意，预编译的二进制文件要求 MATLAB 2009B 或更高版本。
解压压缩包，例如在 Windows 上使用 WinZIP，在 Mac 上双击压缩包，
或在 Linux 和 Mac 上使用命令行：

    > tar xzf vlfeat-X.Y.Z-bin.tar.gz

其中，X.Y.Z 表示最新版本号。启动 MATLAB，运行 VLFeat 初始化命令：

    > run <VLFEATROOT>/toolbox/vl_setup

其中，`<VLFEATROOT>` 应替换为解压后得到的 VLFeat 目录路径。
此时可通过以下命令依次运行所有 VLFeat 演示：

    > vl_demo

如需查看各个演示，请使用 `edit vl_demo` 打开并编辑该文件。

## Octave 支持

该工具箱应当与 GNU Octave 基本兼容。GNU Octave 是一个开源的 MATLAB 替代软件。
不过，二进制发行包中不包含预编译的 GNU Octave MEX 文件。可使用以下命令进行编译：

    > cd <vlfeat directory>
    > make MKOCTFILE=<path to the mkoctfile program>

# 更新记录

- **0.9.21** 维护版本，修复错误。
- **0.9.20** 维护版本，修复错误。
- **0.9.19** 维护版本，修复少量错误，并解决使用 MATLAB 2014a 编译时的问题。
- **0.9.18** 修复多项错误；改进文档，尤其是协变特征检测器的文档；小幅增强 Fisher 向量功能。
- **0.9.17** 重写 SVM 实现，新增对 SGD 和 SDCA 优化器以及多种损失函数
  （合页损失、平方合页损失、逻辑损失等）的支持，并改进接口。
  新增基于 OpenMP 的多核计算基础设施（要求 MATLAB 2009B 或更高版本）。
  为 KD 树和 KMeans 添加 OpenMP 支持。
  新增高斯混合模型、VLAD 编码和 Fisher 向量编码（同样支持 OpenMP）。
  新增 LIOP 特征描述子。新增物体类别识别示例代码，可直接用于多个标准基准测试。
- **0.9.16** 新增 `VL_COVDET`。该函数实现了以下检测器：DoG、Hessian、Harris Laplace、
  Hessian Laplace、Multiscale Hessian、Multiscale Harris。
  同时支持仿射自适应、特征方向估计、仿射图像块上的描述子计算（包括原始图像块），
  以及传入自定义特征帧。
- **0.9.15** 新增 `VL_HOG`（HOG 特征）。新增 `VL_SVMPEGASOS`，并大幅改进 SVM 实现。
  新增 `VL_IHASHSUM`（哈希计数）。改进 INTHIST（积分直方图）。新增 `VL_CUMMAX`。
  改进 `VL_ROC` 和 VL_PR() 的实现。新增 VL_DET()，用于绘制检测错误权衡（DET）曲线。
  改进 AIB 的详细输出控制。新增对 Xcode 4.3 的支持，改进对早期及后续 Xcode 版本的支持。
  完成旧测试代码从 `toolbox/test` 的迁移，将其功能转移到 `toolbox/xtest` 中的新单元测试。
- **0.9.14** 新增 SLIC 超像素。新增 VL_ALPHANUM()。改进 Windows 二进制包，
  新增对 Visual Studio 2010 的支持。改进文档布局，并添加完整的参考文献列表。
  修复错误及其他小幅改进。许可证从 GPL 改为限制更少的 BSD 许可证。
- **0.9.13** 修复 Windows 二进制包。
- **0.9.12** 修复 `vl_compile` 及 32 位 Linux 上的架构字符串。
- **0.9.11** 修复旧版 Mac OS X 的兼容性问题，同时修复少量错误。
- **0.9.10** 改进齐次核映射，进行多项小幅调整与改进。将 Mac 上的默认架构设为 maci64。
- **0.9.9** 新增 SIFT 匹配示例。扩展 Caltech-101 分类示例，使其支持 KD 树。
- **0.9.8** 新增图像距离变换、PEGASOS、浮点 K-means、齐次核映射及 Caltech-101 分类示例。
  改进文档。
- **0.9.7** 调整 Mac OS X 二进制发行包的最低系统版本要求，以兼容较早的 Mac OS X 10.5。
- **0.9.6** 调整 GNU/Linux 二进制发行包的 C 库版本要求，以兼容较早版本的 C 库。
- **0.9.5** 新增 KD 树，以及使用 SSE 加速的向量和直方图比较代码。
  改进密集 SIFT（dsift）的实现。新增对 Snow Leopard 和 MATLAB R2009b 的支持。
- **0.9.4** 新增 Quick Shift。将 dhog 重命名为 dsift，并改进其实现与文档。
  改进教程。新增 64 位 Windows 二进制文件，以及多项其他小幅改动。
- **0.9.3** 调整命名空间（所有名称现在都以 vl_ 为前缀）。进行多项其他修改，
  以支持在 Windows 上使用 MATLAB 7 编译。
- **beta-3** 完善 ikmeans 代码。
- **beta-2** 新增多项功能。
- **beta-1** 首次公开发布。
