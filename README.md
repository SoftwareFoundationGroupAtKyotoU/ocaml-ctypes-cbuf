# Cbuf

This is a fork repository of [ocaml-ctypes](https://github.com/ocamllabs/ocaml-ctypes)

## インストール

```sh
$ make && make install
```

NOTE: Ctypes がすでにインストールされている場合は、先にアンインストールしてください。

```sh
$ make uninstall
```

## 使用方法

## 開発

Cbuf は Cstubs のコードを元に実装しています。

Cstubs から主に変更を加えたファイル:

[./src/cbuf](./src/cbuf)

```
.
├── cbuf.ml                 # Cbufのエントリーポイント (FOREIGN, write_c, write_mlなど)
├── cbuf.mli                # public interface
├── cbuf_generate_c.ml      # Cbufに対応するCの生成ロジックを追加した
├── cbuf_generate_ml.ml     # Cbufに対応するOCamlの生成ロジックを追加した (pattern_and_exp_of_cbuffersなど)
├── cbuf_internals.ml       # 生成されたOCamlのモジュールからインポートされるモジュール
├── cbuf_static.ml         # 追加した主な関数など (@*, retbuf, buffer, cpositionなど)
...
```

## Links

- [Cbuf examples](./examples/cbuf/README.md)
