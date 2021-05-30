resource "aws_service_discovery_private_dns_namespace" "zk-svcnamespace" {
  name               = "${var.name_prefix}_${random_string.tf-nifi-random.result}.internal"
  description        = "Zookeeper Namespace"
  vpc                = aws_vpc.tf-nifi-vpc.id
}

resource "aws_service_discovery_service" "zk-svcdiscoveryA" {
  name = "${var.name_prefix}-zk-svcdiscoveryA-${random_string.tf-nifi-random.result}.internal"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.zk-svcnamespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "zk-svcdiscoveryB" {
  name = "${var.name_prefix}-zk-svcdiscoveryB-${random_string.tf-nifi-random.result}.internal"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.zk-svcnamespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "zk-svcdiscoveryC" {
  name = "${var.name_prefix}-zk-svcdiscoveryC-${random_string.tf-nifi-random.result}.internal"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.zk-svcnamespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
