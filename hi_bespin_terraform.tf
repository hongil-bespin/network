terraform {
  cloud {
    organization = "example-org-fd00ea"

    workspaces {
      name = "network"
    }
  }
}

# AWS 서울 리전 설정
provider "aws" {
  region = "ap-northeast-2" # 서울 리전 코드
  profile = "hi_bespin_terraform"
}

# VPC 생성
resource "aws_vpc" "hi_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true # DNS 호스트 이름 활성화
  tags = {
    Name = "hi_vpc"
  }
}

# 가용 영역 생성 (AZ A & AZ C)
resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true # 서브넷에 생성된 인스턴스에 퍼블릭 IP 주소 할당
  tags = {
    Name = "public_subnet_a"
  }
}

resource "aws_subnet" "web_subnet_a" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "web_subnet_a"
  }
}

resource "aws_subnet" "WAS_subnet_a" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "WAS_subnet_a"
  }
}

resource "aws_subnet" "DB_subnet_a" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "DB_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_c" {
    vpc_id     = aws_vpc.hi_vpc.id
    cidr_block = "10.0.5.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true # 서브넷에 생성된 인스턴스에 퍼블릭 IP 주소 할당
    tags = {
      Name = "public_subnet_c"
    }
  }

resource "aws_subnet" "web_subnet_c" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "web_subnet_c"
  }
}

resource "aws_subnet" "WAS_subnet_c" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "WAS_subnet_c"
  }
}

resource "aws_subnet" "DB_subnet_c" {
  vpc_id     = aws_vpc.hi_vpc.id
  cidr_block = "10.0.8.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "DB_subnet_c"
  }
}

# Internet GW 생성
resource "aws_internet_gateway" "hi_igw" {
  vpc_id = aws_vpc.hi_vpc.id
  tags = {
    Name = "hi_igw"
  }
}

# Elastic IP 생성
resource "aws_eip" "nat_eip_a" {
}

resource "aws_eip" "nat_eip_c" {
}

# NAT GW 생성 (AZ A & AZ C)
resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "nat_gateway_a"
  }
}

resource "aws_nat_gateway" "nat_gateway_c" {
  allocation_id = aws_eip.nat_eip_c.id
  subnet_id     = aws_subnet.public_subnet_c.id
  tags = {
    Name = "nat_gateway_c"
  }
}

# Route Table 생성
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.hi_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hi_igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_route_table_a" {
  vpc_id = aws_vpc.hi_vpc.id
}

resource "aws_route_table" "private_route_table_c" {
  vpc_id = aws_vpc.hi_vpc.id
}

# Route Table 연동
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "web_subnet_association_a" {
  subnet_id      = aws_subnet.web_subnet_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table_association" "WAS_subnet_association_a" {
  subnet_id      = aws_subnet.WAS_subnet_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table_association" "DB_subnet_association_a" {
  subnet_id      = aws_subnet.DB_subnet_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table_association" "web_subnet_association_c" {
  subnet_id      = aws_subnet.web_subnet_c.id
  route_table_id = aws_route_table.private_route_table_c.id
}

resource "aws_route_table_association" "WAS_subnet_association_c" {
  subnet_id      = aws_subnet.WAS_subnet_c.id
  route_table_id = aws_route_table.private_route_table_c.id
}

resource "aws_route_table_association" "DB_subnet_association_c" {
  subnet_id      = aws_subnet.DB_subnet_c.id
  route_table_id = aws_route_table.private_route_table_c.id
}
