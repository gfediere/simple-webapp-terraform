resource "aws_security_group" "mongoDB" {
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }
    ingress {
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        cidr_blocks = [var.myIP]
        #cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }    
    ingress {
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }    
    ingress {
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

resource "aws_key_pair" "guigui" {
  key_name   = "guigui_pub"
  public_key = file("~/.ssh/guigui.pub")
}

resource "aws_network_interface" "mongoDB" {
    subnet_id   = "${element(module.vpc.public_subnets, 0)}"
    private_ips     = ["10.0.48.159"]
    tags = local.tags
    security_groups = [aws_security_group.mongoDB.id]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
      }
      actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = ["ec2:*"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.tierplatform.bucket}/",
      "arn:aws:s3:::${aws_s3_bucket.tierplatform.bucket}/*"
    ]
  }
}

resource "aws_iam_role" "role" {
  name               = "mongoDB_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "policy" {
  name        = "MongoDB-policy"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_policy_attachment" "mongodb-attach" {
  name       = "mongodb-attach"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "mongoDB_profile" {
  name = "mongoDB_profile"
  role = aws_iam_role.role.name
}

resource "aws_instance" "mongoDB" {
    ami           = var.ami
    instance_type = "t2.micro"
    key_name = aws_key_pair.guigui.key_name
    iam_instance_profile = aws_iam_instance_profile.mongoDB_profile.id
    
    subnet_id = "${element(module.vpc.public_subnets, 0)}"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.mongoDB.id]
    
    #network_interface {
    #    network_interface_id = aws_network_interface.mongoDB.id
    #    device_index         = 0
    #}

  user_data = <<EOF
#!/bin/bash
echo "[mongodb]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-4.4.asc" | sudo tee /etc/yum.repos.d/mongodb.repo

sudo yum update
sudo yum install -y mongodb-org mongodb-org-server
sudo sed -i s/127.0.0.1/0.0.0.0/g /etc/mongod.conf
sudo /etc/init.d/mongod start

mongo webapp --eval 'db.createUser({user: "webapp",pwd: "${var.DBPassword}",roles: [ { role: "readWrite", db: "webapp" } ]})'

EOF
    tags = merge(
        var.projectTags,
        {
            Name = "mongoDB"
        },
    )
}