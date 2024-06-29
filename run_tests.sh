#!/bin/sh

# ������


ROOT_DIR=.
OUTPUT_DIR=/home/cloud3/prometheus/perf
#ɾ������������
rm -rf perf
# �������Ŀ¼����������ڣ�
mkdir -p "$OUTPUT_DIR"

# �������� _test.go �ļ�
find "$ROOT_DIR" -name '*_test.go' | while read -r test_file; do
    echo "Processing file: $test_file"
    # ��ȡ����
    pkg=$(dirname "$test_file")
    echo $pkg
    # �������в��Ժ���
    grep -oP 'func \K(Test\w*)' "$test_file" | while read -r test_func; do
        echo $test_func
        # ����ִ������
        cmd="go test -v -run ^$test_func$ $pkg"
        
        # ���� perf �ű�
        ./performance_counter_920.sh "$cmd" "$OUTPUT_DIR"
    done
done
