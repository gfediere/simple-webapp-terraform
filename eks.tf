locals {
  name = "EKS-Cluster-${var.region}"
  tags = {
    Project  = "3TierApp"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.19 "

  cluster_name                   = local.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    workload-m5 = {
      instance_types = ["m5.large"]
      min_size     = 1
      max_size     = 5
      desired_size = 1
      source_security_group_ids = module.eks.cluster_security_group_id
    }
  }

}