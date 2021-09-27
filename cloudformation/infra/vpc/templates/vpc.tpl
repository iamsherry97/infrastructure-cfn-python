AWSTemplateFormatVersion: 2010-09-09
Description: |
  "Template for the creation of new vpc,subnets,igw,nat,route table, routes etc"
Parameters:
  Environment:
    Type: String
  Identifier:
    Type: String
  VpcCidrBlock:
    Description: Cidr Block Range for VPC
    Type: String
    Default: 10.0.0.0/16
  CidrBlockForPubS1:
    Description: Cidr Block Range for Public Subnet 1
    Type: String
    Default: 10.0.1.0/24
  CidrBlockForPubS2:
    Description: Cidr Block Range for Public Subnet 2
    Type: String
    Default: 10.0.2.0/24
  CidrBlockForPriS1:
    Description: Cidr Block Range for Private Subnet 1
    Type: String
    Default: 10.0.3.0/24
  CidrBlockForPriS2:
    Description: Cidr Block Range for Private Subnet 2
    Type: String
    Default: 10.0.4.0/24
Resources:
  MyVpc:
    Type: 'AWS::EC2::VPC'
    Properties:
      CidrBlock: !Ref VpcCidrBlock
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-VPC'
{% if 'Subnets' in subnet_data %}
{% for i in range(subnet_data['Subnets'] | length) %}
  {{ subnet_data['Subnets'][i]['ResourceName'] }}:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref MyVpc
      MapPublicIpOnLaunch: {{subnet_data['Subnets'][i]['MapPublicIpOnLaunch']}}
      CidrBlock: !Ref {{subnet_data['Subnets'][i]['CidrBlock']}}
      AvailabilityZone: {{subnet_data['Subnets'][i]['AvailabilityZone']}}
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-{{ subnet_data['Subnets'][i]['ResourceName'] }}'

{% endfor %}

{%endif%}

  MyIGW:
    Type: 'AWS::EC2::InternetGateway'
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}'
  MyVpcIGWAttachment:
    Type: 'AWS::EC2::VPCGatewayAttachment'
    Properties:
      InternetGatewayId: !Ref MyIGW
      VpcId: !Ref MyVpc
  MyNATEIP:
    Type: 'AWS::EC2::EIP'
    Properties:
      Domain: vpc
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-NATIp'
  MyNatGat:
    Type: 'AWS::EC2::NatGateway'
    Properties:
      SubnetId: !Ref PublicSubnet1
      AllocationId: !GetAtt MyNATEIP.AllocationId
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-NatGateway'
  MyPublicRouteTable:
    Type: 'AWS::EC2::RouteTable'
    Properties:
      VpcId: !Ref MyVpc
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-PublicRouteTable'
  MyPrivateRouteTable:
    Type: 'AWS::EC2::RouteTable'
    Properties:
      VpcId: !Ref MyVpc
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-PrivateRouteTable'
  WWWRouteToIGW:
    Type: 'AWS::EC2::Route'
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref MyIGW
      RouteTableId: !Ref MyPublicRouteTable
  PriSubnetToNat:
    Type: 'AWS::EC2::Route'
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref MyNatGat
      RouteTableId: !Ref MyPrivateRouteTable

{% if 'Subnets' in subnet_data %}
{% for i in range(subnet_data['Subnets'] | length) %}
  {{ subnet_data['Subnets'][i]['ResourceName']}}Asso:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
{% if subnet_data['Subnets'][i]['RouteAssociation'] == "Public" %}
      RouteTableId: !Ref MyPublicRouteTable
{% else %}
      RouteTableId: !Ref MyPrivateRouteTable
{% endif %}
      SubnetId: !Ref {{ subnet_data['Subnets'][i]['ResourceName'] }}

{% endfor %}

{% endif %}

{% if 'SecurityGroup' in sg_data %}
{% for i in range(sg_data['SecurityGroup'] | length) %}
  {{ sg_data['SecurityGroup'][i]['ResourceName'] }}:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: '{{ sg_data['SecurityGroup'][i]['GroupDescription'] }}'
      GroupName: {{ sg_data['SecurityGroup'][i]['GroupName'] }}
      SecurityGroupIngress:
{% for j in range(sg_data['SecurityGroup'][i]['inbound'] | length) %}
{% if sg_data['SecurityGroup'][i]['inbound'][j]['CidrIp'] != ''  %}
        - CidrIp: {{ sg_data['SecurityGroup'][i]['inbound'][j]['CidrIp']}}
{% else %}
        - SourceSecurityGroupId: !Ref {{ sg_data['SecurityGroup'][i]['inbound'][j]['SourceSecurityGroupId']}}
{% endif %}
          IpProtocol: {{ sg_data['SecurityGroup'][i]['inbound'][j]['IpProtocol'] }}
          FromPort: {{ sg_data['SecurityGroup'][i]['inbound'][j]['FromPort'] }}
          ToPort: {{ sg_data['SecurityGroup'][i]['inbound'][j]['ToPort'] }}
{%endfor%}
      SecurityGroupEgress:
{% for k in range(sg_data['SecurityGroup'][i]['outbound'] | length) %}
        - CidrIp: {{ sg_data['SecurityGroup'][i]['outbound'][k]['CidrIp']}}
          IpProtocol: {{ sg_data['SecurityGroup'][i]['outbound'][k]['IpProtocol'] }}
          FromPort: {{ sg_data['SecurityGroup'][i]['outbound'][k]['FromPort'] }}
          ToPort: {{ sg_data['SecurityGroup'][i]['outbound'][k]['ToPort'] }}
{%endfor%}
      VpcId: !Ref MyVpc
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-{{ sg_data['SecurityGroup'][i]['ResourceName'] }}'
{%endfor%}
{%endif %}
          
Outputs:
  VPC:
    Description: VPC ID
    Value: !Ref MyVpc
{% for i in range(subnet_data['Subnets'] | length) %}
  {{ subnet_data['Subnets'][i]['ResourceName'] }}:
    Value: !Ref {{ subnet_data['Subnets'][i]['ResourceName'] }}
{%endfor%}
{% for i in range(sg_data['SecurityGroup'] | length) %}
  {{ sg_data['SecurityGroup'][i]['ResourceName'] }}:
    Description: '{{ sg_data['SecurityGroup'][i]['GroupDescription'] }}'
    Value: !Ref {{ sg_data['SecurityGroup'][i]['ResourceName'] }}
{%endfor%}
