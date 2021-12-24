#!/bin/bash

export NODE_VERSION=16.13.0

################## SETUP ENV ###############################
#EKS-ANYWHERE EKSCTL EXTENSION
export EKSA_RELEASE="0.5.0" OS="$(uname -s | tr A-Z a-z)"
### OCTANT
# browser autostart at octant launch is disabled
# ip address and port are modified (to better work with Cloud9)  
export OCTANT_DISABLE_OPEN_BROWSER=1
export OCTANT_LISTENER_ADDR="0.0.0.0:8080"
### NODE
# this installs in the HOME directory which, for CloudShell, could be a waste. Consider moving to /nvm or /usr/local/bin/nvm ?  
export NVM_DIR=$HOME/nvm
export NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
export PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
export NODE_VERSION=${NODE_VERSION}
### CODE-SERVER
export PATH=/usr/local/bin/code-server/bin:$PATH
################## BEGIN INSTALLATION ######################

######################################
## begin setup add-on systems tools ##
######################################

# setup various utils (latest at time of docker build)
# docker is being installed to support DinD scenarios (e.g. for being able to build)
# httpd-tools include the ab tool (for benchmarking http end points)
yum install sudo -y 
sudo yum update -y \
 && sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && sudo yum install -y \
            git \
            sudo \
            httpd-tools \
            iputils \
            jq \
            less \
            openssl \
            openssl11 \
            python3 \
            gcc \
            tar \
            unzip \
            vi \
            wget \
            which \
            procps-ng \
            figlet \
 && curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo \
    && sudo yum install -y yarn \
 && sudo yum clean all \
 && sudo rm -rf /var/cache/yum

####################################
## end setup add-on systems tools ##
####################################


####################################
##   move into a temp directory   ##
####################################

tmpdir=$(mktemp -d)
cd $tmpdir 

########################################
## begin setup runtime pre-requisites ##
########################################

# Node
mkdir -p ${NVM_DIR} \
 && curl -s https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
 && . $NVM_DIR/nvm.sh \
 && nvm install $NODE_VERSION \
 && nvm alias default $NODE_VERSION \
 && nvm use default


# Upgrade NPM
sudo npm install -g npm

# setup Typescript (latest at time of docker build)
sudo npm install -g typescript

# setup pip (latest at time of docker build)
curl -s https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py \
   && python get-pip.py
 
########################################
### end setup runtime pre-requisites ###
########################################

###########################
## begin setup utilities ##
###########################

# setup zsh (shell)
if [ "$DOCKER" = "true" ]
    then sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)"
    else sudo yum -y install zsh 
fi


# setup MS PowerShell
LATEST=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep linux-x64.tar.gz) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep linux-x64.tar.gz) \
&& curl -L -O $X86URL \
&& sudo mkdir -p /usr/local/bin/powershell/7 \
&& sudo tar -zxvf $X86ARTIFACT -C /usr/local/bin/powershell/7 \
&& sudo chmod +x /usr/local/bin/powershell/7/pwsh \
&& sudo ln -s /usr/local/bin/powershell/7/pwsh /usr/local/bin/pwsh

# setup the aws cli v2 (latest at time of docker build)
curl -Ls "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && sudo ./aws/install --update \
 && /usr/local/bin/aws --version

# setup the eb cli (latest at time of docker build)
pip3 install awsebcli --upgrade  

# setup the aws cdk cli (latest at time of docker build)
sudo npm i -g aws-cdk

# setup the cdk8s cli (latest at time of docker build)
sudo npm i -g cdk8s-cli

# setup SAM CLI 
sudo pip3 install aws-sam-cli --upgrade

