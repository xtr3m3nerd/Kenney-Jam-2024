#!/bin/bash
set -e
cd "$(dirname "$0")"

ITCH_USER="cranberryninja"
ITCH_PAGE="dungeon-light"
GAMENAME="dungeon_light"

declare -A html

html[dir]="./html"
html[build]="Web"
html[exe]="./build/html/index.html"
html[zip]="${GAMENAME}_html.zip"
html[deploy]="${ITCH_USER}/${ITCH_PAGE}:html5"

declare -A linux

linux[dir]="./linux"
linux[build]="Linux/X11"
linux[exe]="./build/linux/${GAMENAME}.x86-64"
linux[zip]="${GAMENAME}_linux.zip"
linux[deploy]="${ITCH_USER}/${ITCH_PAGE}:linux"

declare -A windows

windows[dir]="./windows"
windows[build]="Windows Desktop"
windows[exe]="./build/windows/${GAMENAME}.exe"
windows[zip]="${GAMENAME}_windows.zip"
windows[deploy]="${ITCH_USER}/${ITCH_PAGE}:win"

builds=(html linux windows)
#builds=(html)

deploy=false

while getopts ":D" opt;
do
	case $opt in
		D)
			deploy=true
			;;
		?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done

rm -f ./*.zip
for build_type in "${builds[@]}"
do
	declare -n build_ref="$build_type"

	echo "Clean directory ${build_ref[dir]}"
	mkdir -p "${build_ref[dir]}"
	rm -f "${build_ref[dir]}/*"
	cat << EOF > "${build_ref[dir]}/.gitignore"
# Ignore everything in this directory
*
# Except this file
!.gitignore
EOF
	echo "Build"
	cd ..
	godot-engine --headless --export-debug "${build_ref[build]}" "${build_ref[exe]}"
	cd build

	echo "Zip"
	cd "${build_ref[dir]}"
	zip -r "../${build_ref[zip]}" ./* -x "./.gitignore"
	cd ..

	if $deploy; then
		echo "Deploy"
		butler push "${build_ref[zip]}" "${build_ref[deploy]}"
	fi
done
