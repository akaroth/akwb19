# akwb19

<h2> Requirements </h2>

```
Terraform >= 0.14.5.
```
Platform used is AWS . The api keys used to interact with an AWS account is expected to available locally as an env variable. This can be configured by following this [guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).
Once the profile is initialized , the script also expects a key-pair to login to the system . This can be avoided by either configuring ssm client to work with systems manager . If using keys, please change the name of the key used in the variables.tf file.

Once done , terraform init> terraform plan > terraform apply will setup all the resources .

Also , this POC was not tested for the rpc implemetation . The config.toml files were checked and the rpc ports were enabled . However for the rpc to be available , the blockchain data had to be completely seeded . Due to time constraints , this part was not done/tested.

<h2> Architectural Design </h2>

The design shown in this demo shows only a sigle client. The POC just showcases how to run the client and manage the upgrade of the client after a certain height.
This POC is running the mainnet of the CDC blockchain.


<h2> Current limitation </h2>

* The current module used for imlementing security groups has been observed not to create the outbound rules even when specified . this mostly is a bug and can be fixed by using another module or an egress resource rule like [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule#usage-with-prefix-list-ids).
* Monitoring is not implemented . If monitoring is enabled , assuming there be an exporter to work with prometheus , the block height can be checked and alerted when the block height reaches a certain level . At this point the script(restart_new_client.sh) created to change the client can be triggered.
* This is a standalone node implementation , meaning if the node goes down , the service stops . The ideal implementation would be nodes running in an ASG proxied by a ELB and fronted by a Cloudfront which may also be used cache data which doesnt change much. 
* No configuration tool like Ansible used . These tools can help manage the change of client in case there are large number of nodes 

<h2> DevOps Guidelines and Best Practices </h2>

Below are guidelines you need to follow based on the current system design and security rules. 
<h4>Network Design:</h4>

* IP CIDR Plan - Pick a vpc cidr that is not overlapped with existing network.
* Cross-AZ High Availability - The basic subnet design should have three types subnet across all availability zones. Most aws regions have at least three availability zones.
* Three public subnet which has default route point to igw
* Three nat subnet which has default route point to natgw. You need to put one natgw in each of availability zone
* Three private subnet which has no default route
* You can add more subnets just for management purposes when necessary, but the type will always be three. For example, you can create different subnets for internal alb, redis, rds, but they should bind to the same route table which has no default route which you can create different subnets for ec2 and ecs, but they should bind to the same nat route table.
* Routing Table Design - No matter what kind of vpc you are using, 5 route table is enough and has best practice for 3 availability zone region
* One public route table which has a default route to igw. It can be bound to the public ec2 subnet, external ALB subnet, etc.
* One private route table which has no default route. It can be bound to redis subnet, rds subnet, etc.
* One nat route table which is the default route to natgw for each availability zone. It can be bound to nat ec2 subnet, nat ecs subnet, etc.
* Minimize exposure with public subnet design - Although you can have public subnet point to igw, usually you will only put external alb in this subnet. Use the following ways if you want to put ec2 in a public subnet.
* For ssh access: using aws session manager instead.
* Open service for public access: using external alb and put ec2 behind it
* EIP will only need to be bind to natgw, ec2 and rds usually doesn’t need to bind public ip
* Security Group - Create a different security group for each of aws services such as ec2/alb/ecs/rds/redis etc even some of the resources may have the same security group rule. And just open specific and source with least privilege
* Use terraform to design and manage your networking.
* Networking Topology - For external system, you should use cloudfront->external alb->services arch, enable aws shield and waf on cloudfront and alb
* S3 Bucket Access - For S3 bucket, never set s3 bucket as public access. Always put cloudfront in front of s3 for public access content such as static js file.

<h4>AWS Account and IAM Management:</h4>

* Root account management - Enable 2fa/yubikey for root account. The root account should be locked down and never use it in daily operation. Please transfer the ownership of the root account for centralized management. 
* Terraform IAM Module
* Never create Access & Secret Key pairs on production systems - Never create access key/secret access key, use the following ways instead.
* For ec2/ecs/lambda etc to access aws services, always use role
* For local development, use saml2aws to get temp ak/sk

<h4>DevOps Tool Security</h4>

* Zero-Trust Security on daily DevOps - For internal systems that need web access such as jenkins,grafana,kibana,aws,archery, etc, you need to integrate with okta. Whitelist vpn ip in security group and build private connection between vpc.
* Bastion Server v.s. AWS Session Manager - AWS Session Manager usually provides better security over open source or commercial bastion servers. If you need to have a dedicated bastion server solution, please reach DevSecOps team for discussions.

<h4>Sensitive credential management and integrations</h4>

* Credentials such as database access credentials, wallet key, api key should be kept in AWS secrets manager (KMS backed), where applications need to integrate AWS SDK for access.  Note that we usually need to separate the access credentials for applications from manual operations - like database management.

