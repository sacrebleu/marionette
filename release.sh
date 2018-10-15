#!/usr/bin/env bash
# build and release a new deployment of marionette to the marionette ECS registry in nexmo-dev
IMAGE=marionette

while getopts ":r:d" opt; do
  case $opt in
    r)
      # echo "-ra was triggered, Parameter: $OPTARG" >&2
      REPO=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    d)
      DEPLOY=1
      ;;   
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z "${REPO}" ]]; then
    echo "REPO not specified with -r."
    exit 1
fi


version=`cat .version`

if [[ -z "${version}" ]]; then
    echo "Could not determine version, aborting."
    exit 1
fi

echo "version: $version"
docker build . -t $version\
docker tag $IMAGE:$version $IMAGE:latest 

git add -A
git commit -m "Release version $version"
git tag -a "$version" -m "version $version"
git push
git push --tags

docker tag $IMAGE:latest $REPO/$IMAGE:latest
docker tag $IMAGE:$version $REPO/$IMAGE:$version 
docker push $REPO/$IMAGE:latest
docker push $REPO/$IMAGE:$version

echo "Release ${REPO}/${IMAGE} version $version built and pushed"

if [[ -n "${DEPLOY}" ]]; then
  echo "Initiating deployment to kubernetes cluster"
  kubectl set image deployment/$image image=image:$version --record

  kubectl rollout status deployment/nginx-deployment
fi