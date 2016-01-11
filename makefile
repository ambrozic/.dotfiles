.SILENT: setup install update dotfiles scripts source structure publish

CS := \033[1;30m
CR := \033[1;31m
CG := \033[1;32m
CB := \033[1;34m
CC := \033[1;36m
CD := \033[0m
HOMEBREW_ROOT := "/usr/local"
ifeq ($(shell arch), arm64)
	HOMEBREW_ROOT := "/opt/homebrew"
endif


help:
	#
	# Usage: make COMMAND
	#   make setup
	#   make install
	#   make update
	#   make dotfiles
	#   make scripts
	#   make source
	#   make structure
	#   make publish
	#

setup:
	echo "${CB}» Installing OS Manager${CD}"
	cp osm /usr/local/bin/ && chmod +x /usr/local/bin/osm

install:
	echo "${CS}Started on $$(date "+%F %T")${CD}"

	echo ""
	echo "${CB}» Installing xcode${CD}"
	if ! command -v xcode-select &> /dev/null; then \
		xcode-select --install || true ;\
	fi ;\

	echo ""
	echo "${CB}» Installing brew${CD}"
	if ! command -v brew &> /dev/null; then \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > /tmp/brew.installer && /bin/bash /tmp/brew.installer || true ;\
	fi ;\

	echo ""
	echo "${CS}Finished on $$(date "+%F %T")${CD}"

update:
	echo "${CS}Started on $$(date "+%F %T")${CD}"

	echo ""
	echo "${CB}» Updating brew${CD}"
	brew tap homebrew/cask-fonts
	brew tap homebrew/cask-versions
	brew update
	brew upgrade

	echo ""
	echo "${CB}» Installing binaries${CD}"
	binaries=( \
		bash \
		colima \
		diff-so-fancy \
		docker \
		docker-compose \
		dust \
		duti \
		git \
		htop \
		httpie \
		jq \
		libpq \
		m1ddc \
		nano \
		openjdk \
		pyenv \
		pyenv-virtualenv \
		rename \
		svn \
		tldr \
		tree \
		watch \
		zlib \
		zsh \
		zsh-autosuggestions \
		zsh-syntax-highlighting \
		koekeishiya/formulae/skhd \
		koekeishiya/formulae/yabai \
	) ;\
	for binary in $${binaries[@]}; do \
		brew install $${binary} ;\
	done ;\

	echo ""
	echo "${CB}» Installing applications${CD}"
	applications=( \
		alt-tab \
		betterdisplay \
		bitwarden \
		datagrip \
		dropbox \
		firefox \
		fleet \
		font-source-code-pro \
		font-source-sans-pro \
		freecad \
		github \
		google-chrome \
		iina \
		intellij-idea \
		iterm2 \
		krita \
		obsidian \
		pycharm \
		skype \
		stats \
		sublime-text \
		transmission \
		visual-studio-code \
		xquartz \
	) ;\
	for application in $${applications[@]}; do \
		location="${HOMEBREW_ROOT}/Caskroom/"$${application}"/.metadata/" ;\
		if [ ! -d "$${location}" ]; then \
			echo "$${application} is missing, installing" ;\
			brew install --cask $${application} ;\
			continue ;\
		fi ;\
		current=$$(ls -t $${location} | grep -v "config.json" | head -n 1) ;\
		newest=$$(brew info --cask $${application} | head -n 1 | cut -d " " -f 3) ;\
		if [ "$${current}" != "$${newest}" ]; then \
			read -p "$${application} out of date. Update $${current} > $${newest}? [Y|n]: " update ;\
			if [ "$${update:-Y}" == "Y" ]; then \
				brew uninstall --cask $${application} --force ;\
				brew install --cask $${application} ;\
			fi ;\
			continue ;\
		fi ;\
		echo "$${application} is up to date" ;\
	done ;\

	echo ""
	echo "${CB}» Installing python${CD}"
	pythons=( \
		3.11.6 \
		3.12.0 \
	) ;\
	for python in $${pythons[@]}; do \
		echo "  ${CC}$${python}${CD}" ;\
		pyenv install $${python} --skip-existing ;\
	done ;\

	echo ""
	echo "${CB}» Cleanup brew${CD}"
	brew cleanup -s
	brew autoremove
	brew doctor || true

	echo ""
	echo "${CS}Finished on $$(date "+%F %T")${CD}"

dotfiles:
	echo "${CB}» Installing dotfiles${CD}"
	echo "  ${CC}.gitattributes${CD}"	&& mkdir -p ~/.config/git	&& cp .gitattributes ~/.config/git/attributes
	echo "  ${CC}.gitconfig${CD}"		&& mkdir -p ~/.config/git	&& cp .gitconfig ~/.config/git/config
	echo "  ${CC}.gitignore${CD}"		&& mkdir -p ~/.config/git	&& cp .gitignore ~/.config/git/ignore
	echo "  ${CC}.nanorc${CD}"			&& mkdir -p ~/.config/nano	&& cp .nanorc ~/.config/nano/nanorc
	echo "  ${CC}.skhdrc${CD}"			&& mkdir -p ~/.config/skhd	&& cp .skhdrc ~/.config/skhd/skhdrc
	echo "  ${CC}.yabairc${CD}"			&& mkdir -p ~/.config/yabai && cp .yabairc ~/.config/yabai/yabairc
	echo "  ${CC}.pdbrc${CD}"			&& cp .pdbrc ~/.pdbrc.py
	echo "  ${CC}.psqlrc${CD}"			&& cp .psqlrc ~/.psqlrc
	echo "  ${CC}.vimrc${CD}"			&& cp .vimrc ~/.vimrc
	echo "  ${CC}.zshrc${CD}"			&& cp .zshrc ~/.zshrc

scripts:
	echo "${CB}» Installing scripts${CD}"
	echo "  ${CC}kubectl${CD}"			&& kubectl completion zsh > ${HOMEBREW_ROOT}/share/zsh/site-functions/_kubectl
	echo "  ${CC}pip${CD}"				&& pip3 completion --zsh > ${HOMEBREW_ROOT}/share/zsh/site-functions/_pip
	echo "  ${CC}pyenv${CD}"			&& curl -s -XGET https://raw.githubusercontent.com/pyenv/pyenv/master/completions/pyenv.zsh > ${HOMEBREW_ROOT}/share/zsh/site-functions/_pyenv

source:
	echo "${CB}» Sourcing dotfiles${CD}"
	echo "  ${CC}.osx${CD}"				&& /bin/sh -c "source .osx"
	echo "  ${CC}.iterm${CD}"			&& /bin/sh -c "source .iterm"
	echo "  ${CC}.zshrc${CD}"			&& /bin/zsh -c "source ~/.zshrc"

structure:
	echo "${CB}» Creating directory structure${CD}"
	echo "  ${CC}~/Development${CD}"	&& mkdir -p ~/Development
	echo "  ${CC}~/Files${CD}"			&& mkdir -p ~/Files
	echo "  ${CC}~/Music${CD}"			&& mkdir -p ~/Music
	echo "  ${CC}~/System${CD}"			&& mkdir -p ~/System

publish:
	echo "${CB}» Publishing to github${CD}"
	git add .
	git commit -m "-"
	git rebase -i --root
	git push origin master --force
