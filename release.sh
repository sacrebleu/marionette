while getopts ":r:pd" opt; do
  case $opt in
    r)
      # echo "-ra was triggered, Parameter: $OPTARG" >&2
      REPO=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    p)
      PACKAGE=1
      ;;
    d)
      DEPLOY=1
      ;;
    *)
      echo "Unknown argument $opt"
      exit 1
      ;;  
  esac
done

if [[ -z "${REPO}" ]]; then
    echo "REPO not specified with -r."
    exit 1
fi

IMAGE=marionette

version=`cat .version`
if [[ -z "${version}" ]]; then
    echo "Could not determine version, aborting."
fi

echo "version: $version"

if [[ -n "${PACKAGE}" ]]; then 
  echo "packaging $REPO/$IMAGE:$version"

  docker build . -t $IMAGE:$version
  docker tag $IMAGE:$version $IMAGE:latest

  # tag it
  pushd .

  git add -A
  git commit -m "Release version $version"
  git tag -a "$version" -m "version $version"
  git push
  git push --tags

  docker tag $IMAGE:latest $REPO/$IMAGE:latest
  docker tag $IMAGE:$version $REPO/$IMAGE:$version
  docker push $REPO/$IMAGE:latest
  docker push $REPO/$IMAGE:$version
fi

if [[ -n "${DEPLOY}" ]]; then
  echo "Deploying ${IMAGE}=${REPO}/${IMAGE}:${version} to deployment/${IMAGE}"
  kubectl set image deployment/${IMAGE} ${IMAGE}=${REPO}/${IMAGE}:${version} --record && kubectl rollout status deployment/$IMAGE
fi 