#!/bin/bash
# Install CloudWatch Logs Agent
yum update -y
yum install -y awslogs

# Configure CloudWatch Logs Agent
cat > /etc/awslogs/awslogs.conf <<AWSCONF
[general]
state_file = /var/lib/awslogs/agent-state

[messages]
file = /var/log/messages
log_group_name = ${log_group_name}
log_stream_name = ${environment}-${name_prefix}-messages
datetime_format = %b %d %H:%M:%S

[secure]
file = /var/log/secure
log_group_name = ${log_group_name}
log_stream_name = ${environment}-${name_prefix}-secure
datetime_format = %b %d %H:%M:%S

[httpd-access]
file = /var/log/httpd/access_log
log_group_name = ${log_group_name}
log_stream_name = ${environment}-${name_prefix}-httpd-access

[httpd-error]
file = /var/log/httpd/error_log
log_group_name = ${log_group_name}
log_stream_name = ${environment}-${name_prefix}-httpd-error
datetime_format = [%a %b %d %H:%M:%S.%f %Y]
AWSCONF

# Configure AWS region
sed -i 's/us-east-1/ap-southeast-2/g' /etc/awslogs/awscli.conf

# Start and enable CloudWatch Logs Agent
systemctl start awslogsd
systemctl enable awslogsd