# setup awsls 
LATEST=$(curl -s https://api.github.com/repos/jckuester/awsls/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep linux_amd64.tar.gz) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep linux_amd64.tar.gz) \
&& curl -L -O $X86URL \
&& tar -zxvf $X86ARTIFACT \
&& sudo mv awsls /usr/local/bin/awsls

# setup kubectl (latest at time of docker build)
curl -sLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl

# setup kubecolor 
LATEST=$(curl -s https://api.github.com/repositories/302255735/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep Linux_x86_64.tar.gz) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep Linux_x86_64.tar.gz) \
&& curl -L -O $X86URL \
&& tar -zxvf $X86ARTIFACT \
&& sudo mv kubecolor /usr/local/bin/kubecolor 

# setup the IAM authenticator for aws (for Amazon EKS)
LATEST=$(curl -s https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep linux_amd64) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep linux_amd64) \
&& curl -sLo aws-iam-authenticator $X86URL \
&& chmod +x ./aws-iam-authenticator \
&& sudo mv ./aws-iam-authenticator /usr/local/bin

# setup Helm (latest at time of docker build)
curl -sLo get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
 && chmod +x get_helm.sh \
 && ./get_helm.sh

# setup eksctl (latest at time of docker build)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
    && sudo mv -v /tmp/eksctl /usr/local/bin

# setup eks-anywhere extension for eksctl (specific version)
curl "https://anywhere-assets.eks.amazonaws.com/releases/eks-a/1/artifacts/eks-a/v${EKSA_RELEASE}/${OS}/eksctl-anywhere-v${EKSA_RELEASE}-${OS}-amd64.tar.gz" \
    --silent --location \
    | tar xz ./eksctl-anywhere
sudo mv ./eksctl-anywhere /usr/local/bin/

# setup kubecfg 
LATEST=$(curl -s https://api.github.com/repositories/91519321/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep linux-amd64) \
&& curl -sLo kubecfg $X86URL \
&& chmod +x ./kubecfg \
&& sudo mv kubecfg /usr/local/bin/kubecfg 

# setup kubectx/kubens
sudo git clone https://github.com/ahmetb/kubectx /usr/local/bin/kubectxkubens
sudo ln -s /usr/local/bin/kubectxkubens/kubectx /usr/local/bin/kubectx
sudo ln -s /usr/local/bin/kubectxkubens/kubens /usr/local/bin/kubens

# setup ksonnet 
LATEST=$(curl -s https://api.github.com/repos/ksonnet/ksonnet/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep linux_amd64.tar.gz) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep linux_amd64.tar.gz) \
&& curl -L -O $X86URL \
&& tar -zxvf $X86ARTIFACT --strip-components=1 \
&& sudo mv ks /usr/local/bin/ks 

# setup k9s 
LATEST=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep Linux_x86_64.tar.gz) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep Linux_x86_64.tar.gz) \
&& curl -L -O $X86URL \
&& tar -zxvf $X86ARTIFACT \
&& sudo mv k9s /usr/local/bin/k9s 

# setup docker
sudo amazon-linux-extras install docker -y

# setup docker-compose 
LATEST=$(curl -s https://api.github.com/repos/docker/compose/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep $(uname -s)-$(uname -m)) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep $(uname -s)-$(uname -m)) \
&& curl -Lo ./docker-compose $X86URL\
&& chmod +x ./docker-compose \
&& sudo mv ./docker-compose /usr/local/bin/docker-compose 

# setup bat
LATEST=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest) \
&& X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep x86_64-unknown-linux-gnu.tar.gz) \
&& X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep x86_64-unknown-linux-gnu.tar.gz) \
&& curl -L -O $X86URL \
&& tar -zxvf $X86ARTIFACT \
&& sudo mv $(echo $X86ARTIFACT | sed -r 's/.tar.gz//')/bat /usr/local/bin 

# setup kind
if [ "$AWS_EXECUTION_ENV" != "CloudShell" ]
    then
        LATEST=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest) \
        && X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep kind-linux-amd64) \
        && X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep kind-linux-amd64) \
        && curl -Lo ./kind $X86URL\
        && chmod +x ./kind \
        && sudo mv ./kind /usr/local/bin/kind 
    else 
        echo "skipping because Kind can't work in CloudShell"
fi

# setup Octant
if [ "$AWS_EXECUTION_ENV" != "CloudShell" ]
    then
        LATEST=$(curl -s https://api.github.com/repos/vmware-tanzu/octant/releases/latest) \
        && X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep Linux-64bit.tar.gz) \
        && X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep Linux-64bit.tar.gz) \
        && curl -L -O $X86URL \
        && tar -zxvf $X86ARTIFACT \
        && sudo mv $(echo $X86ARTIFACT | sed -r 's/.tar.gz//')/octant /usr/local/bin/octant
    else 
        echo "skipping because Octant can't work in CloudShell"
fi

# setup VS Code server
if [ "$AWS_EXECUTION_ENV" != "CloudShell" ]
    then
        if [ -d "/usr/local/bin/code-server-dir" ]; then sudo rm -Rf /usr/local/bin/code-server-dir; sudo rm /usr/local/bin/code-server; fi
        LATEST=$(curl -sL https://api.github.com/repos/cdr/code-server/releases/latest) \
        && X86URL=$(echo $LATEST | jq -r '.assets[].browser_download_url' | grep linux-amd64) \
        && X86ARTIFACT=$(echo $LATEST  | jq -r '.assets[].name' | grep linux-amd64) \
        && curl -L -O $X86URL \
        && tar -zxvf $X86ARTIFACT \
        && sudo mv $(echo $X86ARTIFACT | sed -r 's/.tar.gz//') /usr/local/bin/code-server-dir \
        && sudo ln -s /usr/local/bin/code-server-dir/bin/code-server /usr/local/bin/code-server
    else 
        echo "skipping because Code Server can't work in CloudShell"
fi
#########################
## end setup utilities ##
#########################

####################################
##   move into a temp directory   ##
####################################

cd $HOME
sudo rm -r $tmpdir 

##################### INSTALLATION END #####################
