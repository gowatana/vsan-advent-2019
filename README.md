# vSAN のつぶやき。 Advent Calendar 2019 | 設定ファイル集

## 使用方法

ここの設定ファイルを使用する PowerCLI スクリプトについて

* [deploy-1box-vsan Wiki](https://github.com/gowatana/deploy-1box-vsan/wiki)

## ファイルとスクリプトのダウンロード

```
PS> git clone --recursive https://github.com/gowatana/vsan-advent-2019.git
PS> cd ./vsan-advent-2019/
PS> git submodule update --remote
PS> cd ./deploy-1box-vsan/
PS> ./check_base_setting.ps1 ../configs/advent-2019/conf_vSAN-Cluster-20191201.ps1
```
