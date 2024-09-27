# bc-ruby

**bc-ruby** は、Ruby でブロックチェーンとビットコインの仕組みを学ぶために作成されたシンプルなプロジェクトです。基本的なトランザクションの追加やブロックのマイニング、残高の確認を通して、ブロックチェーンの動作を理解することができます。

## 特徴

- トランザクションの作成と追加
- マイニングによるブロックの生成
- 各アカウントの残高確認
- ブロックチェーンの有効性検証

## 必要条件

- Ruby 2.7 以上
- Bundler

## インストールと実行

1. リポジトリをクローンします。

    ```bash
    git clone https://github.com/yourusername/bc-ruby.git
    cd bc-ruby
    ```

2. 依存関係をインストールします。

    ```bash
    bundle install
    ```

3. サンプルを実行して、ブロックチェーンの動作を確認します。

    ```bash
    ruby bin/main.rb
    ```

## テスト

RSpec でテストを実行します。

```bash
bundle exec rspec
```