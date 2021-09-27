AWSTemplateFormatVersion: "2010-09-09"

Parameters:
  Environment:
    Type: String
  Identifier:
    Type: String
  ServiceName:
    Type: String
  ContainerPort:
    Type: String
  ImageURI:
    Type: String
  Tag:
    Type: String
    Default: latest
  CPUUnits:
    Type: String
    Default: 1024
  MemoryUnits:
    Type: String
    Default: 2048
  TaskRoleARN:
    Type: String

  FirelensConfigurationType:
    Type: String
    Default: fluentbit
  DataDogAgentImage:
    Type: String
    Default: "gcr.io/datadoghq/agent:7"
  DataDogAgentContainerPort:
    Type: String
    Default: 8126
  FluentbitImageUri:
    Type: String
    Default: "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest"
  DataDogApiKey:
    Type: String


Outputs:
  TaskDefinition:
    Value: !Ref TaskDefinition

Resources:
  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub ${Identifier}-${Environment}
      TaskRoleArn: !Ref TaskRoleARN
      ExecutionRoleArn: !Ref TaskRoleARN
      Cpu: !Ref CPUUnits
      Memory: !Ref MemoryUnits
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      ContainerDefinitions:
        - Name: DataDogAgent
          PortMappings:
            - ContainerPort: !Ref DataDogAgentContainerPort # 8126
          Essential: true
          Image: !Ref DataDogAgentImage #  gcr.io/datadoghq/agent:7
          Environment:
            - Name: DD_APM_ENABLED
              Value: true
            - Name: DD_SERVICE # Defined for DataDog Service Name
              Value: !Sub "${Identifier}-${Environment}"
            - Name: DD_ENV 
              Value: !Sub "${Identifier}-${Environment}"
            - Name: ECS_FARGATE
              Value: true
            - Name: DD_API_KEY
              Value: !Ref DataDogApiKey 
            - Name: DD_APM_NON_LOCAL_TRAFFIC
              Value: true
            - Name: DD_LOGS_INJECTION
              Value: true
            - Name: DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL
              Value: true
            - Name: DD_DOGSTATSD_NON_LOCAL_TRAFFIC
              Value: true
              


          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-create-group: true
              awslogs-group: !Sub "${Identifier}-${Environment}-datadog"
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: !Sub "${Identifier}-${Environment}-datadog"


        - Name: !Ref ServiceName
          PortMappings:
            - ContainerPort: !Ref ContainerPort
          Image: !Sub ${ImageURI}:${Tag}
          DependsOn: ###
            - ContainerName: DataDogAgent
              Condition: START
          Command:
            - /bin/bash
            - -c
            - cd /akita/src && touch /.dockerenv && /usr/bin/just serve_prod
          User: root

{% if 'task_definition_secret' in data %}
          Secrets:
{% for key, value in data["task_definition_secret"].items() %} 

            - Name: {{ key }}
              ValueFrom: {{ value | replace("ARN|", "") }}

{%- endfor %}
{%endif %}


          Environment:
            - Name: DD_SERVICE # Defined for DataDog Service Name
              Value: !Sub "${Identifier}-${Environment}"
            - Name: DD_ENV 
              Value: !Sub "${Identifier}-${Environment}"
            - Name: DD_LOGS_INJECTION
              Value: true


{% if 'task_definition_environment' in data %}
{% for key, value in data["task_definition_environment"].items() %}
            
            - Name: {{ key }}
              Value: {{ value }}

{%- endfor %}
{%endif %}


          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Sub "${Identifier}-${Environment}"
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: !Sub "${Identifier}-${Environment}"