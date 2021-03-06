AWSTemplateFormatVersion: '2010-09-09'
Description: Template for the Creation of RDS based on Engine Choice
Metadata:
  'AWS::CloudFormation::Interface':
    ParameterGroups:
    - Label:
        default: 'RDS Parameters'
      Parameters:
      - DBSnapshotIdentifier
      - EngineVersion
      - DBAllocatedStorage
      - DBInstanceClass
      - DBName
      - DBBackupRetentionPeriod
      - DBMasterUsername
      - DBMasterUserPassword
      - DBMultiAZ
      - PreferredBackupWindow
      - PreferredMaintenanceWindow
      - EnableIAMDatabaseAuthentication

                      # Parameters CFN #
Parameters:
  Environment:
    Type: String
  Identifier:
    Type: String
  DBSnapshotName:
    Description: 'Optional name or Amazon Resource Name (ARN) of the DB snapshot from which you want to restore (leave blank to create an empty database).'
    Type: String
    Default: ''
  DBAllocatedStorage:
    Description: 'The allocated storage size, specified in GB (ignored when DBSnapshotIdentifier is set, value used from snapshot).'
    Type: Number
    Default: 5
    MinValue: 5
    MaxValue: 16384
  DBInstanceClass:
    Description: 'The instance type of database server.'
    Type: String
    Default: 'db.t2.micro'
    AllowedValues: [db.t2.micro, db.t3.medium, db.m1.small, db.m1.medium, db.m1.large, db.m1.xlarge,
      db.m2.xlarge, db.m2.2xlarge, db.m2.4xlarge, db.m3.medium, db.m3.large, db.m3.xlarge,
      db.m3.2xlarge, db.m4.large, db.m4.xlarge, db.m4.2xlarge, db.m4.4xlarge, db.m4.10xlarge,
      db.r3.large, db.r3.xlarge, db.r3.2xlarge, db.r3.4xlarge, db.r3.8xlarge, db.m2.xlarge,
      db.m2.2xlarge, db.m2.4xlarge, db.cr1.8xlarge, db.t2.micro, db.t2.small, db.t2.medium,
      db.t2.large]    
  DBName:
    Description: The database name
    Type: String
  DBBackupRetentionPeriod:
    Description: 'The number of days to keep snapshots of the database.'
    Type: Number
    MinValue: 0
    MaxValue: 35
    Default: 0
  DBMasterUsername:
    Description: The database admin account username
    Type: String
    Default: master
  DBMasterUserPassword:
    Default: root1234
    NoEcho: 'true'
    Description: The database admin account password
    Type: String
    MinLength: '8'
  DBMultiAZ:
    Description: 'Specifies if the database instance is deployed to multiple Availability Zones for HA.'
    Type: String
    Default: false
    AllowedValues: [true, false]
  DeleteAutomatedBackups:
    Description: 'Specifies if the database backup should be deleted.'
    Type: String
    Default: false
    AllowedValues: [true, false]    
  DeletionProtection:
    Description: 'Specifies if the database should be deleted.'
    Type: String
    Default: false
    AllowedValues: [true, false]  
  EnablePerformanceInsights:
    Description: 'Specifies if the Performance Insights should be enabled?'
    Type: String
    Default: false
    AllowedValues: [true, false]     
  PreferredBackupWindow:
    Description: 'The daily time range in UTC during which you want to create automated backups.'
    Type: String
    Default: '09:54-10:24'
  PreferredMaintenanceWindow:
    Description: The weekly time range (in UTC) during which system maintenance can occur.
    Type: String
    Default: 'sat:07:00-sat:07:30'
  PubliclyAccessible:
    Description: 'Specifies if the DB Public Access should be enabled?'
    Type: String
    Default: false
    AllowedValues: [true, false]  
  EnableIAMDatabaseAuthentication:
    Description: 'Enable mapping of AWS Identity and Access Management (IAM) accounts to database accounts (https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.html).'
    Type: String
    AllowedValues: ['true', 'false']
    Default: 'false'
  StorageType:
    Description: 'Storage Type of DB-Instance.'
    Type: String
    AllowedValues: ['standard', 'gp2', 'io1']
    Default: 'gp2'
  UseDefaultProcessorFeatures:
    Description: 'Indicates whether the DB instance class of the DB instance uses its default processor features.'
    Type: String
    Default: false
    AllowedValues: [true, false]  
  VPCId: 
    Description: Create security group in this respective VPC
    Type: String
  privatesubnet01:
    Description: The Amazon RDS Subnet-1.  
    Type: String 
  privatesubnet02:
    Description: The Amazon RDS Subnet-2.  
    Type: String
  DBEncryptionKmsAlias:
    Description: The alias for Key Management Service encryption key alias
    Type: String
    Default: ''
  DatabaseEngine:
    Description: 'Database Engine version.'
    Type: String
    AllowedValues: [postgres, mysql, aurora-mysql, aurora]

                # Conditions CFN #
Conditions:
  useDBEncryptionKmsAlias: !Not
    - !Equals
      - !Ref 'DBEncryptionKmsAlias'
      - ''
  useDBSnapshot: !Not
    - !Equals
      - !Ref 'DBSnapshotName'
      - ''
  # CreateProdResources: !Equals 
  #   - !Ref DatabaseEngine
  #   - aurora


                # Resources CFN #
