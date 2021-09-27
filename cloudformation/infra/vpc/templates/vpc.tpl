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
      RouteTableId: !Ref PublicSubnet1
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

{% if 'SecurityGroup' in data_2 %}
{% for i in range(data_2['SecurityGroup'] | length) %}
  {{ data_2['SecurityGroup'][i]['ResourceName'] }}:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: '{{ data_2['SecurityGroup'][i]['GroupDescription'] }}'
      GroupName: {{ data_2['SecurityGroup'][i]['GroupName'] }}
      SecurityGroupIngress:
{% for j in range(data_2['SecurityGroup'][i]['inbound'] | length) %}
{% if data_2['SecurityGroup'][i]['inbound'][j]['CidrIp'] != ''  %}
        - CidrIp: {{ data_2['SecurityGroup'][i]['inbound'][j]['CidrIp']}}
{% else %}
        - SourceSecurityGroupId: !Ref {{ data_2['SecurityGroup'][i]['inbound'][j]['SourceSecurityGroupId']}}
{% endif %}
          IpProtocol: {{ data_2['SecurityGroup'][i]['inbound'][j]['IpProtocol'] }}
          FromPort: {{ data_2['SecurityGroup'][i]['inbound'][j]['FromPort'] }}
          ToPort: {{ data_2['SecurityGroup'][i]['inbound'][j]['ToPort'] }}
{%endfor%}
      SecurityGroupEgress:
{% for k in range(data_2['SecurityGroup'][i]['outbound'] | length) %}
        - CidrIp: {{ data_2['SecurityGroup'][i]['outbound'][k]['CidrIp']}}
          IpProtocol: {{ data_2['SecurityGroup'][i]['outbound'][k]['IpProtocol'] }}
          FromPort: {{ data_2['SecurityGroup'][i]['outbound'][k]['FromPort'] }}
          ToPort: {{ data_2['SecurityGroup'][i]['outbound'][k]['ToPort'] }}
{%endfor%}
      VpcId: !Ref MyVpc
      Tags:
        - Key: Name
          Value: !Sub '${Identifier}-${Environment}-{{ data_2['SecurityGroup'][i]['ResourceName'] }}'
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
  PublicSubnet2:
    Description: Public Subnet 2 ID
    Value: !Ref MyPublicSubnet2
  PrivateSubnet2:
    Description: Private Subnet 2 ID
    Value: !Ref MyPrivateSubnet2
{% for i in range(data_2['SecurityGroup'] | length) %}
  {{ data_2['SecurityGroup'][i]['ResourceName'] }}:
    Description: '{{ data_2['SecurityGroup'][i]['GroupDescription'] }}'
    Value: !Ref {{ data_2['SecurityGroup'][i]['ResourceName'] }}
{%endfor%}
