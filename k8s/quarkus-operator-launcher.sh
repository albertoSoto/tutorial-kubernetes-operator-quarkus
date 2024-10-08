#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

GROUP_ID="info.magnolia.k8s"
PROJECT_ID="quarkus-operator-demo"
DISABLE_FOLDER_NAVIGATION="n"

browse_directory() {
  if [ "$DISABLE_FOLDER_NAVIGATION" != "y" ]; then
    cd "$1" || exit
  fi
}

browse_back() {
  if [ "$DISABLE_FOLDER_NAVIGATION" != "y" ]; then
    cd ..
  fi
}

while true; do
  echo "--------------------------------------------------------------"
  echo " Quarkus operator setup"
  echo "--------------------------------------------------------------"
  echo "Choose what do you wanna do:"
  echo "   0 - Install quarkus CLI"
  echo "   1 - Install local docker registry"
  echo "   2 - Setup project & organization name"
  echo "   3 - Generate quarkus operator project"
  echo "   4 - Project dev"
  echo "   5 - Compile the project"
  echo "   6 - Generate docker image and publish locally"
  echo "   7 - deploy to current kubernetes cluster"
  echo "   8 - Disable folder navigation"
  echo "   n - none"
  echo "--------------------------------------------------------------"

  read -p "Which option do you wanna trigger? " userOption
  case $userOption in
    0 )
      echo "-->   0 - Install quarkus CLI"
      brew install quarkusio/tap/quarkus
      quarkus --version
      ;;
    1 )
      echo "-->   1 - Install local docker registry"
      docker run -d -p 5001:5000 --name registry registry:latest
      docker logs -f registry
      ;;
    2 )
      echo "-->   2 - Setup project & organization name"
      read -p "Enter the group ID (e.g., info.magnolia.k8s): " GROUP_ID
      read -p "Enter the project ID (e.g., quarkus-operator-demo): " PROJECT_ID
      echo "GROUP_ID set to: $GROUP_ID"
      echo "PROJECT_ID set to: $PROJECT_ID"
      ;;
    3 )
      echo "-->   3 - Generate quarkus operator project"
      quarkus create app "$GROUP_ID:$PROJECT_ID" -x='qosdk,olm'
      ;;
    4 )
      echo "-->   4 - Project dev"
      browse_directory "$PROJECT_ID"
      quarkus dev
      browse_back
      ;;
    5 )
      echo "-->   5 - Compile the project"
      browse_directory "$PROJECT_ID"
      mvn clean package -Dquarkus.container-image.build=true -Dquarkus.container-image.registry=localhost:5001 -Dquarkus.container-image.group='' -Dquarkus.container-image.name="$PROJECT_ID" -Dquarkus.container-image.tag=latest
      browse_back
      ;;
    6 )
      echo "-->   6 - Generate docker image and publish locally"
      browse_directory "$PROJECT_ID"
      docker build -t "$PROJECT_ID" -f ./src/main/docker/Dockerfile.jvm .
      docker tag "$PROJECT_ID":latest localhost:5001/"$PROJECT_ID":latest
      docker push localhost:5001/"$PROJECT_ID":latest
      browse_back
      ;;
    7 )
      echo "-->   7 - deploy to current kubernetes cluster"
      browse_directory "$PROJECT_ID"
      kubectl apply -f ./target/kubernetes/kubernetes.yml
      browse_back
      ;;
    8 )
      echo "-->   8 - Disable folder navigation"
      read -p "Do you want to disable folder navigation? (y/n): " DISABLE_FOLDER_NAVIGATION
      ;;
    [Nn]* )
      echo "Exiting..."
      break ;;
    * )
      echo "Invalid option. Please choose a valid option." ;;
  esac
done

echo "Rabbit cluster operator CLI finished"
