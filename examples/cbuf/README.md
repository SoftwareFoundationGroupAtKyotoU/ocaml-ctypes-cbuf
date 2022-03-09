# Cbuf examples

## Files

```
.
├── bindgen.ml   # CとOCamlのスタブを生成する
├── bindings.ml  # バインドする関数型のCbufによる記述
├── example.c    # バインド先のCのライブラリ
├── example.h    # バインド先のCのライブラリのヘッダ
└── example.ml   # エントリーポイント
```

## ビルド

```sh
dune build
```

`bindgen.ml`によって`_build`内に`cbuf_gen.c`と`cbuf_gen.ml`が生成される。

## 実行

```sh
dune exec ./example.exe
```
