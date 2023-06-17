# Local nouns

- [localNouns](https://github.com/Cryptocoders-wtf/local-nouns-assets/)にあるご当地nounsのheadとaccessoryを使ってNounish NFTを構成する

- bodyとglassはNounsTokenのデータを参照してそのまま使う
- headとaccessoryはstorageへ書き込む
-- headとaccessoryは、都道府県ごとのパーツを組み合わせる

## Contractの構成
- LocalNounsToken -> LocalNounsProvider -> LocalNounsDescriptor(NounsDescriptorを中で参照)
- NounsのパーツはNounsSeeder, LocalNounsのパーツはLocalNounsSeederで採番する

## deploy & test
 - scripts/deploy_localNouns.ts　→ デプロイ
 - scripts/populate_localNouns.ts　→ パーツ画像の登録、テストミント

 - nouns daoのcontracのデータを参照するので、mainnet forkingで動かす必要がある
 -- パーツはNounsDescriptorV1で作成されたものを使用している
 -- scripts/deploy_nounsDescriptorV1.ts　→ デプロイ
 -- scripts/populate_nounsV1.ts　→ パーツ画像の登録