#!/usr/bin/env sh
CLIPS_ENV_DIR="$HOME/.clipsenv"
CLIPS_BIN_DIR="$CLIPS_ENV_DIR/bin"
CLIPS_SRC_DIR="$CLIPS_ENV_DIR/src"

CLIPS_COMMAND_AVAILABLE=$(command -v clips)
CURL_COMMAND_AVAILABLE=$(command -v curl)
GIT_COMMAND_AVAILABLE=$(command -v git)

CLIPS_VERSIONS="6.4.1
6.40
6.31
CLIPSockets"

installation_process()
{
	CLIPS_VERSION="$1"
	if [ -d "$CLIPS_BIN_DIR/$1" ]; then
		echo "This CLIPS version is already installed!"
	else
		make -C "$CLIPS_SRC_DIR/$1"
		mkdir -p "$CLIPS_BIN_DIR/$1"
		ln -sf "$CLIPS_SRC_DIR/$1/clips" "$CLIPS_BIN_DIR/$1/clips"
	fi
}

download_process()
{
	CLIPS_VERSION="$1"
	if [ "$CLIPS_VERSION" = "CLIPSockets" ]; then
		if [ -n "$GIT_COMMAND_AVAILABLE" ]; then
			git clone "https://github.com/mrryanjohnston/CLIPSockets" "$CLIPS_SRC_DIR/CLIPSockets"
		else
			echo "Need git to download CLIPSockets source code. Exiting..."
			exit
		fi
	elif [ -n "$CLIPS_VERSION" ] && [ -d "$CLIPS_SRC_DIR/$CLIPS_VERSION" ]; then
		echo "Source code for $CLIPS_VERSION already on system..."
	elif [ -n "$CLIPS_VERSION" ]; then
		CLIPS_TAR_FILE="clips_core_source_$(echo "$CLIPS_VERSION" | tr -d '.').tar.gz"
		CLIPS_SRC_URL="https://sourceforge.net/projects/clipsrules/files/CLIPS/$CLIPS_VERSION/$CLIPS_TAR_FILE"
		echo "$CLIPS_SRC_URL"
		if [ -n "$CURL_COMMAND_AVAILABLE" ]; then
			curl -L -o "$CLIPS_SRC_DIR/$CLIPS_TAR_FILE" "$CLIPS_SRC_URL"
		elif [ -n "$WGET_COMMAND_AVAILABLE" ]; then
			wget -P "$CLIPS_SRC_DIR" "$CLIPS_SRC_URL"
		else
			echo "Need curl or wget to download CLIPS source code. Exiting..."
			exit
		fi
		mkdir -p "$CLIPS_SRC_DIR/$CLIPS_VERSION"
		tar --strip-components=2 -xvf "$CLIPS_SRC_DIR/$CLIPS_TAR_FILE" -C "$CLIPS_SRC_DIR/$CLIPS_VERSION"
	else
		echo "Invalid selection. Use (ctrl + c) to exit anytime. Otherwise, let's continue..."
	fi
}

display_global_prompt()
{
	echo "$CURRENTLY_INSTALLED_BINARIES" | nl
	read -p "Which?: " REPLY
	CLIPS_VERSION="$(echo "$CURRENTLY_INSTALLED_BINARIES" | sed -n "$REPLY"p | xargs basename)"
	ln -s "$CLIPS_BIN_DIR/clips" "$CLIPS_BIN_DIR/$CLIPS_VERSION/clips"
	echo "Done! Exit any time with (ctrl + c). Otherwise, let's continue..."
}

display_installation_prompt()
{
	echo "$CLIPS_VERSIONS" | nl
	read -p "Which?: " REPLY
	CLIPS_VERSION=$(echo "$CLIPS_VERSIONS" | sed -n "$REPLY"p)
	download_process "$CLIPS_VERSION"
	installation_process "$CLIPS_VERSION"
	read -p "Installed! Want to point the global clips command to this newly installed binary? (Y/n): " REPLY
	if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "" ]; then
		ln -sf "$CLIPS_BIN_DIR/$CLIPS_VERSION/clips" "$CLIPS_BIN_DIR/clips"
		echo "Done!"
	else
		echo "Ok."
	fi
	echo "Use (ctrl + c) to exit anytime. Otherwise, let's continue..."
}

