[
  {
    "name": "${name_prefix}-containerC-${aws_suffix}",
    "image": "${aws_repo_url}:latest",
    "cpu": ${service_cpu},
    "memory": ${service_memory},
    "essential": true,
    "environment": [
      {
        "ZOO_MY_ID": "3", "ZOO_SERVERS": "server.1=${lb_A}:2888:3888;${service_port} server.2=${lb_B}:2888,3888;${service_port} server.3=${lb_C}:2888,3888;${service_port}"
      }
    ], 
    "portMappings": [
      {
        "containerPort": 2181,
        "hostPort": ${service_port}
      },
      {
        "containerPort": 2888,
        "hostPort": 2888
      },
      {
        "containerPort": 3888,
        "hostPort": 3888
      }
    ]
  }
]
