set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
IMAGE=marionette

# ensure we're up to date
git pull

# bump version
docker run --rm -v "$PWD":/app marionette/bump patch
version=`cat ../.version`
echo "version: $version"
# run build
./build.sh
# tag it
cd ..

git add -A
git commit -m "Release version $version"
git tag -a "$version" -m "version $version"
git push
git push --tags
docker tag marionette/$IMAGE:latest $USERNAME/$IMAGE:$version
# push it
docker push $USERNAME/$IMAGE:latest
docker push $USERNAME/$IMAGE:$version