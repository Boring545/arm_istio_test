# istio安装及测试脚本指南

## 脚本介绍

### install.sh
`install.sh`是用于安装和测试istio的脚本。该脚本会首先安装必要的工具，然后调用`run_tests.sh`进行`go test`和性能测试，最后调用Python脚本统计测试结果。

### run_tests.sh
`run_tests.sh`是一个自动化脚本，用于执行`go test -v`测试以及调用性能测试脚本。该脚本的目的是分别测试每个测试项。

### count_perf.sh
`count_perf.sh`是一个用于处理`run_tests`输出文件的Python脚本，将测试结果统计为Excel格式。

### performance_counter_920.sh
`performance_counter_920.sh`是用于性能测试的脚本。

### count_test.py 和 count_perf.py
这两个Python脚本分别用于统计测试结果和性能测试结果。

## 执行流程

1. **克隆仓库**
   ```bash
   git clone https://github.com/Boring545/arm_istio_test.git

1. **安装所需内容**
   ```bash
   ./install.sh

1. **开始测试**
   ```bash
   ./run_tests.sh

1. **收集测试结果**
   ```bash
   ./count_test.py
   ./count_perf.sh
