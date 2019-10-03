# monitoring-ruby-app
Monitoring Rails app with the Elastic Stack.
Elastic Stackを利用して、Ruby on Railsのアプリで構成されるシステムを監視するデモの目的のために作成したリポジトリ。

[説明用スライドはこちら](https://noti.st/johtani/eJPLbZ/elastic)。

## Features

アプリケーション、システムの監視の目的のために、Elastic Stackの以下のプロダクトを使用しています。

* Heartbeat : 死活監視、外形監視を行うためのBeats。詳細は[こちら](https://www.elastic.co/products/beats/heartbeat)。
* Metricbeat : 各種メトリック（サーバーのメトリック）を収集するためのBeats。詳細は[こちら](https://www.elastic.co/products/beats/metricbeat)。
* Filebeat : ファイルのテイル、ログ収集のためのBeats.詳細は[こちら](https://www.elastic.co/products/beats/filebeat)。
* Packetbeat : ネットワークパケットからDNSのリクエストなどを収集するためのBeats。詳細は[こちら](https://www.elastic.co/products/beats/packetbeat)。
* Elastic APM : Elasticsearch,Kibanaを使用したアプリケーションパフォーマンスモニタリングのツール。今回はRubyエージェントを使用。詳細は[こちら](https://www.elastic.co/products/apm)。
* Elasticsearch : 上記BeatsおよびElastic APMが収集したデータを保存するサーバー。詳細は[こちら](https://www.elastic.co/products/elasticsearch)。
* Kibana : 上記収集したデータを元に、監視のためのデータを可視化するためのサーバー。詳細は[こちら](https://www.elastic.co/products/kibana)。

## System Architecture

デモアプリとして、質問投稿アプリをRuby on Railsで構築しました。
以下のような2台のサーバー構成です。

![シナリオイメージ](./ruby-app/public/scenario.png)

アプリケーションは以下の3つのソフトウェアで構成されます。

* NGINX : Webサーバー。クライアントとHTTPS通信を行う。Ruby on Railsへのロードバランス。
* Ruby on Rails : 質問投稿アプリ本体。簡単な投稿＋投票機能を実装。その他に、APM説明用のControllerあり。
* PostgreSQL : データ永続化層。投稿された質問と、投票データを保持。

NGINX+Ruby on Railsをフロントエンドサーバーに、PostgreSQLをバックエンドサーバーにデプロイします。
（ローカル環境では、NGINXはRailsとは別のVMとして切り出してあります）。

なお、Beats、APMのデータ保存先には[Elastic Cloud Elasticsearch Service](https://www.elastic.co/products/elasticsearch/service)を使用しています。
Elastic Cloudを利用することで、APM Serverより先の部分をElastic Cloudにまかせてしまうことができ、簡単に導入ができるという利点があります。

## Structure of repository

* gcp : GCPにデプロイするためのTerraform、Ansibleのファイルおよびデプロイ用の設定ファイル
* local : Docker on macOSで起動するためのdocker-compose.ymlおよび、各種設定ファイル
* nginx : localの環境で利用するためのNGINXのDockerfileと設定。
* ruby-app : Ruby on Railsのアプリ。

## Setup 

セッションで利用するデモ環境はGCP上に2つのGCEインスタンスを起動して、Beats、Elastic APM、アプリケーションをデプロイしています。

ローカルで動作させる方法としては、Dockerを利用できます。

### GCP

必要なツール : `gcloud`、`terraform`、`ansible`
必要なサービス : [Elastic Cloud Elasticsearch Service](https://www.elastic.co/products/elasticsearch/service)
必要な情報 : ドメイン（デモサイトをユーザーにも公開するため）


1. Elastic Cloudに`variables.yml`の`elastic_version`と同じバージョンのElasticsearchおよびKibanaを起動する。
2. 次の環境変数を設定する。(`gcp/setenv.sh.sample`にそれぞれ値を設定し、`source ./setenv.sh`を実行する。)
    * ELASTICSEARCH_CLOUD_ID - Cloud ID を設定（詳細は[ドキュメントを参照](https://www.elastic.co/guide/en/cloud/current/ec-cloud-id.html)）
    * ELASTICSEARCH_CLOUD_AUTH - Cloud Auth を設定（詳細は[ドキュメントを参照](https://www.elastic.co/guide/en/cloud/current/ec-cloud-id.html)）
    * ELASTIC_APM_SERVER_URL - Elastic Cloud 上のElastic APM ServerのURL（[詳細はこちら](https://www.elastic.co/guide/en/cloud/current/ec-create-deployment.html)）
    * ELASTIC_APM_SECRET_TOKEN - Elastic Cloud 上のElastic APM Serverの管理コンソール上にある`APM Server secret token`の文字列 
    * ELASTICSEARCH_USER - インデックスへの書き込み権限Kibanaの設定権限があるElasticsearchのユーザー
    * ELASTICSEARCH_PASSWORD - インデックスへの書き込み権限Kibanaの設定権限があるElasticsearchのユーザーのパスワード
    * ELASTICSEARCH_HOST - Elastic Cloud上のElasticsearchへのアクセスURL
3. 必要に応じて`valicables.tf`の設定（ドメインやインスタンスタイプなど）を変更
4. `gcp`ディレクトリに移動
5. `TF_VAR_project_id`を設定（GCPに関する設定）
6. `terraform init` で初期化（GCPに関するプラグインを入れる前）。その後`terraform plan`を実行して、設定ファイルの記述ミスなどがないかを確認。
7. `terraform apply`を実行して、インスタンスやDNSの設定をGCP上に反映（ここまでがGCP上の環境の設定）。
8. `ansible-playbook configure_all.yml`で2台のインスタンスにBeatsなどのセットアップ(ここからはAnsibleでアプリなどのデプロイ)
9. `ansible-playbook configure_backend.yml`でDBサーバー、Heartbeatをセットアップ
10. `ansible-playbook configure_frontend.yml`でNGINX、Railsをセットアップ

環境が必要なくなったら、`terraform destroy`を実行すればGCPのインスタンスやDNSの設定などが削除されます。

_※ TODO `google_dns_managed_zone`の設定でゾーンを指定する方法が不明のため、手動で、Google Domainsのネームサーバーの設定をTerraformでApplyした時に割り当てられたゾーンに合わせる必要がある_
_

### Local

TODO : まだ途中
GCP対応以前にローカルで動作確認のために利用してたましたが、

#### Start

1. Run Docker
2. Change directory into `local`
3. `docker-compose up -f docker-compose-elastic-cloud.yml` if using Elastic Cloud
3. `docker-compose up` if all system in local

#### Shutdown


# References 

* https://github.com/xeraa/microservice-monitoring

 