# ssmauth
SSMAUTH provides a method of automating the creation and deletion of local users on an EC2 instance associated with a AWS Cloudformation stack.  This project includes A Cloudformation Template which will build 2 lambda functions to manage the automation.  It relies on AWS Cloudformation Output keys, IAM Groups, IAM User SSH keys, AWS SSM, and a local ruby script deployed on each instance.

## Includes
- CF Template
- alternate Apex/python based lambdas
- related ruby script for IAM based local user management

## IAM Requirements
- SSH keys for users requiring SSH access
- users in a $targetGroup associated with required access to the CF Stack
- optionally create SiteReliabilityEngineers & SecurityEngineers IAM Groups for default SRE or Sec users

## CF Stack Requirements
- Output
  - key:  OutputInstanceIAMGroup value: $targetGroup

## AMI Requirements
- [iam-authorized-keys-command](https://github.com/Fullscreen/iam-authorized-keys-command)
- [ssm-agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html)
- a [ruby](https://www.ruby-lang.org/en/) interpretur on the instances being managed
- place the included ruby script in /usr/local/bin, and make it executible

## Todo
- convert ruby script to golang or bash
- sample InstanceRole policy allowing the SSM & IAM SSH Key lookups
