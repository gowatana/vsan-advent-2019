# vSAN のつぶやき。 Advent Calendar 2019 | 設定ファイル集

## 使用方法の説明

ここの設定ファイルを使用する PowerCLI スクリプトについて

* [deploy-1box-vsan Wiki](https://github.com/gowatana/deploy-1box-vsan/wiki)

## ファイルとスクリプトのダウンロード

設定ファイルのダウンロードと、スクリプトの更新。

```
PS> git clone --recursive https://github.com/gowatana/vsan-advent-2019.git
PS> cd ./vsan-advent-2019/
PS> git submodule update --remote
```

## スクリプトの実行例

事前確認。

```
PS> cd ./deploy-1box-vsan/
PS> ./check_base_setting.ps1 ../configs/advent-2019/conf_vSAN-Cluster-20191201.ps1
```

vSAN クラスタの作成。

```
PS> .\setup_vSAN-Cluster.ps1 ..\configs\advent-2019\conf_vSAN-Cluster-20191202a.ps1
```

vSAN クラスタの削除。

```
PS> .\setup_vSAN-Cluster.ps1 ..\configs\advent-2019\conf_vSAN-Cluster-20191202a.ps1
```
