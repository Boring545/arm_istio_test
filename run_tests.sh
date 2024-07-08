#!/bin/sh

# ������


ROOT_DIR=.
OUTPUT_DIR_Perf=/home/cloud3/prometheus/perf
OUTPUT_DIR_Test=/home/cloud3/prometheus/test_r
#ɾ������������
rm -rf perf
rm -rf test_r
# �������Ŀ¼����������ڣ�
mkdir -p "$OUTPUT_DIR_Perf"
mkdir -p "$OUTPUT_DIR_Test"
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
        path=$(echo "$pkg" | sed 's:.*/::')
        file="$test_func-$path"
        $cmd > $file.txt 2>&1
        echo $test_func >>$file.txt
        echo "($pkg)" >>$file.txt
        mv $file.txt $OUTPUT_DIR_Test
        # ���� perf �ű�
        ./performance_counter_920.sh "$cmd" "$OUTPUT_DIR_Perf" 
    done
done
