#!/bin/bash

# 日志文件
LOGFILE="install.log"

# 日志记录函数
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

# 错误处理函数
error_exit() {
    log "Error: $1"
    exit 1
}

# 检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        log "Error executing: $1"
    else
        log "Successfully executed: $1"
    fi
}
# 下载 istio-1.22.1
log "开始下载 istio..."
if [ ! -d "istio" ]; then
    git clone --branch 1.22.1  https://github.com/istio/istio.git
    check_command "git clone https://github.com/istio/istio.git"
    chmod +x -R .
else
    log "istio 已经下载，跳过此步骤."
fi

# 安装 Go 语言
GO_URL="https://github.com/Boring545/go_golang.git"
log "开始下载 Go 语言..."
if [ ! -d "go_golang" ]; then
    git clone ${GO_URL} 
    check_command "git clone ${GO_URL}"
    chmod +x -R .
    log "Go 安装完成."
else
    log "Go 安装包已经下载，跳过此步骤."
fi



# 设置 GOROOT 和 GOPATH
log "设置 Go 环境变量..."
export GOROOT=$PWD/go_golang/go
export GOPATH=$PWD/go_golang/golang
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH 
export GOSUMDB=sum.golang.org
chmod +x -R ./go_golang
go env -w GO111MODULE=on
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
log "Go 环境变量设置完成."

#安装go-junit-report
go install github.com/jstemmer/go-junit-report@latest


#将脚本移动到指定目录中
mv run_tests.sh ./istio
mv performance_counter_920.sh ./istio
mv count_test.py ./istio
mv count_perf.py ./istio
log "赋予执行权限"
chmod +x -R .

log "切换目录位置到istio文件下"
cd istio
#下载build所需docker镜像
docker pull registry.cn-hangzhou.aliyuncs.com/iloveyuanshen/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac
docker tag registry.cn-hangzhou.aliyuncs.com/iloveyuanshen/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac gcr.io/istio-testing/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac

#初始化
log "初始化构建"
make init
go mod download
mkdir  backup
mv Makefile.overrides.mk backup/
make build

log "进行test和perf测试"
./run_tests.sh

log "测试完成，使用Python脚本进行统计，安装依赖包"
pip3 install os
pip3 install pandas
pip3 install openpyxl
log "依赖安装成功，开始统计"
python count_test.py
python count_perf.py
