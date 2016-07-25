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


##### 2. クライアントのコンパイル

    % npm install
    % npm run build

リリースバージョンは

    % npm run build-dist

でコンパイルできる。


##### 3. MongoDB の起動

    % su -u mongodb mongod --config /etc/mongodb.conf


##### 4. DB の初期化

    % mongo localhost/bonnie --quiet local/utils/initdb.js


##### 5. SSL のオレオレ証明書と秘密鍵を作成 (質問に何と答えるかは、スクリプト内のコメント参照)

    % cd local/certs
    % sh ../utils/gen-dummy-certs.sh


##### 6. HTTP サーバを起動

    % cd ../..
    % sudo npm run http-server


##### 7. ユーザアカウントの作成

    % node local/utils/adduser.js -[rp] <account> <password>

-r は一般ユーザ、-p は特権ユーザを作成する。


##### 8. 完了

https://localhost にアクセスすれば、7. で作成したユーザでアクセスできる。


### 保守

##### 0. ユーザアカウント

local/utils/chuser.js で、ユーザアカウントを保守ができる。
「できる」とは言っても、

* アカウントの名称はそもそも変更できない
* 一般ユーザへ変更できる (-r)
* 特権ユーザへ変更できる (-p)
* ログイン対象外に (一時的に消去することが) できる (-k)
* ログイン対象に (復活させることが) できる (-a)

だけである。
本当に大したことはしていないので、スクリプトを直接見た方が理解が早いかも。
