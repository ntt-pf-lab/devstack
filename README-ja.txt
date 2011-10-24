OpenStack環境構築手順(Devstack+Quantum版)

前提条件
    下記のコンポーネントをシングルノードで実行する手順です
        Nova, Glance, Keystone, Dashboard, Quantum, MySQL, RabbitMQ
    OSはUbuntu 11.04 Desktop x86_64で動作確認しています
    インターネットに接続できる環境(apt-get installが実行できる)が必要です
    実行ユーザはパスワード無しでsudoが実行できるように設定されている必要があります

セットアップ手順
1. セットアップ先のマシンにUbuntu 11.04 x86_64 をクリーンインストールする
2. /etc/sudoers を設定する
3. sudo apt-get install -y git
4. git clone https://github.com/ntt-pf-lab/devstack.git
5. cd devstack
6. git checkout -b int002 origin/int002
7. 必要に応じてlocalrcファイルを設定してください

起動手順
1. ./stack.sh
2. screen -x -S nova
3. ブラウザで http://localhost/ を開くとDashboardが表示されます
   ユーザ名はadminとdemo、パスワードは予めlocalrc中でADMIN_PASSWORD環境変数
   を設定するか、設定していなければランダム生成されたものがログ中に表示されます

終了手順
1. screen画面で"Ctrl+A" -> "\" -> "y"と入力

制約事項
    easy_install を利用してPythonのライブラリパスを追加しているため
    インストール先を変えて再セットアップするためには、下記ファイルの編集が必要です。
    /usr/local/lib/python2.7/dist-packages/easy-install.pth

    VMの起動はDashboardから実行できますが
    ネットワークの追加は、Dashboardのメニューからは正常に行えません。
    ネットワークの追加には、下記のようなコマンドを用います
        nova-manage network create --label=private_2-2 --project_id=2 --fixed_range_v4=10.0.3.0/24 --bridge_interface=br-int --num_networks=1 --network_size=32


