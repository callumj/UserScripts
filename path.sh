if [[ ! $PATH =~ .*$CUSTOM_PATH.* ]]
then
	PATH=$CUSTOM_PATH:$PATH
fi