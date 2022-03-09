# Cbuf

This is a fork repository of [ocaml-ctypes](https://github.com/ocamllabs/ocaml-ctypes)
Original README.md is [here](./README.original.md)

## インストール

```sh
$ make && make install
```

NOTE: Ctypes がすでにインストールされている場合は、先にアンインストールしてください。

```sh
$ make uninstall
```

## 使用方法

以下の C の関数をバインドしたいとする。

```c
void *memcpy(void *restrict dst, const void *restrict src, size_t n);
int last_cbuf(int in, unsigned char *out1, unsigned char *out2);
int first_cbuf(unsigned char *out1, unsigned char *out2, int in);
```

Cbuf による関数型の記述は以下のようになる。

```ml
module C (F : Cbuf.FOREIGN) = struct
  (* val memcpy : bytes ocaml -> Unsigned.size_t -> bytes * unit return *)
  let memcpy =
    foreign "memcpy"
      (ocaml_bytes @-> size_t
      @-> retbuf ~cposition:`First (buffer 4 ocaml_bytes) (returning void))
  (* val last_cbuf : int -> (bytes * bytes) * int return *)
  let last_cbuf =
    foreign "last_cbuf"
      (int
      @-> retbuf (buffer 4 ocaml_bytes @* buffer 8 ocaml_bytes) (returning int)
      )
  (* val first_cbuf : int -> (bytes * bytes) * int return *)
  let first_cbuf =
    foreign "first_cbuf"
      (int
      @-> retbuf ~cposition:`First
            (buffer 4 ocaml_bytes @* buffer 8 ocaml_bytes)
            (returning int))
end
```

これらの関数型の記述を元に C と OCaml のプログラムを生成する。

```ml
Cbuf.write_c fmt1 (module Bindings.C);
Cbuf.write_ml fmt2 (module Bindings.C)
```

生成したコードを元に C の関数を OCaml から呼び出す。

```ml
module C = Bindings.C (Cbuf_gen)

let dest, _ = C.memcpy_cbuf src n in ...
let (out1, out2), _ = C.last_cbuf 3 in ...
let (out1, out2), ret = C.first_cbuf 4 in ...
```

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
├── cbuf_static.ml          # 追加した主な関数など (@*, retbuf, buffer, cpositionなど)
...
```

## Links

- [Cbuf example project](./examples/cbuf/README.md)
- [ocaml-sodium binding using Cbuf](https://github.com/atrn0/ocaml-sodium)
- [OCaml 用 FFI ライブラリ Ctypes の参照渡し関数への拡張](./grad_thesis.pdf)
