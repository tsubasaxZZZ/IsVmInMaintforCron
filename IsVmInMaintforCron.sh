#!/bin/sh

# ワーキングディレクトリの取得
CWD=$(cd $(dirname $0) && pwd)

# 変数定義
SCRIPT_NAME=$(basename $0)
RESULT_NEW="$CWD/_event"
RESULT_OLD="$CWD/current_event"
LOGGER="logger -is -t $SCRIPT_NAME"
CHECK_URL="http://169.254.169.254/metadata/v1/maintenance"
#CHECK_URL="http://azure-nomupro.cloudapp.net:8080/testazure.html"
JSONFILE="testazure.json"
JQ="$CWD/jq"
RETVAL=0

mkdir $RESULT_NEW $RESULT_OLD 2>/dev/null

# チェック用URLから JSON ダウンロード
curl -sS $CHECK_URL | tee $JSONFILE | grep -qi EventID 
IS_EVENT=$?

# 差分があり、かつ、イベントが発生している時にlogger出力
# - イベント状態からイベント無し状態の遷移の時はloggerにも出さず、戻り値も0のまま
# - イベント状態からイベント状態の遷移の時は、logger に出力せず、戻り値は1
if [ $IS_EVENT -eq 0 ]; then
    $JQ -r '[.EventID,.EventCreationTime] | @csv' $JSONFILE | while read EVENT
    do
	ID=$(echo $EVENT | cut -d ',' -f 1 | sed 's/"//g')
	DATETIME=$(echo $EVENT | cut -d ',' -f 2 | sed 's/"//g')

	# ファイル名で使える
	FNAME=$ID-$(date -d "$DATETIME" +%Y%m%d%H%M%S)

	# イベントIDごとの空ファイル作成/日付はEventCreationTimeにしておく
	touch -d "$DATETIME" $RESULT_NEW/$FNAME
    done

    # 前回と今回の比較
    diff $RESULT_NEW $RESULT_OLD >/dev/null 2>&1
    if [ $? -gt 0 ]; then
	$LOGGER "Incoming VM Event" - $(ls -1 $RESULT_NEW)
    fi

    RETVAL=1
fi
rm -rf $RESULT_OLD
mv $RESULT_NEW $RESULT_OLD

#echo "---$RETVAL---"
exit $RETVAL