#!/bin/sh

# ワーキングディレクトリの取得
CWD=$(cd $(dirname $0) && pwd)

# 変数定義
SCRIPT_NAME=$(basename $0)
RESULT1_FILE="$CWD/result1.out"
RESULT2_FILE="$CWD/result2.out"
LOGGER="logger -is -t $SCRIPT_NAME"
CHECK_URL="http://169.254.169.254/metadata/v1/maintenance"
#CHECK_URL="http://localhost/testazure.html"
RETVAL=0

# 結果ファイルの作成
touch $RESULT1_FILE $RESULT2_FILE

# チェック用URLから EventID をgrepしてファイル出力
curl -sS $CHECK_URL | grep -i EventID > $RESULT1_FILE
IS_EVENT=$?

# 前回と今回のファイルを比較
diff -q $RESULT1_FILE $RESULT2_FILE
# 差分があり、かつ、イベントが発生している時
# (イベント状態からイベント無し状態の遷移を考慮)
if [ $? -gt 0 -a $IS_EVENT -eq 0 ]; then
    $LOGGER "Incoming VM Event"
    RETVAL=1
fi
mv $RESULT1_FILE $RESULT2_FILE

exit $RETVAL