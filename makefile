CR := \033[1;31m
CG := \033[1;32m
CB := \033[1;34m
CC := \033[1;36m
CD := \033[0m
EOK := "${CG}» OK${CD}"

export HOMEBREW_CASK_OPTS:=--appdir=/Applications

.SILENT: apps guiapps dotfiles scripts source structure publish

help:
	#
	# Usage
	#	Order
	#		make apps
	#		make guiapps
	#		make dotfiles
	#		make scripts
	#		make source
	#		make structure
	#
	#	Commands should be idempotent
	#

apps:
	echo "${CB}» Installing XCODE${CD}"
	xcode-select --install || true
	echo ${EOK}

	echo ""
	echo "${CB}» Installing BREW${CD}"
	if ! hash brew 2>/dev/null; then \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install > /tmp/brew.installer && ruby /tmp/brew.installer || true ;\
	fi ;\
	echo ${EOK}

	echo ""
	echo "${CB}» Updating BREW${CD}"
	brew update
	brew upgrade
	echo ${EOK}

	echo ""
	echo "${CB}» Installing APPS${CD}"
	brew install bash
	brew install bash-completion
	brew install diff-so-fancy
	brew install git
	brew install go
	brew install htop
	brew install httpie
	brew install nano
	brew install pyenv
	brew install pyenv-virtualenv
	brew install rust
	brew install tldr
	brew install tree
	brew install zsh
	brew install zsh-autosuggestions
	brew install zsh-syntax-highlighting
	brew install zlib
	echo ${EOK}

	echo ""
	echo "${CB}» Installing PYTHON${CD}"
	pyenv install 3.7.4 || true
	pyenv install 3.8.0 || true
	echo ${EOK}

	echo ""
	echo "${CB}» Cleanup BREW${CD}"
	brew cleanup -s
	brew doctor || true
	echo ${EOK}

guiapps:
	echo ""
	echo "${CB}» Updating BREW CASK${CD}"
	brew tap homebrew/cask
	brew tap homebrew/cask-fonts
	brew tap homebrew/cask-versions
	brew update
	echo ${EOK}

	echo ""
	echo "${CB}» Installing GUI APPS${CD}"
	apps=( \
		datagrip \
		docker \
		dropbox \
		figma \
		firefox \
		enpass \
		font-source-code-pro \
		font-source-sans-pro \
		github \
		google-chrome \
		hammerspoon \
		hyperswitch \
		intellij-idea \
		iterm2 \
		pycharm \
		sizeup \
		skype \
		sublime-text \
		typora \
		vlc \
		xquartz \
	) ;\
	for app in $${apps[@]}; do \
		location='/usr/local/Caskroom/'$${app}'/.metadata/' ;\
		if [ ! -d "$${location}" ]; then \
			brew cask install $${app} ;\
			continue ;\
		fi ;\
		current=$$(ls -t $${location} | grep -v "config.json" | head -n 1) ;\
		newest=$$(brew cask info $${app} | head -n 1 | cut -d " " -f 2) ;\
		if [ "$${current}" != "$${newest}" ]; then \
			read -p "$${app} out of date. Update $${current} > $${newest}? [Y|n]: " update ;\
			if [ "$${update:-Y}" == "Y" ]; then \
            	brew cask uninstall $${app} --force ;\
            	brew cask install $${app} ;\
			fi ;\
            continue ;\
		fi ;\
		echo "$${app} up to date" ;\
	done
	echo ${EOK}

	echo ""
	echo "${CB}» Cleanup BREW CASK${CD}"
	brew cleanup
	echo ${EOK}

dotfiles:
	echo "${CB}» Installing DOTFILES${CD}"
	echo "\t${CC}.gitattributes${CD}"	&& cp .gitattributes ~/.gitattributes
	echo "\t${CC}.gitconfig${CD}"		&& cp .gitconfig ~/.gitconfig
	echo "\t${CC}.gitignore${CD}"		&& cp .gitignore ~/.gitignore
	echo "\t${CC}.hammerspoon${CD}"		&& mkdir -p ~/.hammerspoon && cp .hammerspoon ~/.hammerspoon/init.lua
	echo "\t${CC}.inputrc${CD}"			&& cp .inputrc ~/.inputrc
	echo "\t${CC}.nanorc${CD}"			&& cp .nanorc ~/.nanorc
	echo "\t${CC}.profile${CD}"			&& cp .profile ~/.profile
	echo "\t${CC}.psqlrc${CD}"			&& cp .psqlrc ~/.psqlrc
	echo "\t${CC}.vimrc${CD}"			&& cp .vimrc ~/.vimrc
	echo "\t${CC}.zshrc${CD}"			&& cp .zshrc ~/.zshrc
	echo ${EOK}
	echo ""

scripts:
	echo "${CB}» Installing SCRIPTS${CD}"
	echo "\t${CC}django${CD}"			&& curl -s -XGET https://raw.githubusercontent.com/django/django/master/extras/django_bash_completion > /usr/local/etc/bash_completion.d/django_bash_completion
	echo "\t${CC}docker${CD}"			&& curl -s -XGET https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker > /usr/local/etc/bash_completion.d/docker
	echo "\t${CC}docker-compose${CD}"	&& curl -s -XGET https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose > /usr/local/etc/bash_completion.d/docker-compose
	echo "\t${CC}pip${CD}"				&& curl -s -XGET https://raw.githubusercontent.com/ekalinin/pip-bash-completion/master/pip > /usr/local/etc/bash_completion.d/pip
	echo "\t${CC}pyenv${CD}"			&& curl -s -XGET https://raw.githubusercontent.com/yyuu/pyenv/master/completions/pyenv.bash > /usr/local/etc/bash_completion.d/pyenv
	echo ${EOK}
	echo ""

source:
	echo "${CB}» Sourcing DOTFILES${CD}"
	echo "\t${CC}.osx${CD}"				&& /bin/sh -c 'source .osx'
	echo "\t${CC}.iterm${CD}"			&& /bin/sh -c 'source .iterm'
	echo "\t${CC}.profile${CD}"			&& /bin/sh -c 'source ~/.profile'
	echo "\t${CC}.zshrc${CD}"			&& /bin/sh -c 'source ~/.zshrc'
	echo ${EOK}
	echo ""

structure:
	echo "${CB}» Creating directory structure${CD}"
	echo "\t${CC}~/Development${CD}"	&& mkdir -p ~/Development
	echo "\t${CC}~/System${CD}"			&& mkdir -p ~/System
	echo ${EOK}
	echo ""

publish:
	git add .
	git commit -m "-"
	git rebase -i --root
	git push origin master --force
