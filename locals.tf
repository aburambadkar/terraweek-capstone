locals {
  # The active workspace name — used for resource Name tags and the Environment
  # default_tag in provider.tf. This is also what the guardrail below checks against.
  env = terraform.workspace

  # ---- Workspace / tfvars guardrail --------------------------------
  # If you accidentally pass the wrong tfvars file (e.g. staging.tfvars
  # while on the dev workspace), Terraform will abort here with a clear
  # error rather than silently modifying the wrong environment's infrastructure.
  #
  # tobool() on a non-boolean string always fails — we exploit that to
  # surface a readable message at plan time.
  _validate_environment = (
    var.environment == local.env
    ? true
    : tobool(
        "WORKSPACE MISMATCH: var.environment is \"${var.environment}\" but the active workspace is \"${local.env}\". Run: terraform workspace select ${var.environment}"
      )
  )
}
