DATE=$(date +%Y-%m-%d_%H-%M) 
AMI_NAME="Firegr-ami"
ASG_NAME=$1
INSTANCE_ID="i-076605929800bab3a"
#aws ec2 run-instances --image-id ami-0c45382841b8d21fa --instance-type t2.medium --key-name Firegr-key --subnet-id subnet-0a8ba75bd9f0dafda --security-group-ids sg-00e1b498004f5b132 

#INSTANCE_ID=$(aws ec2 describe-instances --filters 'Name=image-id,Values=ami-0c45382841b8d21fa' --filters 'Name=instance-state-name,Values=pending' --query Reservations[*].Instances[*].[InstanceId] --output 'text' --region ap-southeast-1)

OLD_AMI=$(aws ec2 describe-images --region ap-southeast-1 --owners '436696877611' --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' --output 'text' --filters 'Name=name,Values=Firegr-ami')

if [[ ${OLD_AMI} != "" ]]; then
  aws ec2 deregister-image --image-id $OLD_AMI
  sleep 60
else
  exit 0
fi

#printf "Requesting AMI for instance $1..."
aws ec2 create-image --instance-id ${INSTANCE_ID} --name "$AMI_NAME" --no-reboot >/dev/null  2>&1

#if [ $? -eq 0 ]; then
#		printf "AMI request complete!"
#fi

NEW_AMI=$(aws ec2 describe-images --region ap-southeast-1 --owners '436696877611' --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' --output 'text' --filters 'Name=name,Values=Firegr-ami')

aws autoscaling create-launch-configuration --launch-configuration-name "Firegr"-${DATE} --image-id ${NEW_AMI} --instance-type t2.medium --key Firegr-key --associate-public-ip-address --security-groups sg-00e1b498004f5b132

aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${ASG_NAME} --launch-configuration-name "Firegr"-${DATE} --debug

sed -i "s/LC_NAME/Firegr-${DATE}/g" firegr.py
