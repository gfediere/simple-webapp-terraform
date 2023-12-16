output "instance_ips" {
    description = "Update Kubeconfig"
    value = "doormat aws export --role arn:aws:iam::952754899905:role/aws_guillaume.fediere_test-developer && aws eks --region ${var.region} update-kubeconfig --name EKS-Cluster-${var.region} --kubeconfig ~/.kube/config-${var.region} && export KUBECONFIG=\"$HOME/.kube/config-${var.region}\" "
}

output mongoDBIP {
    value = aws_instance.mongoDB.private_ip
}