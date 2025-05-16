install.packages("gridExtra")
library(tidyverse)
library(gridExtra)
library(dplyr)
library(lubridate)
install.packages("zoo")  
library(zoo)
library(stringr)

#問1
#やること
#超おおまかな方針としては1つ1つのcsvファイルを規定のやり方に則って
#整えていく。それを縦結合すれば終わる。
#その整えていくべきやり方をanswerファイルを参考にしながら整理していく。
#何をすればanswerファイルになるのか
#1つの地域、1つの企業産業大分類につき、3つのインデックスがある
#それは総数、単一事業所企業、複数事業所企業である
#必要なカラムは結構限られているのでそれだけ選べば良い
#


df_answer1 <- read_csv("./answer/PB05_rep_1_answer.csv")
View(df_answer1)

#まずは2012年の仙台のcsvファイルから加工していく
#forで回す処理は後回し。1つのファイルの処理の仕方が分からないのに
#いきなりforループを考えるのはただの

#データの読み込み
#宮城：1、栃木：2、東京：3、神奈川：4とする

df1_2012 <- read_csv("./in/2012/g01300-04.csv",
                     locale = locale(encoding = "shift-jis"),
                     skip = 14)
View(df1_2012)

#まずはカラム2の「ti.」を削除する
df1_2012_1 <- df1_2012 %>%
  mutate(...2 = str_replace(...2,"ti.",""))
View(df1_2012_1)

#次に企業産業大分類の表記揺れを補正する
df1_2012_2 <- df1_2012_1 %>%
  mutate(企業産業大分類 = str_replace_all(企業産業大分類, "　", "") %>% 
           str_replace_all(" ", "") %>%  
           str_replace_all("～", "") %>% 
           str_replace_all("（", "(") %>%  
           str_replace_all("）", ")")) 
View(df1_2012_2)

#この問でいらないカラムを削除するよ。
df1_2012_2 <- df1_2012_2[,c(2,7,8,9,10,11,22,25,26,27,38,41,42,43,44,55)]
View(df1_2012_2)

#次の操作を考える
#pivot_longer or wierを使えばいけそう
#総数、単事業所企業などは後回し、最後に手入力した方が早い
#単一事業所企業は企業数と事務所数が一致するので最初で
#カラムを作っていた方が都合がよさそう

df1_2012_2 <- df1_2012_2 %>%
  mutate(事務所数=`企業等数(事業所数)`)
df1_2012_2 <- df1_2012_2[,c(1,2,3,4,5,6,7,8,17,9,10,11,12,13,14,15,16)]

#pivot_lonerをしていく
#やることとしては、カラム3以降に関して5つ進んだら縦に並べていく感じ

df1_2012_a <- df1_2012_2 %>%
  pivot_longer(cols = c(3,8,13), 
               values_to = "企業等数")
df1_2012_a <- df1_2012_a[,c(1,2,16)]


df1_2012_b <- df1_2012_2 %>%
  pivot_longer(cols = c(4,9,14), 
               values_to = "事業所数")
df1_2012_b <- df1_2012_b[,c(16)]


df1_2012_c <- df1_2012_2 %>%
  pivot_longer(cols = c(5,10,15), 
               values_to = "従業者数_人")
df1_2012_c <- df1_2012_c[,c(16)]

df1_2012_d <- df1_2012_2 %>%
  pivot_longer(cols = c(6,11,16), 
               values_to = "売上金額_百万円")
df1_2012_d <- df1_2012_d[,c(16)]

df1_2012_e <- df1_2012_2 %>%
  pivot_longer(cols = c(7,12,17), 
               values_to = "付加価値額_百万円")
df1_2012_e <- df1_2012_e[,c(16)]




df1_2012_3 <- bind_cols(df1_2012_a,df1_2012_b,df1_2012_c,df1_2012_d,df1_2012_e)


View(df1_2012_3)

