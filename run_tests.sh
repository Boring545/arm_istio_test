#!/bin/sh
ROOT_DIR="."
OUTPUT_DIR_PERF="perf_out"
OUTPUT_DIR_TEST="test_out"

# 删除已有输出结果
rm -rf "$OUTPUT_DIR_PERF"
rm -rf "$OUTPUT_DIR_TEST"

# 创建输出目录（如果不存在）
mkdir -p "$OUTPUT_DIR_PERF"
mkdir -p "$OUTPUT_DIR_TEST"

# 查找所有 _test.go 文件并执行测试
find "$ROOT_DIR" -name '*_test.go' | while read -r test_file; do
    # 提取包名
    pkg=$(dirname "$test_file")

    # 查找所有测试函数
    grep -oP 'func \K(Test\w*)' "$test_file" | while read -r test_func; do
        # 生成执行命令
        cmd="go test -v -race -run ^$test_func$ $pkg"
        path=$(echo "$pkg" | sed 's:.*/::')
        file="$test_func-$path"
        
        # 执行测试命令
        $cmd > "$file.txt" 2>&1
        
        # 将测试结果移动到测试输出目录
        echo $test_func >> "$file.txt"
        echo "($pkg)" >> "$file.txt"
        mv "$file.txt" "$OUTPUT_DIR_TEST"
        
        # 调用 perf 脚本
        ./performance_counter_920.sh "$cmd" "$OUTPUT_DIR_PERF"
    done
done

