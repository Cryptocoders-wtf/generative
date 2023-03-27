# fontデータのsmart contractの作成

Fully-On-Chain.solで使えるfontデータを持ったsmart contractの作成について。

まず、フォントの元となる画像ファイルを用意します。ASCIIの表示に必要な大文字と小文字のアルファベット、数字、記号のセットが必要です。

`generative/contract/contracts/fonts` 以下のフォルダー

- font_lower_case_letters
- font_upper_case_letters
- font_numbers
- font_symbols

に、こちらで用意したSVG画像が上記フォルダに入っています。
独自にフォントを作る場合、各SVGのファイルのファイル名は絶対に変更しないで上記フォルダにあるファイル名にそろえてください。
SVG画像はこのレポジトリに入っている画像ファイルと同様に、pathのdのみで構成したSVG画像を用意してくさい。tranformやstyleなども利用不可です。gを使ってnestもしないでください。取り込みに失敗します。


画像をsmart contractのソースコードに変換します。

```
npx ts-node gen.ts
```

`generative/contract/contracts/fonts/font.sol` が生成されます。

contract名(contractの後の、`LondrinaSolid`) を変更してください。


`generative/contract/scripts/deploy_font.ts` を変更してデプロイ。
デプロイ時にpayout用にdesignerのaddressが必要。

デプロイ時に、smart contractのaddressが表示されるのでメモっておく。
(verifyも忘れずに）

# 他スマコンから呼び出す

`contract/contracts/samples/SimpleFontToken.sol`

が実装の参考となります。FontをNFTに組み込んで表示させる場合は`SVG.text`を利用します。

以下、`SVG.text`を使うまでの手順。

intefaceのimport 

```
import '../../packages/graphics/IFontProvider.sol';
```

font コントラクトを呼び出すためにintefaceの定義

```
IFontProvider public immutable font;
```

利用する側のコンストラクトで、fontのスマコンのaddressをセット。(後述するdeployスクリプトで、今回デプロイしたfont smart contractのaddressを渡して受け取る)

```
constructor(IFontProvider _font) {
  font = _font;
}
```

font -> textはSVGのpathとして、文字の画像を取得する

```
  SVG.text(font, "hello"),
```

このスマコンのデプロイ方法は`scripts/deploy_simplefont.ts`を参考に。
デプロイ時にfontのスマコンのアドレスを渡す。

```
const contract = await factory.deploy("SimpleFontToken", "Font", lonrinaFont);
```

以上で、デプロイしたfontが使えます。

fontは一度デプロイすると、どのスマコンからも利用可能となります。
デプロイしたスマコンは、addressを共有してください。
