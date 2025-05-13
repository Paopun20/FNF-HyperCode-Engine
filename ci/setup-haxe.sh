set -e

echo "🔧 Setting up Haxe environment..."

haxelib setup ~/haxelib
haxelib install hxcpp --quiet
haxelib install lime --quiet
haxelib install openfl --quiet

chmod +x ./setup/unix.sh
./setup/unix.sh
