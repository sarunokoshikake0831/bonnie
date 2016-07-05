### 要件

* git
* node v6.2.2 以上
* npm
* MongoDB
* OpenSSL
* python2.7 (node のモジュール bcrypt のインストールに必要)


### 構築手順

以下の手順は Linux 用。
上記の要件がインストールできれば、Windows* や MacOS X でも動作するはず。


##### 0. 要件の準備

上記要件を予めインストールしておく。


##### 1. ソースコードの取得

    % git clone https://github.com/sarunokoshikake0831/bonnie.git
    % cd bonnie


##### 2. クライアントのコンパイル (デバグ用バージョン)

    % npm install
    % npm run build

リリースバージョンを

    % npm run build-dist

でコンパイルできようにしたかったのだが、uglify が ES2015 に対応していないため、現状は不可。
uglify が対応してくれたら、リリースバージョンのビルドにも対応する予定。


##### 3. MongoDB の起動

    % su -u mongodb mongod --config /etc/mongodb.conf

ユーザを登録しないと使えない。
近日中にユーザを登録するスクリプトを作成予定 (つまり、そのスクリプトができるまで使えない ...)。


##### 4. SSL のオレオレ証明書と秘密鍵を作成 (質問に何と答えるかは、スクリプト内のコメント参照)

    % cd local/certs
    % sh ../utils/gen-dummy-certs.sh

##### 5. HTTP サーバを起動

    % cd ../..
    % sudo npm run http-server
