#!/bin/sh

# ワーキングディレクトリの取得
CWD=$(cd $(dirname $0) && pwd)

# 変数定義
SCRIPT_NAME=$(basename $0)
RESULT1_FILE="$CWD/result1.out"
RESULT2_FILE="$CWD/result2.out"
LOGGER="logger -is -t $SCRIPT_NAME"
CHECK_URL="http://169.254.169.254/metadata/v1/maintenance"
#CHECK_URL="http://azure-nomupro.cloudapp.net:8080/testazure.html"
RETVAL=0

# 結果ファイルの作成
touch $RESULT1_FILE $RESULT2_FILE

# チェック用URLから EventID をgrepしてファイル出力
curl -sS $CHECK_URL | grep -i EventID > $RESULT1_FILE
IS_EVENT=$?

# 前回と今回のファイルを比較
diff -q $RESULT1_FILE $RESULT2_FILE
IS_DIFF=$?
# 差分があり、かつ、イベントが発生している時にlogger出力
# - イベント状態からイベント無し状態の遷移の時はloggerにも出さず、戻り値も0のまま
# - イベント状態からイベント状態の遷移の時は、logger に出力せず、戻り値は1
if [ $IS_EVENT -eq 0 ]; then
    if [ $IS_DIFF -gt 0 ]; then
	$LOGGER "Incoming VM Event" - $(cat $RESULT1_FILE)
    fi
    RETVAL=1
fi
mv $RESULT1_FILE $RESULT2_FILE

#echo "---$RETVAL---"
exit $RETVAL