variable "region" {
  description = "AWS Region used"
}

variable "s3BucketName" {
  description = "S3 bucket name used for backups" 
}

variable "cluster_version" {
  description = "EKS Cluster version"
  default = "1.28"
}

variable "ami" {
  description= "AMI Used"
}

variable vpc_name {
  default = "3tierApp"
}

variable vpc_cidr {
  default = "10.0.0.0/16"
}

variable "projectTags" {
  default     = { Project  = "3TierApp" }
  type        = map(string)
}

variable "DBPassword" {
  description = "Password setup for MongoDB"
}

variable "myIP" {
  description = "IP used for SSH access"
}