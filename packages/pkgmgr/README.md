# pkgmgr

`pkgmgr` は `.tar.zst` 形式のシンプルなバイナリパッケージを
インストール/削除/一覧表示するための最小パッケージ管理ツールです。

## build

```bash
cd packages/pkgmgr
./build.sh
```

生成物: `out/pkgmgr-0.1.0-1-x86_64.tar.zst`

## install

```bash
sudo tar --zstd -xf out/pkgmgr-0.1.0-1-x86_64.tar.zst -C /
```

## usage

```bash
pkgmgr install <package.tar.zst>
pkgmgr remove <name>
pkgmgr list
pkgmgr info <name>
```