#力技だがやっとできた
#あとは必要なカラムを追加していく。
df1_2012_4 <- df1_2012_3 %>%
  mutate(集計年=2012) %>% 
  mutate(市区町村コード=...1) %>%
  mutate(都道府県コード="04") %>%
  mutate(事業所区分 = rep(c("0_総数", "1_単一事業所企業", "2_複数事業所企業"), length.out = n()))

df1_2012_4 <- df1_2012_4[,c(-1)]
df1_2012_4 <- df1_2012_4[,c(7,9,8,1,10,2,3,4,5,6)]
View(df1_2012_4)  


#後は、2012年と2016年それぞれでfor文を回して縦結合するのみ。


# ファイル末尾のリスト
files <- c("04", "09", "13", "14")

# データを格納するリスト
df_list <- list()

# ループ処理
for (file in files) {
  # ファイルパスの作成
  file_path <- paste0("./in/2012/g01300-", file, ".csv")
  
  # CSVを読み込む
  df <- read_csv(file_path,
                 locale = locale(encoding = "shift-jis"),
                 skip = 14)
  
  # 「ti.」の削除
  df <- df %>%
    mutate(...2 = str_replace(...2, "ti.", ""))
  
  # 企業産業大分類の表記揺れ補正
  df <- df %>%
    mutate(企業産業大分類 = str_replace_all(企業産業大分類, "　", "") %>% 
             str_replace_all(" ", "") %>%  
             str_replace_all("～", "") %>% 
             str_replace_all("（", "(") %>%  
             str_replace_all("）", ")"))
  
  # 必要なカラムを選択
  df <- df[, c(2,7,8,9,10,11,22,25,26,27,38,41,42,43,44,55)]
  
  # 事務所数の追加
  df <- df %>%
    mutate(事務所数 = `企業等数(事業所数)`)
  df <- df[, c(1,2,3,4,5,6,7,8,17,9,10,11,12,13,14,15,16)]
  
  # pivot_longer() を適用
  df_a <- df %>%
    pivot_longer(cols = c(3,8,13), values_to = "企業等数") %>%
    select(1,2,16)
  
  df_b <- df %>%
    pivot_longer(cols = c(4,9,14), values_to = "事業所数") %>%
    select(16)
  
  df_c <- df %>%
    pivot_longer(cols = c(5,10,15), values_to = "従業者数_人") %>%
    select(16)
  
  df_d <- df %>%
    pivot_longer(cols = c(6,11,16), values_to = "売上金額_百万円") %>%
    select(16)
  
  df_e <- df %>%
    pivot_longer(cols = c(7,12,17), values_to = "付加価値額_百万円") %>%
    select(16)
  
  # bind_cols() で横結合
  df_combined <- bind_cols(df_a, df_b, df_c, df_d, df_e)
  
  # 集計年、都道府県コード、事業所区分の追加
  df_final <- df_combined %>%
    mutate(集計年 = 2012,
           市区町村コード = ...1,
           都道府県コード = file,
           事業所区分 = rep(c("0_総数", "1_単一事業所企業", "2_複数事業所企業"), length.out = n())) %>%
    rename(産業大分類 = 企業産業大分類) %>%
    select(-1) %>%
    select(7,9,8,1,10,2,3,4,5,6)
  
  # リストに格納
  df_list[[file]] <- df_final
}

# 全データを縦結合
df_2012_all <- bind_rows(df_list)

# 結果を確認
View(df_2012_all)

#次に2016年のファイルに対しても処理を行う
#産業大分類がアルファベット順になっているさいあく
#アルファベット順とデータ読み込みのスキップ数を考慮すれば
#2012年のデータの処理と変わらない


df1_2016 <- read_csv("./in/2016/03000 (1).csv",
                     locale = locale(encoding = "shift-jis"),
                     skip = 20)
View(df1_2016)

df1_2016_1 <- df1_2016 %>%
  mutate(...2 = str_replace(...2,"ti.",""))
