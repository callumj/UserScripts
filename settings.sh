source ~/.user_data/git-completion.bash

alias mdbgo="sh ~/.user_data/startmongo.sh"
alias memgo="memcached -vvvvv"
alias passgo="passenger start"
alias cpyg="git url | tr -d '\n' | pbcopy"
alias reload="source ~/.bash_profile"
alias ls="ls -l"
alias testgo="bundle exec spork cucumber"
alias testall="cucumber features"
alias masterpull="git checkout master && git pull; git checkout development"
alias foundation="consular start foundation"
alias autonetdisable="sudo launchctl unload -w /System/Library/LaunchDaemons/com.callumj.autoswitch.network.plist"
alias autonetenable="sudo launchctl load -w /System/Library/LaunchDaemons/com.callumj.autoswitch.network.plist"
alias txt="macruby ~/.user_data/scripts/txt.macruby.rb"
alias edit="/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"

CUSTOM_PATH=$HOME/bin:/usr/local/sbin:$HOME/Applications/MongoDB/bin
export EDITOR=mate
export TERM_EDITOR=vi

export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
export EC2_HOME="/usr/local/Cellar/ec2-api-tools/1.5.2.3/jars"
