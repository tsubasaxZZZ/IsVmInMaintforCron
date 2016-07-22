# IsVmInMaintforCron

## 実行方法
    ./IsVmInMaintforCron.sh

## Syslog 出力例
    Jul 22 20:25:54 alinsrv01 IsVmInMaintforCron.sh[61314]: Incoming VM Event - "EventID": "1a0a13a3-dc0d-4bbe-ab24-df710a3917e6",
    Jul 22 20:26:24 alinsrv01 IsVmInMaintforCron.sh[61526]: Incoming VM Event - "EventID": "1a0a13a3-dc0d-4bbe-ab24-df710a3917e6",
    Jul 22 20:26:33 alinsrv01 IsVmInMaintforCron.sh[61564]: Incoming VM Event - "EventID": "0a0a13a3-dc0d-4bbe-ab24-df710a3917e6",

## 戻り値
イベントがある場合 常に1 を返します。

## パターン
* イベント無し->イベント発生 = logger 出力 + 戻り値 1
* イベント発生->イベント発生 = **logger 出力無** + 戻り値 1
* イベント発生->イベント無し = logger 出力無し + 戻り値 0
* イベント発生->イベント発生(EventID違い) = logger 出力 + 戻り値 1

## 備考
EventID の出力の仕方次第では、うまくloggerにEventIDは出力され無いかもしれません(EventIDと:の間に改行がある等)。
