### What is it?

Both the AWS CloudShell and AWS Cloud9 environments are curated and regularly updated. However you may find your self needing a specific utility or tool that has not been pre-installed OR a specific latest version of a tool that has been pre-installed (and that has not yet been updated). 

`Extensions for AWS managed shells` is a(n experimental) script that allows AWS CloudShell users and AWS Cloud9 (with Amazon Linux 2) users to do two things: update the version of pre-installed utilities and install additional utilities. Feel free to add (via PR) additional utilities you may find useful. In addition to this the repository contains a `Dockerfile` that would allow you to build a self-contained image (FROM AL2). 

The `Extensions for AWS managed shells` script installs and/or updates the following tools and utilities:
- [Oh My Zsh](https://ohmyz.sh/) [MIT license - [link](https://github.com/ohmyzsh/ohmyzsh/blob/master/LICENSE.txt)]
- [PowerShell](https://github.com/PowerShell/PowerShell) [MIT license - [link](https://github.com/PowerShell/PowerShell/blob/master/LICENSE.txt)]
- [AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) [Apache Software license v2 - [link](https://github.com/aws/aws-cli/blob/develop/LICENSE.txt)]
- [AWS Elastic Beanstalk CLI](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-advanced.html) - [Apache Software license - [link](https://pypi.org/project/awsebcli/)]
- [AWS CDK](https://github.com/awslabs/aws-cdk) - [Apache Software license v2 - [link](https://github.com/aws/aws-cdk/blob/master/LICENSE)]
- [CDK8s](https://cdk8s.io/) - [Apache Software license v2 - [link](https://github.com/awslabs/cdk8s/blob/master/LICENSE)]
- [SAM CLI](https://github.com/aws/aws-sam-cli) - [Apache Software license v2 - [link](https://github.com/aws/aws-sam-cli/blob/develop/LICENSE)]
- [AWS IR](https://aws_ir.readthedocs.io/en/latest/) - [MIT license - [link](https://aws-ir.readthedocs.io/en/latest/about.html#license)]
- [awsls](https://github.com/jckuester/awsls) - [MIT license - [link](https://github.com/jckuester/awsls/blob/master/LICENSE.md)]
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - [Apache Software license v2 - [link](https://github.com/kubernetes/kubectl/blob/master/LICENSE)]
- [IAM Authenticator for AWS](https://github.com/kubernetes-sigs/aws-iam-authenticator) - [Apache Software license v2 - [link](https://github.com/kubernetes-sigs/aws-iam-authenticator/blob/master/LICENSE)]
- [helm version 3](https://github.com/helm/helm) - [Apache Software license v2 - [link](https://github.com/helm/helm/blob/master/LICENSE)]
- [eksctl](https://github.com/weaveworks/eksctl) - [Apache Software license v2 - [link](https://github.com/weaveworks/eksctl/blob/master/LICENSE)]
- [kubecfg](https://github.com/ksonnet/kubecfg) - [Apache Software license v2 - [link](https://github.com/bitnami/kubecfg/blob/master/LICENSE)]
- [kubectx/kubens](https://github.com/ahmetb/kubectx/) - [Apache Software license v2 - [link](https://github.com/ahmetb/kubectx/blob/master/LICENSE)]
- [ksonnet](https://github.com/ksonnet/ksonnet) - [Apache Software license v2 - [link](https://github.com/ksonnet/ksonnet/blob/master/LICENSE)]
- [k9s](https://k9ss.io/) - [Apache Software license v2 - [link](https://k9ss.io/)]
- [docker](https://docs.docker.com/engine/) - [Apache Software license v2 - [link](https://github.com/docker/engine/blob/master/LICENSE)]
- [docker-compose](https://docs.docker.com/compose/) - [Apache Software license v2 - [link](https://github.com/docker/compose/blob/master/LICENSE)]
- [bat](https://github.com/sharkdp/bat/) - [Apache Software license v2 - [link](https://github.com/sharkdp/bat/blob/master/LICENSE-APACHE)]
- [kind](https://kind.sigs.k8s.io/) - [Apache Software license v2 - [link](https://github.com/kubernetes-sigs/kind/blob/master/LICENSE)] [Only available in Cloud9]
- [Octant](https://github.com/vmware-tanzu/octant) - [Apache Software license v2 - [link](https://github.com/vmware-tanzu/octant/blob/master/LICENSE)] [Only available in Cloud9]
- [VS Code server](https://github.com/cdr/code-server) - [MIT license - [link](https://github.com/cdr/code-server/blob/v3.8.0/LICENSE.txt)] [Only available in Cloud9]
- additional utils: unzip, jq, vi, wget, less, git, yarn, which and httpd-tools (and more, just in case) 

The script also installs and/or updates the following pre-requisites: 
- NodeJS 
- Pip 


### What's the version of the utilities included?

The whole purpose of the script is to install the latest version of existing pre-installed tools and to upgrade to the latest version the tools that are already installed (and that may be lagging behind a few releases).


### How can I use it?

The script is designed to work for both the AWS CloudShell as well as for AWS Cloud9. Because the two environments have different charatheristics, the script usage pattern may vary. 

Cloud9 is persistent by design so it's likely that you may need to run the script only after the first deployment or when you want to update the tools. Also, because the Cloud9 environment has inbound connectivity, the script installs additional tools (e.g. kind, VS Code server and possibly others) when it detects it's running in a Cloud9 shell. Note the script is only designed to work with the Amazon Linux 2 OS installed (for consistency, because that is the same OS powering AWS CloudShell).

CloudShell only persists up to 1GB of disk space for the `$HOME` folder. Given all the tools the script installs lands on a system folder, the user would need to run the script every time the CloudShell reconnects. Perhaps a good idea would be to persist a clone of the repo in the `$HOME` folder for a speedy launch. Someone may go the extra mail and force the script to run at [every start of the CloudShell](https://docs.aws.amazon.com/cloudshell/latest/userguide/vm-specs.html#modifying-shell-scripts).

In addition to these main options, the repository includes an experimental `Dockerfile` that would allow you to build a portable container (built from the Amazon Linux 2 image). You can build the container with this command: 
```
docker build -t extensions-for-aws-managed-shells:latest . 
```

You can then run it with the following command:
```
docker run -e NODE_PATH=/root/nvm/versions/node/v12.20.0/lib/node_modules -e PATH=/root/nvm/versions/node/v12.20.0/bin:$PATH --rm -it extensions-for-aws-managed-shells:latest 
```

### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

### License

This library is licensed under the MIT-0 License. See the LICENSE file.
