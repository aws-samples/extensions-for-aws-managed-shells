FROM amazonlinux:2

ADD extensions-for-aws-managed-shells.sh extensions-for-aws-managed-shells_check.sh ./
RUN yum install -y sudo 
RUN /extensions-for-aws-managed-shells.sh 
CMD /bin/sh