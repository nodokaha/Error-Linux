# Error-Linux
オリジナルのLinux distributionを作成するための試験場（無理そうならやめる。

makeコマンド一発での作成を目指してます。

Linux from Scratchより自動スクリプトを組んで手動更新で基礎を作り。自作パッケージマネージャーまたは既存の各パッケージマネージャーによる実行ファイル管理を目指す。

実質GNU/Linux distributionの違いってパッケージマネージャーの違いなのでパッケージマネージャも作成予定。

scriptブランチをクローンした方がおすすめです。

## パッケージ雛形の生成

パッケージを簡単に作成できるよう、テンプレートを自動生成するスクリプトを追加しました。

```bash
./package_new.sh <package-name> [version]
# 例
./package_new.sh hello 2.12.1
```

または `make` からも実行できます。

```bash
make package-new name=hello version=2.12.1
```

実行すると `packages/<package-name>/` に以下を作成します。

- `package.conf`: パッケージ情報（URL, checksum, 依存関係）
- `build.sh`: ダウンロード・ビルド・パッケージングのたたき台
- `README.md`: 調整手順


## pkgmgr（試作パッケージマネージャー）

新規追加した `package_new.sh` で雛形を作成し、
`packages/pkgmgr` に最小構成のパッケージ管理ツールを実装しました。

```bash
make pkgmgr-build
```

`packages/pkgmgr/out/` に `pkgmgr-*.tar.zst` が出力されます。


## ディストリビューション管理フロー

従来の `Makefile` による tier ビルドに加えて、
`pkgmgr` ベースでディストリビューションを構成するスクリプトを追加しました。

```bash
# プロファイルで指定した全パッケージをビルド
./distro_manage.sh build-all

# 生成済みパッケージを rootfs へインストールして構成
./distro_manage.sh assemble
```

プロファイルは `distribution/profiles/base.list` を編集して管理します。
`make dist-build` / `make dist-assemble` からも同じ処理を実行できます。