display_uninstallation_prompt()
{
	CURRENTLY_AVAILABLE_BINARIES="$(ls -rd "$CLIPS_BIN_DIR"/*/ 2> /dev/null)"
	echo "$CURRENTLY_AVAILABLE_BINARIES" | nl
	read -p "Which?: " REPLY
	CLIPS_VERSION_IN_AVAILABLE_BINARIES=$(echo "$CURRENTLY_AVAILABLE_BINARIES" | sed -n "$REPLY"p)
	if [ -z "$CLIPS_VERSION_IN_AVAILABLE_BINARIES" ]; then
		echo "Invalid selection. Use (ctrl + c) to exit anytime. Otherwise, let's continue..."
		return
	fi
	rm -rf "$CLIPS_VERSION_IN_AVAILABLE_BINARIES"
	read -p "Uninstalled! Want to purge the source files, as well? (Y/n): " REPLY
	if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "" ]; then
		CURRENTLY_AVAILABLE_SOURCE="$(ls -rd "$CLIPS_SRC_DIR"/*/ 2> /dev/null)"
		CLIPS_VERSION_IN_AVAILABLE_SOURCE=$(echo "$CURRENTLY_AVAILABLE_SOURCE" | sed -n "$REPLY"p)
		if [ -z "$CLIPS_VERSION_IN_AVAILABLE_SOURCE" ]; then
			echo "Source directory wasn't there. Something is wrong. Exiting..."
			exit
		fi
		rm -rf "$CLIPS_VERSION_IN_AVAILABLE_SOURCE"
		echo "Done!"
	else
		echo "Ok."
	fi
}

display_clone_prompt()
{
	CURRENTLY_AVAILABLE_SOURCE="$(ls -rd "$CLIPS_SRC_DIR/*/" 2> /dev/null)"
	echo "$CLIPS_VERSIONS\n$CURRENTLY_AVAILABLE_SOURCE" | nl
	read -p "Which?: " REPLY
	CLIPS_VERSION_IN_AVAILABLE_SOURCE=$(echo "$CLIPS_AVAILABLE_SOURCE" | sed -n "$REPLY"p)
	if [ -z "$CLIPS_VERSION_IN_AVAILABLE_SOURCE" ] && [ -n "$CLIPS_VERSION" ]; then
		download_process "$CLIPS_VERSION"
	fi
}

echo "   _____ _      _____ _____   _____                 "
echo "  / ____| |    |_   _|  __ \ / ____|                "
echo " | |    | |      | | | |__) | (___   ___ _ ____   __"
echo " | |    | |      | | |  ___/ \___ \ / _ \ '_ \ \ / /"
echo " | |____| |____ _| |_| |     ____) |  __/ | | \ V / "
echo "  \_____|______|_____|_|    |_____/ \___|_| |_|\_/ "
echo "CLIPSenv: A Version Manager for CLIPS"

if [ "$CLIPS_COMMAND_AVAILABLE" ]; then
	case "$CLIPS_COMMAND_AVAILABLE" in
		"$CLIPS_BIN_DIR/"*) ;;
		*) echo "WARNING: clips command found, but it is not managed by CLIPSenv!";;
	esac
fi


CONTINUE=true
while "$CONTINUE"
do

	CURRENTLY_INSTALLED_BINARIES="$(ls -rd "$CLIPS_BIN_DIR"/*/ 2> /dev/null)"
	CURRENTLY_AVAILABLE_SOURCE="$(ls -rd "$CLIPS_SRC_DIR"/*/ 2> /dev/null)"
	if [ -L "$CLIPS_BIN_DIR/clips" ] && [ ! -e "$CLIPS_BIN_DIR/clips" ]; then
		echo "clips global command is not linked to an existing file."
		if [ -n "$CURRENTLY_INSTALLED_BINARIES" ]; then
			read -p "Want to update the global clips command to point it to an installed binary on the system? (Y/n): " REPLY
			if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "" ]; then
				display_global_prompt
			fi
		else
			read -p "There are no installed binaries on this system. Want to just delete it? (Y/n): " REPLY
			if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "" ]; then
				rm "$CLIPS_BIN_DIR/clips"
				echo "Done! Exit any time with (ctrl + c). Otherwise, let's continue..."
			fi
			
		fi
	elif [ ! -L "$CLIPS_BIN_DIR/clips" ] && [ -n "$CURRENTLY_INSTALLED_BINARIES" ]; then
		echo "$CLIPS_BIN_DIR/clips is not present, but there are installed binaries"
		read -p "Want to make a link the global clips command to an installed binary on the system? (Y/n): " REPLY
		if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "" ]; then
			display_global_prompt
		fi
	elif [ -z "$CURRENTLY_INSTALLED_BINARIES" ]; then
		read -p "Do you want to (i)nstall or (c)lone a base as a new install? (i/c): " REPLY
		if [ "$REPLY" -eq "i" ]; then
			display_installation_prompt
		elif [ "$REPLY" -eq "c" ]; then
			display_clone_prompt
		else
			echo "Option not recognized. Exit any time with (ctrl + c). Otherwise, let's continue..."
		fi
	elif [ -n "$CURRENTLY_INSTALLED_BINARIES" ]; then 
		read -p "Do you want to (i)nstall, (u)ninstall, or (c)lone a base as a new install? Or set the (g)lobal CLIPS command? (i/u/c/g): " REPLY
		if [ "$REPLY" = "i" ]; then
			display_installation_prompt
		elif [ "$REPLY" = "u" ]; then
			display_uninstallation_prompt
		elif [ "$REPLY" = "c" ]; then
			display_clone_prompt
		elif [ "$REPLY" = "g" ]; then
			display_clone_prompt
		else
			echo "Option not recognized. Exit any time with (ctrl + c). Otherwise, let's continue..."
		fi
	fi
done
