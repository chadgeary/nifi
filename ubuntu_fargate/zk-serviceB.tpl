[
  {
    "name": "${name_prefix}-zk2-${aws_suffix}",
    "image": "${aws_repo_url}:latest",
    "essential": true,
    "environment": [
      {"name": "ZOO_MY_ID", "value": "2"},
      {"name": "ZOO_SERVERS", "value": "server.1=zka.${name_prefix}_${aws_suffix}.internal:2888:3888:participant;zka.${name_prefix}_${aws_suffix}.internal:2181 server.2=0.0.0.0:2888:3888:participant;0.0.0.0:2181 server.3=zkc.${name_prefix}_${aws_suffix}.internal:2888:3888:participant;zkc.${name_prefix}_${aws_suffix}.internal:2181"},
      {"name": "ZOO_4LW_COMMANDS_WHITELIST", "value": "*"}
    ], 
    "portMappings": [
      {
        "containerPort": 2181,
        "hostPort": 2181
      },
      {
        "containerPort": 2888,
        "hostPort": 2888
      },
      {
        "containerPort": 3888,
        "hostPort": 3888
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/aws/ecs/${name_prefix}_${aws_suffix}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "zk2"
      }
    }
  }
]