View(df1_2016_1)

#次に企業産業大分類の表記揺れを補正する
df1_2016_2 <- df1_2016_1 %>%
  mutate(企業産業大分類 = str_replace_all(企業産業大分類, "　", "") %>% 
           str_replace_all(" ", "") %>%  
           str_replace_all("～", "") %>% 
           str_replace_all("（", "(") %>%  
           str_replace_all("）", ")")) 
df1_2016_2 <- df1_2016_2 %>%
  arrange(...2,企業産業大分類)


View(df1_2016_2)

#この問でいらないカラムを削除するよ。
df1_2016_2 <- df1_2016_2[,c(2,7,8,9,10,11,22,25,26,27,38,41,42,43,44,55)]
View(df1_2016_2)

#次の操作を考える
#pivot_longer or wierを使えばいけそう
#総数、単事業所企業などは後回し、最後に手入力した方が早い
#単一事業所企業は企業数と事務所数が一致するので最初で
#カラムを作っていた方が都合がよさそう

df1_2016_2 <- df1_2016_2 %>%
  mutate(事務所数=`企業等数(事業所数)`)
df1_2016_2 <- df1_2016_2[,c(1,2,3,4,5,6,7,8,17,9,10,11,12,13,14,15,16)]

#pivot_lonerをしていく
#やることとしては、カラム3以降に関して5つ進んだら縦に並べていく感じ

df1_2016_a <- df1_2016_2 %>%
  pivot_longer(cols = c(3,8,13), 
               values_to = "企業等数")
df1_2016_a <- df1_2016_a[,c(1,2,16)]


df1_2016_b <- df1_2016_2 %>%
  pivot_longer(cols = c(4,9,14), 
               values_to = "事業所数")
df1_2016_b <- df1_2016_b[,c(16)]


df1_2016_c <- df1_2016_2 %>%
  pivot_longer(cols = c(5,10,15), 
               values_to = "従業者数_人")
df1_2016_c <- df1_2016_c[,c(16)]

df1_2016_d <- df1_2016_2 %>%
  pivot_longer(cols = c(6,11,16), 
               values_to = "売上金額_百万円")
df1_2016_d <- df1_2016_d[,c(16)]

df1_2016_e <- df1_2016_2 %>%
  pivot_longer(cols = c(7,12,17), 
               values_to = "付加価値額_百万円")
df1_2016_e <- df1_2016_e[,c(16)]




df1_2016_3 <- bind_cols(df1_2016_a,df1_2016_b,df1_2016_c,df1_2016_d,df1_2016_e)


View(df1_2016_3)

#力技だがやっとできた
#あとは必要なカラムを追加していく。
df1_2016_4 <- df1_2016_3 %>%
  mutate(集計年=2012) %>% 
  mutate(市区町村コード=...1) %>%
  mutate(都道府県コード="04") %>%
  mutate(事業所区分 = rep(c("0_総数", "1_単一事業所企業", "2_複数事業所企業"), length.out = n())) %>%
  rename(産業大分類 = 企業産業大分類)

df1_2016_4 <- df1_2016_4[,c(-1)]
df1_2016_4 <- df1_2016_4[,c(7,9,8,1,10,2,3,4,5,6)]

View(df1_2016_4)

#2016年のループ文を作る



# ファイル名のリスト（末尾の番号）
files <- c("1", "2", "3", "4")

# 都道府県コード（filesの順番に対応）
codes <- c("04", "09", "13", "14")

# 縦結合するためのリスト
df_list <- list()

