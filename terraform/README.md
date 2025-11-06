# Terraform Infrastructure as Code

このリポジトリは、AWSインフラストラクチャをTerraformで管理します。

## ディレクトリ構成

```
terraform/
├── envs/                    # 環境ごとの設定
│   ├── dev/                 # 開発環境
│   │   ├── main.tf          # メインリソース定義
│   │   ├── variables.tf    # 変数定義
│   │   ├── outputs.tf      # 出力定義
│   │   ├── versions.tf      # Terraform/プロバイダーバージョン
│   │   ├── backend.tf      # バックエンド設定
│   │   ├── provider.tf     # プロバイダー設定
│   │   └── terraform.tfvars.example  # 変数サンプル
│   └── stg/                 # ステージング環境
│       └── ...
├── modules/                 # 再利用可能なモジュール
│   ├── iam/                 # IAMモジュール
│   │   ├── role.tf         # IAMロール定義
│   │   ├── variables.tf    # 変数定義
│   │   └── outputs.tf     # 出力定義
│   └── vpc/                 # VPCモジュール
│       ├── main.tf          # VPCリソース定義
│       ├── variables.tf    # 変数定義
│       └── outputs.tf      # 出力定義
└── .gitignore              # Git除外設定
```

## セットアップ

### 1. 必要な環境

- Terraform >= 0.13
- AWS CLI設定済み
- 適切なAWS認証情報

### 2. 環境ごとの設定

各環境ディレクトリ（`envs/dev/` など）で：

```bash
# 変数ファイルのコピー
cp terraform.tfvars.example terraform.tfvars

# terraform.tfvarsを編集して値を設定
# 注意: terraform.tfvarsは.gitignoreに含まれています

# 初期化
terraform init

# 実行計画の確認
terraform plan

# 適用
terraform apply
```

### 3. 変数ファイルの使い方

#### 自動読み込み

`terraform.tfvars`という名前のファイルは、Terraformが自動的に読み込みます：

```bash
# terraform.tfvarsが自動的に読み込まれる
terraform plan
terraform apply
```

#### 明示的な指定（-var-fileオプション）

特定のファイル名を使う場合、または複数のファイルを指定する場合：

```bash
# 特定のファイルを指定
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# 複数のファイルを指定（後から指定したものが優先）
terraform plan \
  -var-file="common.tfvars" \
  -var-file="dev.tfvars" \
  -var-file="dev-override.tfvars"

# コマンドライン引数で一時的に値を上書き
terraform plan \
  -var-file="terraform.tfvars" \
  -var="mgmt_account_id=123456789012"
```

#### ファイル名の優先順位

Terraformは以下の順で自動的にtfvarsファイルを探します：

1. `terraform.tfvars`（自動読み込み）
2. `terraform.tfvars.json`（自動読み込み）
3. `*.auto.tfvars`（自動読み込み、アルファベット順）
4. `-var-file`で明示的に指定したファイル

#### 実用例

環境ごとに異なるファイル名を使う場合：

```bash
# dev環境
cd envs/dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# stg環境
cd envs/stg
terraform plan -var-file="stg.tfvars"
terraform apply -var-file="stg.tfvars"
```

## モジュール

以下のモジュールが利用可能です：

### IAM Module

IAMユーザーとロールを管理します。

**変数:**
- `environment`: 環境名（dev, stg, prod）
- `mgmt_account_id`: 管理アカウントID

**出力:**
- `infra_user_name`: infraユーザー名
- `readonly_user_name`: readonlyユーザー名
- `infra_admin_role_arn`: infra adminロールARN
- `readonly_role_arn`: readonlyロールARN

### VPC Module

VPCとサブネットを管理します。

**変数:**
- `environment`: 環境名
- `cidr_block`: VPC CIDRブロック
- `public_subnets`: パブリックサブネットCIDRリスト
- `private_subnets`: プライベートサブネットCIDRリスト
- `azs`: アベイラビリティゾーンリスト

**出力:**
- `vpc_id`: VPC ID
- `vpc_cidr_block`: VPC CIDRブロック
- `public_subnet_ids`: パブリックサブネットIDリスト
- `private_subnet_ids`: プライベートサブネットIDリスト

## ベストプラクティス

- ✅ 環境ごとにディレクトリを分離
- ✅ モジュール化による再利用性
- ✅ 変数ファイルの分離（variables.tf）
- ✅ 出力定義の分離（outputs.tf）
- ✅ バージョン管理の分離（versions.tf）
- ✅ バックエンド設定の分離（backend.tf）
- ✅ 機密情報はterraform.tfvarsで管理（gitignore）

## 注意事項

- `terraform.tfvars`はGitにコミットしないでください
- バックエンド設定（S3バケット）は事前に作成しておく必要があります
- IAMリソースは環境ごとに名前が重複しないように環境名が付与されます

