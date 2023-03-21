# fontデータのsmart contractの作成

- font_lower_case_letters
- font_upper_case_letters
- font_numbers
- font_symbols

のフォルダーに、大文字、小文字、数字、記号のSVG画像を用意する。
各SVGのファイルのファイル名は変更しないようにしてください。
用意する画像は、このレポジトリに入っているフォントの画像ファイルと同様に、pathのdのみで構成した画像にしてください。tranformなども利用不可です。

```
npx ts-node gen.ts
```

font.sol が生成されます。
