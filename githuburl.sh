echo https://github.com/`git config remote.origin.url` | sed -E s/[a-z]+@github\.com:// | sed s/\.git$//