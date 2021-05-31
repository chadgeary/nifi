resource "aws_service_discovery_private_dns_namespace" "zk-svcnamespace" {
  name        = "${var.name_prefix}_${random_string.tf-nifi-random.result}.internal"
  description = "Zookeeper Namespace"
  vpc         = aws_vpc.tf-nifi-vpc.id
}

resource "aws_service_discovery_service" "zk-svcdiscoveryA" {
  name = "zka"
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
  name = "zkb"
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
  name = "zkc"
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