# ループ処理開始
for (i in seq_along(files)) {
  file <- files[i]
  prefecture_code <- codes[i]  # 順番に 04, 09, 13, 14 を割り当てる
  
  # ファイルパスの作成
  file_path <- paste0("./in/2016/03000 (", file, ").csv")
  
  # CSVを読み込む
  df <- read_csv(file_path,
                 locale = locale(encoding = "shift-jis"),
                 skip = 20)
  
  # 「ti.」の削除
  df <- df %>%
    mutate(...2 = str_replace(...2, "ti.", ""))
  
  # 企業産業大分類の表記揺れ補正
  df <- df %>%
    mutate(企業産業大分類 = str_replace_all(企業産業大分類, "　", "") %>% 
             str_replace_all(" ", "") %>%  
             str_replace_all("～", "") %>% 
             str_replace_all("（", "(") %>%  
             str_replace_all("）", ")")) 
  
  # 企業産業大分類のアルファベット順にソート
  df <- df %>%
    arrange(...2, 企業産業大分類)
  
  # 必要なカラムを選択
  df <- df[, c(2,7,8,9,10,11,22,25,26,27,38,41,42,43,44,55)]
  
  # 事務所数の追加
  df <- df %>%
    mutate(事務所数 = `企業等数(事業所数)`)
  df <- df[, c(1,2,3,4,5,6,7,8,17,9,10,11,12,13,14,15,16)]
  
  # pivot_longer() を適用
  df_a <- df %>%
    pivot_longer(cols = c(3,8,13), values_to = "企業等数") %>%
    select(1,2,16)
  
  df_b <- df %>%
    pivot_longer(cols = c(4,9,14), values_to = "事業所数") %>%
    select(16)
  
  df_c <- df %>%
    pivot_longer(cols = c(5,10,15), values_to = "従業者数_人") %>%
    select(16)
  
  df_d <- df %>%
    pivot_longer(cols = c(6,11,16), values_to = "売上金額_百万円") %>%
    select(16)
  
  df_e <- df %>%
    pivot_longer(cols = c(7,12,17), values_to = "付加価値額_百万円") %>%
    select(16)
  
  # bind_cols() で横結合
  df_combined <- bind_cols(df_a, df_b, df_c, df_d, df_e)
  
  # 集計年、都道府県コード、事業所区分の追加
  df_final <- df_combined %>%
    mutate(集計年 = 2016,
           市区町村コード = ...1,
           都道府県コード = prefecture_code,  # files の順番に応じた都道府県コードを設定
           事業所区分 = rep(c("0_総数", "1_単一事業所企業", "2_複数事業所企業"), length.out = n())) %>%
    rename(産業大分類 = 企業産業大分類)
  
  # カラムの順番調整
  df_final <- df_final[, c(-1)]
  df_final <- df_final[, c(7,9,8,1,10,2,3,4,5,6)]
  
  # リストに格納
  df_list[[file]] <- df_final
}

# 全データを縦結合
df_2016_all <- bind_rows(df_list)

# 結果を確認
head(df_2016_all)


# 結果を確認
View(df_2016_all)

#2012年と2016年のデータを縦結合すれば問一は終わり

df_2012_2016 <- bind_rows(df_2012_all,df_2016_all)
View(df_2012_2016)

#csvファイルとして抽出する
write_csv(df_2012_2016,"PB05_rep_1_5023117.csv",
          
          na="NA")

#問2
#
#
#
#
#

df_answer2 <- read_csv("./answer/PB05_rep_2_answer.csv")
View(df_answer2)

library(readxl)
df_2021 <- read_excel("./in/2021/h2_003.xlsx",
                      skip = 13)
View(df_2021)

#いらないカラムを消去
df_2021 <- df_2021[,c(2,3,4,5,6,7,8,18)]

#地域コードの番号以外の削除

df_2021_1 <- df_2021 %>%
  mutate(地域区分 = str_remove(地域区分, "_.*"))
View(df_2021_1)

#企業産業大分類の表記揺れの補正
df_2021_1 <- df_2021_1 %>%
  mutate(企業産業大分類 = str_replace_all(企業産業大分類, "　", "") %>% 
           str_replace_all(" ", "") %>%  
           str_replace_all("～", "") %>% 
           str_replace_all("（", "(") %>%  
           str_replace_all("）", ")")) 

