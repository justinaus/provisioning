resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "test-subnet-public"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "test-subnet-private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test-igw"
  }
}

resource "aws_eip" "nat" {
  # vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id

  # nat gateway는 퍼블릭 서브넷에 위치.
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "test-natgw"
  }
}

resource "aws_route_table" "public22" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  

  tags = {
    Name = "test-rt-public22"
  }
}

resource "aws_route_table_association" "route_table_association_public" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public22.id
}

resource "aws_route_table" "private22" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test-rt-private22"
  }
}

resource "aws_route_table_association" "route_table_association_private" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private22.id
}

resource "aws_route" "private_nat" {
  route_table_id = aws_route_table.private22.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}