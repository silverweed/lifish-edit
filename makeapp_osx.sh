#!/bin/bash
# Create a Mac OSX app bundle.
# MUST be launched from the lifish directory
# The lifish executable MUST already exist.

APPNAME=LifishEdit
EXE=lifish-edit
MACOS=($EXE)
DYLIBS=(foreign/{libnfd-mac.so,Darwin/libvoidcsfml-{graphics,audio,system}.dylib})
RESOURCES=(res)
FRAMEWORK_PATH=/Library/Frameworks
FRAMEWORKS=(SFML.framework)

# Ensure all due resources are here
for i in ${MACOS[@]} ${RESOURCES[@]} ${DYLIBS[@]}; do
	[[ -e $i ]] || {
		echo "$i not found in this directory." >&2
		exit 1
	}
done

for i in ${FRAMEWORKS[@]}; do
	[[ -d "$FRAMEWORK_PATH/$i" ]] || {
		echo "$i not found in $FRAMEWORK_PATH". >&2
		exit 1
	}
done

set -x

rm -rf "$APPNAME.app"

# Create the bundle structure
mkdir -p "$APPNAME.app"/Contents/{MacOS,Resources,Frameworks}

# Inject frameworks
for i in ${FRAMEWORKS[@]}; do
	cp -R "$FRAMEWORK_PATH/$i" "$APPNAME.app"/Contents/Frameworks/.
done

# Create info.plist
cat > "$APPNAME.app"/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleExecutable</key>
        <string>lifish-edit</string>
        <key>CFBundleIdentifier</key>
        <string>github.com/silverweed/lifish-edit</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>0.0</string>
        <key>CFBundleName</key>
        <string>lifish-edit</string>
        <key>CFBundleDisplayName</key>
        <string>LifishEdit</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
	<key>CFBundleIconFile</key>
	<string>LifishEdit.icns</string>
    </dict>
</plist>
EOF

# Copy binaries and resources 
cp -r ${MACOS[@]} "$APPNAME.app"/Contents/MacOS/.
for i in ${DYLIBS[@]}; do
	libpath="$APPNAME.app/Contents/MacOS/$(dirname $i)"
	[[ -d "$libpath" ]] || mkdir -p "$libpath"
	cp "$i" "$libpath"
done
cp -r ${RESOURCES[@]} "$APPNAME.app"/Contents/Resources/.
cp osx/Lifish.icns Lifish.app/Contents/Resources/.

pushd "$APPNAME.app"/Contents/MacOS

# FIXME
# Hack to ensure things are installation-independent
DYN=$(otool -L $EXE | tail -n+2 | awk '{print $1}' | egrep -v '^(/usr|/Library|/System)')
for i in $DYN; do
	# Should only have found "our" libraries: check if they're all in DYLIBS array
	found=0
	for dy in ${DYLIBS[@]}; do 
		[[ $(basename $dy) == $(basename $i) ]] && {
			found=1
			break
		}
	done
	[[ $found == 1 ]] || {
		echo "Found unexpected library $i in ones to be relocated!" >&2
		exit 1
	}
	install_name_tool -change "$i" "@executable_path/${i#@rpath}"
done
