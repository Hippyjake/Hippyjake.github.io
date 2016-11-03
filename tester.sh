#!/usr/bin/env bash
#colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo "${yellow}Checking For Ruby${reset}"
if which ruby
then
  echo "${green}Found Ruby${reset}"
  
else
  echo "${red}Please Install Ruby With Your Package Manager${reset}"
  exit
fi

echo "${yellow}Exporting path${reset}"

rbversion=$(ruby --version | awk '{print substr($2, 0, 4)}' | awk '$1=$1"0"')
case "$rbversion" in
  $rbversion)
    echo "${yellow}Setting path For${reset}${green} $rbversion${reset}"
    export PATH=~/.gem/ruby/$rbversion/bin:$PATH
  ;;
  *)
    echo "$rbversion"
  ;;
esac

echo "${yellow}Checking For Jekyll${reset}"
if [ -f ~/.gem/ruby/"$rbversion"/bin/jekyll ]
then
  echo "${green}Found Jekyll${reset}"
  
else
  echo "${red}Installing Jekyll${reset}"
  gem install jekyll --user-install
fi

echo "${yellow}Checking For Bundler${reset}"
if [ -f ~/.gem/ruby/"$rbversion"/bin/bundler ]
then
  echo "${green}Found Bundler${reset}"
  
else
  echo "${red}Installing Bundler${reset}"
  gem install bundler --user-install
fi

echo "${yellow}Checking Dependencies${reset}"
if [ -d vendor ]
then
  echo "${green}Found vendor folder${reset}"
  echo -e "${green}Updating Dependencies \n Update log can be found at logs/bundelUpdate.txt${reset}"
  bundle update > logs/bundelUpdate.txt
else
  echo "${red}Installing Dependencies${reset}"
  bundle install --path vendor
fi

echo "${yellow}Checking for old _site${reset}"
if [ -d _site ]
then
  echo "${red}Cleaning up site cache${reset}"
  rm -rf _site
  echo "${green}Done${reset}"
else
  echo "${green}All set${reset}"
fi

echo "${green}Opening Browser Tab...${reset}"
echo "${yellow}You Will Need To Refresh Your Browser After The Server Starts${reset}"
sleep 5
xdg-open http://localhost:4000 &

echo "${green}Statring Jekyll${reset}"

bundle exec jekyll serve > logs/jekyllLog.txt &
echo "Jekyll output can be found at logs/jekyllLog.txt"
echo -e "${green}$(gettext 'Press ENTER to stop Jekyll and leave script')${reset}"
function pause(){
  read -rp "$*"
  pgrep -f "jekyll" | xargs kill -INT
}
pause "$@"

echo ""
echo "Bye!"
exit
