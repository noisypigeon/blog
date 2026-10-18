locals {
  # Exactly the R2 state bucket's name plus -backup (LIB-0016 §1).
  exact_name  = "${var.state_bucket_name}-backup"
  description = "Versioned offsite copy of noisypigeon/blog's R2 Terraform state (LIB-0007)."
}
