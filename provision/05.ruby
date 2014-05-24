if [ <%- provision.env %> = true ] ; then
	if [[ ! -f "$HOME/.rvm/scripts/rvm" ]]; then
		curl -sSL https://get.rvm.io | bash -s -- --version latest --ruby=1.9.3 --ignore-dotfiles
	fi
fi
