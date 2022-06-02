# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
ZSH_DISABLE_COMPFIX="true"

# Path to your oh-my-zsh installation.
export ZSH="/Users/tobias/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="avit"
ZSH_THEME="gnzh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

SHOW_AWS_PROMPT=false

plugins=(git zsh-autosuggestions zsh-syntax-highlighting aws)

source $ZSH/oh-my-zsh.sh

login_aws_kubectl() {
    if [ "$1" = "prod" ]; then
        port=12341
    elif [ "$1" = "int" ]; then
        port=12342
    else
        port=12345
    fi
    local bastionHostId=$(aws cloudformation --profile $3 describe-stacks  --stack-name IsiTargetApp-$1-Stack --query "Stacks[0].Outputs[?OutputKey=='BastionHostInstance'].OutputValue" --output text)
    local kubectlUrl=${$(aws cloudformation --profile $3 describe-stacks  --stack-name IsiTargetApp-$1-Stack --query "Stacks[0].Outputs[?OutputKey=='BastionKubeconfigServer'].OutputValue" --output text )/https:\/\//}
    local inConn=$(aws ec2-instance-connect send-ssh-public-key --instance-id $bastionHostId --instance-os-user ec2-user --availability-zone eu-west-1a --ssh-public-key file://$2 --profile $3)
    AWS_PROFILE=$3 ssh ec2-user@$bastionHostId -fNT -L $port:$kubectlUrl:443
}

function aws_prompt_info() {
  [[ -z $AWS_PROFILE ]] && return
  echo "%{$reset_color%} | %{$fg[blue]%}aws:${AWS_PROFILE}%{$reset_color%}"
}


alias a='aws'
alias d="docker"
alias dc="docker-compose"
alias k="kubectl"
alias mvn="/Users/tobias/.m2/wrapper/dists/apache-maven-3.6.3-bin/1iopthnavndlasol9gbrbg6bf2/apache-maven-3.6.3/bin/mvn"

alias bastion_dev="login_aws_kubectl dev ~/.ssh/id_rsa.pub pag-dev"
alias bastion_int="login_aws_kubectl int ~/.ssh/id_rsa.pub pag-int"
alias bastion_prod="login_aws_kubectl prod ~/.ssh/id_rsa.pub pag-prod"


alias awst-oreres="awstoken -rsa -u vwbxaz5 -a 817789906003 -region eu-west-1 -r PA_DEVELOPER -p ore-res"
alias awst-oredev="awstoken -rsa -u vwbxaz5 -a 655385917808 -region eu-west-1 -r PA_DEVELOPER -p ore-dev"

alias awst-pagint="awstoken -rsa -u vwbxaz5 -a 518456700320 -region eu-west-1 -r PA_DEVELOPER -p pag-int"
alias awst-pagdev="awstoken -rsa -u vwbxaz5 -a 178467815056 -region eu-west-1 -r PA_DEVELOPER -p pag-dev"


export DEVSTACK_USERNAME=""
export DEVSTACK_PASSWORD=""
export BDH_TOKEN=""

export ISI_AWS_RES_ACCOUNT_USERNAME=""
export ISI_AWS_RES_ACCOUNT_PASSWORD=""

export AWS_REGION="eu-west-1"
export GPG_TTY=$(tty)

if [ /usr/local/bin/kubectl ]; then source <(kubectl completion zsh); fi

# BUILD PROMPT
PROMPT='%(?:%{$fg[green]%}╭─ :%{$fg[red]%}╭─ )'
PROMPT+='%{$fg[green]%}%n@%{$fg[red]%}%m %{$fg[blue]%}%~%{$reset_color%}$(git_prompt_info)$(aws_prompt_info)'
PROMPT+='
%(?:%{$fg_bold[green]%}╰─%{$reset_color%} :%{$fg_bold[red]%}╰─%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[magenta]%}<"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[magenta]%}> "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}%{$fg[blue]%}*"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}"

export PATH="/usr/local/sbin:$PATH"
source $HOME/.cargo/env

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
