import {
  id = "dev-readonly-user"
  to = module.iam.module.iam_roles.aws_iam_user.readonly_user
}

import {
  id = "dev-infra-user"
  to = module.iam.module.iam_roles.aws_iam_user.infra_user
}

import {
  id = "dev-infra-admin-role"
  to = module.iam.module.iam_roles.aws_iam_role.infra_admin_role
}

import {
  id = "dev-readonly-role"
  to = module.iam.module.iam_roles.aws_iam_role.readonly_role
}