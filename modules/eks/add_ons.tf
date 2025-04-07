# Create IAM role for EFS CSI Driver
resource "aws_iam_role" "efs_csi_driver" {
  name = "${aws_eks_cluster.eks.name}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.Account_ID}:oidc-provider/"${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa",
			"${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach required policy to the EFS CSI role
resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# EFS CSI Addon
resource "aws_eks_addon" "aws_efs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-efs-csi-driver"
  service_account_role_arn = aws_iam_role.efs_csi_driver.arn
}


# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${aws_eks_cluster.eks.name}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.Account_ID}:oidc-provider/"${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa",
			"${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach required policy to the EBS CSI role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# EBS CSI Addon
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
}



resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"
}