View(df_2021_1)

#企業産業大分類をアルファベット順に変更
df_2021_2 <- df_2021_1 %>%
  arrange(地域区分,企業産業大分類)

View(df_2021_2)

df_2021_3 <- df_2021_2 %>%
  rename(市区町村コード = 地域区分,
         事業所区分 = `単一・複数`,
         産業大分類 = 企業産業大分類,
         企業等数 = ...5,
         事業所数 = ...6,
         従業者数_人 = ...7,
         売上金額_百万円 = ...8,
         付加価値額_百万円 = ...18) %>%
  mutate(集計年 = 2021) %>%
  mutate(都道府県コード = str_sub(市区町村コード, 1, 2))

View(df_2021_3)

df_2021_gg <- df_2021_3[,c(9,10,1,2,3,4,5,6,7,8)]
View(df_2021_gg)

#csvファイルとして抽出する
write_csv(df_2021_gg,"PB05_rep_2_5023117.csv",
      
          na="NA")


#問3
df_answer3 <- read_csv("./answer/PB05_rep_3_answer.csv")
View(df_answer3)

#スライドのヒントには書いていないけど、都道府県全体のデータが消えている。
#いや、もしかしたら変換マスタを使うことで自動的に都道府県全体のデータは
#消えるのかも知れない。多分そう
#変換マスタの使い方を考えるべきやな
#数値カラムに変更するのは後ででいい


#一旦縦結合

df3 <- bind_rows(df_2012_2016,df_2021_gg)
View(df3)

#次に産業大分類においていらないレコードを消す。
#なんかおかしいと思ったら、answerファイルの産業大分類の
#全角半角が統一されていなくて草
#もはやこっちが個別で対応するしかないようだ

df3_1 <- df3 %>%
  filter(!str_detect(産業大分類, "AR全産業\\(Ｓ公務を除く\\)") &  # 括弧をエスケープ
           !str_detect(産業大分類, "CR非農林漁業\\(Ｓ公務を除く\\)") &
           !str_detect(産業大分類, "AR全産業\\(S公務を除く\\)") &
           !str_detect(産業大分類, "CR非農林漁業\\(S公務を除く\\)"))  # Ｓ が全角か確認

View(df3_1)

#次に変換マスタを適応させる。
#これでanswerファイルとインデックス数がそろうはずだ。


df_master <- read_csv("./in/市区町村変換マスタ_20191001更新.csv",
                     locale = locale(encoding = "shift-jis"))
View(df_master)





#df3_1 に市区町村コードの変換を適用

# df3_1 に市区町村コードの変換を適用
df3_2 <- df3_1 %>%
  left_join(df_master, by = c("市区町村コード" = "OLD_CITY_CODE")) %>%  
  filter(!is.na(NEW_CITY_CODE)) %>%  
  mutate(市区町村コード = NEW_CITY_CODE,  
         都道府県コード = NEW_PREF_CODE,  
         市区町村名 = NEW_CITY_NAME) %>%  
  select(-NEW_CITY_CODE, -NEW_PREF_CODE, -NEW_CITY_NAME)

df3_2 <- df3_2 %>%
  rename(都道府県名=NEW_PREF_NAME)

#とりま順番並び替える
#その前に産業大分類のコードと名前を分離させよう


df3_2 <- df3_2 %>%
  mutate(
    産業大分類コード = str_extract(産業大分類, "^[A-Z]+"),  # 先頭のアルファベット部分を抽出
    産業大分類名 = str_replace(産業大分類, "^[A-Z]+", "")  # アルファベット部分を削除し、残りを取得
  )

df3_2 <- df3_2[,c(-4)]
df3_2 <- df3_2[,c(1,2,10,3,11,12,13,4,5,6,7,8,9)]

View(df3_2)

#なんかインデックス数違うよなんで？
#めんどくさいけど調べた結果、answerファイルには栃木市が全部無くなっていた。
#やっと理解出来た
#統合後は、結果が＋されるみたいだ。
#めっちゃ時間かかったよ。
#


