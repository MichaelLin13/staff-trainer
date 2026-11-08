# 五線譜練習（Godot 4.6）

練習辨識五線譜的小遊戲：高音譜／低音譜、可設定音域（以中央Do為 0 個八度）與音符種類（全音符、2分音符、4分音符）。答對 +1、答錯 -1，滿 10 分回首頁。

## 網頁版
推送到 main 分支後，GitHub Actions（`.github/workflows/deploy-web.yml`）會自動用 Godot 4.6.1 匯出網頁版並發佈到 GitHub Pages。

## 字型與圖示
repo 不存二進位檔。建置時 `tools/prepare_assets.py` 會：
- 下載 Bravura 音樂字型（SIL OFL）
- 下載 Noto Sans CJK TC，只保留程式與場景用到的中文字（SIL OFL）
- 產生勾選框圖示

本機開發時先執行一次 `pip install fonttools pillow` 和 `python tools/prepare_assets.py`。新增中文字後，刪掉 `fonts/NotoSansTC-Subset.otf` 再執行一次。
