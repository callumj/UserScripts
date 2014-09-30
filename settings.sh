source ~/.user_data/git-completion.bash

alias cpyg="git url | tr -d '\n' | pbcopy"
alias reload="source ~/.bash_profile"
alias ls="ls -l -a"
alias testall="spec spec/"
alias masterpull="git checkout master && git pull; git checkout development"
alias autonetdisable="sudo launchctl unload -w /System/Library/LaunchDaemons/com.callumj.autoswitch.network.plist"
alias autonetenable="sudo launchctl load -w /System/Library/LaunchDaemons/com.callumj.autoswitch.network.plist"
alias mdprev="markdown $1 | bcat;"
alias spec="rspec"
alias beam="open -a \"Beamer\""
alias mkvb="open -a \"Beamer\" *.mkv"
alias nl2s="ssh -L 6243:localhost:4243 -L 6880:localhost:6880 -L 8500:localhost:8500 nl2.callumj.com"
alias dtest1s="ssh -L 7243:localhost:4243 root@dockertest1.callumj.com"
alias gst="git status"
alias gadd="git add"
alias gcm="git commit"
alias dalt="HOME=$HOME/.dropbox-alt /Applications/Dropbox.app/Contents/MacOS/Dropbox &"
function ginst { go install ${PWD/\/Users\/callumj\/Development\/go\/src\//}; }
export GOPATH=$HOME/Development/go

function gsq { git rebase -i HEAD~$1; } 

CUSTOM_PATH=$GOPATH/bin:./bin:/Applications/Sublime\ Text.app/Contents/SharedSupport/bin:/Applications/Postgres93.app/Contents/MacOS/bin:$HOME/.rbenv/bin:$HOME/bin:/usr/local/sbin:$HOME/Applications/MongoDB/bin
export EDITOR=vi
export TERM_EDITOR=vi

export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
export EC2_HOME="/usr/local/Cellar/ec2-api-tools/1.5.2.3/jars"
export POKE_APP_PATH="/Users/callumj/Development/Projects/poke_data"

export DOCKER_HOST="tcp://127.0.0.1:4243"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