df3_2 <- df3_2 %>%
  mutate(
    企業等数 = as.integer(ifelse(企業等数 == "-", 0, 企業等数)),  # "-" → 0, 整数変換
    事業所数 = as.integer(ifelse(事業所数 == "-", 0, 事業所数)),  # "-" → 0, 整数変換
    従業者数 = as.integer(ifelse(従業者数_人 == "-", 0, 従業者数_人)),  # "-" → 0, 整数変換
    売上金額_百万円 = as.numeric(ifelse(売上金額_百万円 == "-", 0, 
                                       ifelse(売上金額_百万円 == "X", NA, 売上金額_百万円))),  # "-" → 0, "X" → NA, 数値変換
    付加価値額_百万円 = as.numeric(ifelse(付加価値額_百万円 == "-", 0, 
                                        ifelse(付加価値額_百万円 == "X", NA, 付加価値額_百万円)))  # "-" → 0, "X" → NA, 数値変換
  )

# ② 統合後の市区町村ごとに数値データを合計
df3_final <- df3_2 %>%
  group_by(集計年,都道府県コード, 都道府県名,市区町村コード,市区町村名,産業大分類コード,産業大分類名,事業所区分) %>%  # 統合後の市区町村ごとに集約
  summarise(
    企業等数 = sum(企業等数_int, na.rm = TRUE),
    事業所数 = sum(事業所数_int, na.rm = TRUE),
    従業者数_人 = sum(従業者数_int, na.rm = TRUE),
    売上金額_百万円 = sum(売上金額_百万円_float, na.rm = TRUE),
    付加価値額_百万円 = sum(付加価値額_百万円_float, na.rm = TRUE),
    .groups = "drop"  # `group_by()` の影響を解除
  )

# 結果を確認
View(df3_final)

#csvファイルとして抽出する
write_csv(df3_final,"PB05_rep_3_5023117.csv",
          
          na="NA")



#問4
df_answer4 <- read_csv("./answer/PB05_rep_4_answer.csv")
View(df_answer4)


df3_final <- df3_final[,c(-2,-3,-9,-10,-12)]
View(df3_final)


df4_1 <- df3_final %>%
  filter(集計年 != 2016) %>%  # 集計年が2016の行を削除
  filter(事業所区分 == "0_総数")  # 事業所区分が"0_総数"の行のみ残す

df4_1 <- df4_1[,c(-6)]
View(df4_1)

library(dplyr)

# ① 従業員一人当たり付加価値額を計算
df4_1 <- df4_1 %>%
  mutate(従業員一人当たり付加価値額 = 付加価値額_百万円 / 従業者数_人)

# ② 2012年と2021年のデータを取得
df_growth <- df4_1 %>%
  filter(集計年 %in% c(2012, 2021)) %>%
  select(市区町村コード,市区町村名, 産業大分類コード,産業大分類名,集計年, 従業員一人当たり付加価値額) %>%
  pivot_wider(names_from = 集計年, values_from = 従業員一人当たり付加価値額, names_prefix = "年") %>%
  filter(!is.na(年2012) & !is.na(年2021)) %>%  
  mutate(生産性変化率 = (年2021 - 年2012) / 年2012) %>%  
  filter(is.finite(生産性変化率)) %>%  
  filter(!is.na(生産性変化率)) %>%  
  mutate(生産性変化率 = round(生産性変化率, 4)) %>%  
  arrange(desc(生産性変化率)) %>%  
  slice_head(n = 30)  

# 結果を表示
View(df_growth)

df4_2 <- df_growth[,c(-5,-6)]
df4_gg <- df4_2 %>%
  mutate(生産性ランキング = row_number())
View(df4_gg)

#csvファイルとして抽出する
write_csv(df4_gg,"PB05_rep_4_5023117.csv",
          
          na="NA")
























