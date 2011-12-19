cur_path=`dirname $0`
script=$cur_path"/mongo_save.rb -t 30 -d cgr_foundation_development -o /Users/callumj/DevelopmentTools/dumps/ -b /Users/callumj/Applications/MongoDB/bin -m /Users/callumj/Applications/MongoDB/data"
ruby $script &
~/Applications/MongoDB/bin/mongod -vvv --dbpath ~/Applications/MongoDB/data
kill $!
