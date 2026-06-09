variable "region" {
  description = "AWS region for the guestbook Lambda."
  type        = string
  default     = "us-east-1"
}

variable "participant" {
  description = "Unique per-fork identifier; part of the Lambda function name so attendees don't collide."
  type        = string
}

variable "env_name" {
  description = "Environment name baked into the function name + reported by the Lambda (e.g. dev, prod)."
  type        = string
}

variable "image_tag" {
  description = "Frontend image tag being promoted; surfaced as the Lambda VERSION env var."
  type        = string
  default     = "dev"
}

variable "function_prefix" {
  description = "Lambda function name prefix. MUST match the name pattern your AWS user is allowed to create."
  type        = string
  default     = "kargo-guestbook"
}

variable "execution_role_arn" {
  description = "ARN of the shared, pre-created Lambda execution role (created once by an admin). The workshop creds only need iam:PassRole on this role."
  type        = string
  default     = "arn:aws:iam::218691292270:role/lambda-execution-role"
}