Resources:
  DatabaseSecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: !Ref 'AWS::StackName'
      VpcId: !Ref VPCId
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 5432
        ToPort: 5432
        CidrIp: 10.0.0.0/16


  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: rds private subnet 
      SubnetIds:
        - !Ref privatesubnet01
        - !Ref privatesubnet02


  DBInstance:
    DeletionPolicy: Snapshot # default
    UpdateReplacePolicy: Snapshot
    Type: 'AWS::RDS::DBInstance'
    Properties:
      AllocatedStorage: !Ref DBAllocatedStorage
      AllowMajorVersionUpgrade: false
      AutoMinorVersionUpgrade: true
      BackupRetentionPeriod: !Ref DBBackupRetentionPeriod
      CopyTagsToSnapshot: true
      EnablePerformanceInsights: !Ref EnablePerformanceInsights  
      DBInstanceClass: !Ref DBInstanceClass
      DBName: !Ref DBName
      DBSnapshotIdentifier: !If
        - useDBSnapshot
        - !Ref 'DBSnapshotName'
        - !Ref 'AWS::NoValue'      
      DBSubnetGroupName: !Ref DBSubnetGroup
      DeleteAutomatedBackups: !Ref DeleteAutomatedBackups
      DeletionProtection: !Ref DeletionProtection
      EnableIAMDatabaseAuthentication: !Ref EnableIAMDatabaseAuthentication
      Engine: !Ref DatabaseEngine
      MasterUsername: !Ref DBMasterUsername
      MasterUserPassword: !Ref DBMasterUserPassword
      MultiAZ: !Ref DBMultiAZ
      PreferredBackupWindow: !Ref PreferredBackupWindow
      PreferredMaintenanceWindow: !Ref PreferredMaintenanceWindow
      StorageType: !Ref StorageType
      PubliclyAccessible: !Ref PubliclyAccessible
      StorageEncrypted: !If
        - useDBEncryptionKmsAlias
        - 'true'
        - 'false'
      KmsKeyId: !If
        - useDBEncryptionKmsAlias
        - !Ref 'DBEncryptionKmsAlias'
        - !Ref 'AWS::NoValue'      
      Tags:
        - Key: Name
          Value: !Join [ '', [ 'Postgress- ', !Ref 'AWS::StackName' ] ]      
      UseDefaultProcessorFeatures: !Ref UseDefaultProcessorFeatures
      VPCSecurityGroups:
      - !Ref DatabaseSecurityGroup

################
# Aurora Cluster
################

  # RDSCluster: 
  #   Type: "AWS::RDS::DBCluster"  
  #   Properties: 
  #     BackupRetentionPeriod: 30
  #     DatabaseName: !Ref DatabaseName
  #     DBClusterParameterGroupName: 
  #       Ref: RDSDBClusterParameterGroup
  #     Port: 3306  
  #     DBSubnetGroupName: !Ref rdsDBSubnetGroup
  #     Engine: aurora
  #     EngineMode: serverless
  #     MasterUserPassword: 
  #       Ref: DatabaseMasterPassword
  #     MasterUsername: 
  #       Ref: DatabaseMasterUsername
  #     Tags:
  #       - Key: Name
  #         Value: !Join [ '', [ 'Aurora- ', !Ref 'AWS::StackName' ] ]        
  #     VpcSecurityGroupIds:
  #     - !Ref DatabaseSecurityGroup
      

  # RDSDBClusterParameterGroup: 
  #   Properties: 
  #     Description: "CloudFormation Sample Aurora Cluster Parameter Group"
  #     Family: aurora5.6
  #     Parameters: 
  #       time_zone: US/Eastern
  #   Type: "AWS::RDS::DBClusterParameterGroup"


  # RDSDBInstance1: 
  #   Type: "AWS::RDS::DBInstance"  
  #   Properties: 
  #     AvailabilityZone: us-east-1c
  #     DBClusterIdentifier: 
  #       Ref: RDSCluster
  #     DBInstanceClass: !Ref DatabaseInstanceType
  #     DBParameterGroupName: 
  #       Ref: RDSDBParameterGroup
  #     DBSubnetGroupName: !Ref rdsDBSubnetGroup
  #     Engine: aurora
  #     Tags:
  #       - Key: Name
  #         Value: !Join [ '', [ 'Aurora- ', !Ref 'AWS::StackName' ] ]
      


# Outputs:
#  TemplateID:
#    Description: 'cloudonaut.io template id.'
#    Value: 'state/rds-postgres'
#   TemplateVersion:
#     Description: 'cloudonaut.io template version.'
#     Value: '__VERSION__'
#   StackName:
#     Description: 'Stack name.'
#     Value: !Sub '${AWS::StackName}'
#   InstanceName:
#     Description: 'The name of the database instance.'
#     Value: !Ref DBInstance
#     Export:
#       Name: !Sub '${AWS::StackName}-InstanceName'
#   DNSName:
#     Description: 'The connection endpoint for the database.'
#     Value: !GetAtt 'DBInstance.Endpoint.Address'
#     Export:
#       Name: !Sub '${AWS::StackName}-DNSName'
#   SecurityGroupId:
#     Description: 'The security group used to manage access to RDS Postgres.'
#     Value: !Ref DatabaseSecurityGroup
#     Export:
#       Name: !Sub '${AWS::StackName}-SecurityGroupId'