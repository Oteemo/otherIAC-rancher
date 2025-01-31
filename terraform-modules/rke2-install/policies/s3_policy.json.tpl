{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket}/*",
        "arn:aws:s3:::${aws_s3_bucket}",
        "arn:aws:s3:::lts-rancher-backup-${environment}/*",
        "arn:aws:s3:::lts-rancher-backup-${environment}"
      ]
    }
  ]
}
