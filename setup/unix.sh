printf "\033[0;32m"
echo "Installing dependencies..."
echo "This might take a few moments depending on your internet speed."

while read -r line; do
    eval "$line"
done < "setup/list.haxelib"

echo "Finished!"