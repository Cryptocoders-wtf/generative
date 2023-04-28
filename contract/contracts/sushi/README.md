# Sushi nouns

- [sushi_dao](https://github.com/Cryptocoders-wtf/sushi-nouns-dao-assets/)にある寿司nounsのheadとaccessoryを使ってNounish NFTを構成する

- bodyとglassはNounsTokenのデータを参照してそのまま使う
- headとaccessoryはstorageへ書き込む

## Contractの構成
- SushiNounsToken -> SushiNounsProvider -> SushiNounsDescriptor(NounsDescriptorを中で参照)
- MixedSeeder(NounsSeeder, SushiNounsSeederをmixしたseeder)

- データ等を重複しない構成をしている
  - paletteが型問題で参照できないのでSushiNounsDescriptorにデータとして入れる
- backgroundsの画像化は試したがデータ量が多いのでgas代問題でng
  - SushiNounsDescriptorのpartsを5個にし、NFTDescriptorを改良すればできる
- mint時にseedはproviderで管理する
  - seederの受け渡しに問題でtokenで管理していない

## deploy & test
 - test/sushi.ts　にテストがある
   - これを参照すればdeployもつくれる。
 - nouns daoのcontracのデータを参照するので、mainnet forkingで動かす必要がある
