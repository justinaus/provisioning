terraform {
    backend "s3" { # 강의는 
      bucket         = "justinaus2-apne2-tfstate" # s3 bucket 이름
      key            = "terraform/s3/terraform.tfstate" # s3 내에서 저장되는 경로를 의미합니다.
      region         = "ap-northeast-2"  
      encrypt        = true
      dynamodb_table = "terraform-lock"
    }
}