#!/bin/bash
# Create a Mac OSX app bundle.
# Must be launched from the lifish-edit directory
# The lifishedit executable must already exist.

APPNAME=LifishEdit
EXE=lifishedit
MACOS=($EXE)
DYLIBS=(foreign/Darwin/{libnfd-mac.so,libvoidcsfml-{graphics,window,system}.2.4.dylib})
RESOURCES=(res)
FRAMEWORK_PATH=/Library/Frameworks
FRAMEWORKS=({ogg,freetype,OpenAL,vorbis{,enc,file},sfml-{window,graphics,system}}.framework)

nstep=1
step() {
	echo "------------------------------" >&2
	echo "* [$nstep] $*..." >&2
	let nstep++
}

# Ensure all due resources are here
for i in ${MACOS[@]} ${RESOURCES[@]} ${DYLIBS[@]}; do
	[[ -e $i ]] || {
		echo "FATAL: $i not found in this directory." >&2
		exit 1
	}
done

for i in ${FRAMEWORKS[@]}; do
	[[ -d "$FRAMEWORK_PATH/$i" ]] || {
		echo "FATAL: $i not found in $FRAMEWORK_PATH". >&2
		exit 1
	}
done

rm -rf "$APPNAME.app"

# Create the bundle structure
step "Creating bundle structure"
mkdir -vp "$APPNAME.app"/Contents/{MacOS,Resources,Frameworks}

# Copy frameworks
step "Copying frameworks"
for i in ${FRAMEWORKS[@]}; do
	echo "  > ${i%.framework}" >&2
	cp -R "$FRAMEWORK_PATH/$i" "$APPNAME.app"/Contents/Frameworks/.
done

# Create info.plist
step "Creating info.plist"
cat > "$APPNAME.app"/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleExecutable</key>
        <string>lifishedit</string>
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
step "Copying binaries"
cp -vr ${MACOS[@]} "$APPNAME.app"/Contents/MacOS/.
for i in ${DYLIBS[@]}; do
	libpath="$APPNAME.app/Contents/MacOS/$(dirname $i)"
	[[ -d "$libpath" ]] || mkdir -vp "$libpath"
	cp -v "$i" "$libpath"
done
step "Copying resources"
cp -vr ${RESOURCES[@]} "$APPNAME.app"/Contents/Resources/.
#cp -v LifishEdit.icns "$APPNAME.app"/Contents/Resources/.

pushd "$APPNAME.app"/Contents/MacOS

## Ensure things are installation-independent
# Libraries to relocate
DYN=(foreign/Darwin/libnfd-mac.so
@rpath/libvoidcsfml-graphics.2.4.dylib 
@rpath/libvoidcsfml-window.2.4.dylib 
@rpath/libvoidcsfml-system.2.4.dylib 
/usr/local/opt/bdw-gc/lib/libgc.1.dylib 
/usr/local/opt/libevent/lib/libevent-2.1.6.dylib
/usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib)

step "Relocating dynamic library paths"
for i in ${DYN[@]}; do
	# If it's one of "our" libraries, just change the dynamic path
	found=0
	for dy in ${DYLIBS[@]}; do 
		a=$(basename $dy)
		b=$(basename $i)
		if [[ $a == $b ]]; then 
			found=$dy
			break
		fi
	done
	if [[ $found != 0 ]]; then
		install_name_tool -change "$i" "@executable_path/$found" "$EXE"
	else
		# Else, copy it and relocate
		cp -v $i foreign
		llib="foreign/$(basename $i)"
		chmod +w $llib
		install_name_tool -id "@executable_path/$llib" $llib
		install_name_tool -change "$i" "@executable_path/$llib" "$EXE"
		for dl in $(otool -L $llib | grep /usr/local); do
			install_name_tool -change $dl "@executable_path/foreign/$(basename $dl)" $llib 
		done
	fi
done

# Finally, inject rpath
popd
step "Injecting rpath"
find "$APPNAME.app" -type f -exec install_name_tool -add_rpath "@executable_path/../Frameworks" {} \; 2>&1 | grep -v "not a Mach-O"
echo "Done!" >&2
