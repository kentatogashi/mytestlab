#
# ============================================================
#  IAM ROLES (infra-admin-role / readonly-role)
#  - dev / stg / prod 各アカウントに共通で配置できる
#  - MGMT_ACCOUNT_ID は変数化して管理者アカウントを外出し
# ============================================================
#


locals {
}

# ------------------------------------------------------------
# IAM Users（管理アカウント内）
# ------------------------------------------------------------
resource "aws_iam_user" "infra_user" {
  name = "${var.environment}-infra-user"
  path = "/"

  tags = {
    Name = "${var.environment}-infra-user"
  }
}

resource "aws_iam_user" "readonly_user" {
  name = "${var.environment}-readonly-user"
  path = "/"

  tags = {
    Name = "${var.environment}-readonly-user"
  }
}

# ------------------------------------------------------------
# 1. infra-admin-role（管理者）
# ------------------------------------------------------------
data "aws_iam_policy_document" "infra_admin_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.mgmt_account_id}:user/${var.environment}-infra-user"
      ]
    }
  }
}

resource "aws_iam_role" "infra_admin_role" {
  name               = "${var.environment}-infra-admin-role"
  assume_role_policy = data.aws_iam_policy_document.infra_admin_trust.json
}

resource "aws_iam_role_policy_attachment" "infra_admin_attach" {
  role       = aws_iam_role.infra_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ------------------------------------------------------------
# 2. readonly-role（閲覧専用）
# ------------------------------------------------------------
data "aws_iam_policy_document" "readonly_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.mgmt_account_id}:user/${var.environment}-readonly-user",
      ]
    }
  }
}

resource "aws_iam_role" "readonly_role" {
  name               = "${var.environment}-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.readonly_trust.json
}

resource "aws_iam_role_policy_attachment" "readonly_attach" {
  role       = aws_iam_role.readonly_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ------------------------------------------------------------
# Note: terraform-exec-role は Terraform の管理対象外です
# Terraform実行用のロール、ポリシー、ユーザーは手動または
# 別の管理方法で作成・管理してください
# ------------------------------------------------------------

