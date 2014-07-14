# Testing of Attributes
## 概要
`key=value`の形式の設定ファイルを生成するために，attributeとtemplateで実装したいが，暗号化が必要な場合にはEncrypted Data Bagを利用する必要があり，recipeから読み込む必要がある．
recipe内でEncrypted Data Bagを読み込み，attributeとmergeしてtemplateに渡すテスト．

:warning: Encrypted Data Bagは使用していません．
## 作成
### ベースレシピ
```ruby:site-cookbooks/config-test/recipes/conf.rb
template '/tmp/common.config' do
        source 'common.config.erb'
end
```
### 共通設定
```ruby:site-cookbooks/config-test/attributes/config.rb
default[:config] = {
        key1: 'value1',
        key2: 'value2'
}
```
### 設定ファイル template
```ruby:site-cookbooks/config-test/templates/default/common.config.erb
<%= node[:config].map {|k,v| "#{k}=#{v}"}.join("\n") %>
```
### app1固有設定
```ruby:site-cookbooks/config-test/recipes/app1.rb

node.default[:config].merge!({
        app1_password: 'password4app1'
})

include_recipe 'config-test::conf'
```
### app2固有設定
```ruby:site-cookbooks/config-test/recipes/app2.rb

node.default[:config].merge!({
        app2_password: 'P@ssw0rd'
})

include_recipe 'config-test::conf'
```
## 実行
test-kitchenで確認する
### test-kitchen設定
```yaml:.kitchen.yml
---
driver:
  name: vagrant

provisioner:
  name: chef_solo

platforms:
  - name: centos-6.4

suites:
  - name: app1
    run_list: recipe[config-test::app1]
    attributes:
  - name: app2
    run_list: recipe[config-test::app2]
    attributes:
  - name: both
    run_list:
      - recipe[config-test::app1]
      - recipe[config-test::app2]
    attributes:
```
### test-kitchen実行
```sh
bundle exec kitchen test --destroy=never --parallel
```
## 確認
### app1
```
bundle exec kitchen login app1-centos-64
[vagrant@app1-centos-64 ~]$ cat /tmp/common.config
key1=value1
key2=value2
app1_password=password4app1
[vagrant@app1-centos-64 ~]$ exit
```
### app2
```
bundle exec kitchen login app2-centos-64
[vagrant@app2-centos-64 ~]$ cat /tmp/common.config
key1=value1
key2=value2
app2_password=P@ssw0rd
[vagrant@app1-centos-64 ~]$ exit
```
### both
```
bundle exec kitchen login both-centos-64
[vagrant@both-centos-64 ~]$ cat /tmp/common.config
key1=value1
key2=value2
app1_password=password4app1
app2_password=P@ssw0rd
[vagrant@both-centos-64 ~]$ exit
```
## 結果
期待通りに動作している
