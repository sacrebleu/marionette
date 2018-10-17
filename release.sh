# /usr/bin/env bash

while getopts ":r:" opt; do
  case $opt in
    r)
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

AWS_REGION=${REGION}
AWS_DEFAULT_REGION=${REGION}

IMAGE=marionette

version=`cat .version`
if [[ -z "${version}" ]]; then
    echo "Could not determine version, aborting."
    exit 1
fi

echo "+--- Version checks"
echo "| Docker: $(docker --version)"
echo "| Kubectl: $(kubectl version --short --client)"
echo "| AWS cli: $(aws --version)"

# suppress a legal -e flag that docker no longer supports
docker_login=$(aws ecr get-login --region eu-west-1 | sed 's/ -e none//')
echo "Logging into ECR with ${docker_login}"
eval $docker_login

regversion=$(aws ecr describe-images --registry-id 564623767830  --repository-name marionette --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags' | grep -e [0-9] | sed 's/[ ",]//g')

echo "Git repo version: $version"
echo "Registry latest version: ${regversion}"

if [[ "${version}" = "${regversion}" ]]; then 
  echo "Latest version already exists in registry - did you remember to bump the version?"
  exit 0
fi

docker build . -t $IMAGE:$version
docker tag $IMAGE:$version $IMAGE:latest

echo "Preparing to publish ${IMAGE}:${version} to ${REPO}/${IMAGE}:${version}" 

docker tag $IMAGE:latest $REPO/$IMAGE:latest
docker tag $IMAGE:$version $REPO/$IMAGE:$version
docker push $REPO/$IMAGE:latest
docker push $REPO/$IMAGE:$version

echo "Deploying ${IMAGE}=${REPO}/${IMAGE}:${version} to deployment/${IMAGE}"
kubectl set image deployment/${IMAGE} ${IMAGE}=${REPO}/${IMAGE}:${version} --record && kubectl rollout status deployment/$IMAGE
