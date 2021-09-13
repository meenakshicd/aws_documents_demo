#!/bin/sh

set -eo pipefail
trap '[[ $BASH_COMMAND != echo* ]] && echo $BASH_COMMAND' DEBUG
LOCUST_FILE=({{locustFile}})
WORKERS="{{workers}}"
USERS="{{users}}"
SPAWN_RATE="{{spawnRate}}"
STOP_TIMEOUT="{{stopTimeout}}"
RUN_TIME="{{runTime}}"
ADDITIONAL_TEST_PARAMETERS="{{additionalTestParameters}}"
DOCKER_IMAGE_TAG="{{dockerImageTag}}"
RESULT_BUCKER_NAME="{{resultBucketName}}"
AWS_RESGION="{{awsRegion}}"
#LOCUST_FILE_TEST=echo $locustFileTest

declare -A LOCUST_FILE_TEST=(["locustfile/Onboarding/Onboarding.py"]="100")
LOCUST_FILE_TEST["locustfile/CustomerProfile/CustomerProfile.py"]="03"
echo "${!ADDITIONAL_TEST_PARAMETERS[@]}"
for item in "${!ADDITIONAL_TEST_PARAMETERS[@]}"
do
    echo "$item => ${ADDITIONAL_TEST_PARAMETERS[$item]}"
done

SAFE_LOCUSTFILE_NAME=$(echo $LOCUST_FILE | sed 's/locustfiles\///' | sed 's/\.py//g' | sed 's/[/ ]/-/g')
MASTER_CONTAINER_NAME="locust-master-$SAFE_LOCUSTFILE_NAME"

#MASTER_CONTAINER_ID=$(docker run \
#    --rm \
#    --detach \
#    --name $MASTER_CONTAINER_NAME \
#    --network=host \
#    --env RESULT_BUCKET_NAME=$RESULT_BUCKET_NAME
#    --env AWS_REGION=$AWS_REGION
#    --env TEST_TIMESTAMP=$(date '+%Y/%m/%d/%H-%M-%S') \
#    --env LOCUST_MASTER_BIND_PORT=5557 \
#    --env LOCUST_LOCUSTFILE=$LOCUST_FILE\
#    --env LOCUST_EXPECT_WORKERS=$WORKERS\
#    --env LOCUST_USERS=$USERS\
#    --env LOCUST_SPAWN_RATE=$SPAWN_RATE\
#    --env LOCUST_STOP_TIMEOUT=$STOP_TIMEOUT\
#    --env LOCUST_RUN_TIME=$RUN_TIME\
#
#    $ADDITIONAL_TEST_PARAMETERS)

#for file in "${!locustFileTest[@]}"
#do
#  echo "$file - ${locustFileTest[$file]}";
#  docker run \
#        --rm \
#        -- detach \
#        --name $file \
#        --network=host \
#        --env LOCUST_LOCUSTFILE=$file \
#        --env LOCUST_MASTER_HOST=$(curl http://localhost:8080/latest/meta-data/local-ipv4) \
#        --env LOCUST_MASTER_PORT=5557 \
#done


for WORKER_NUMBER in `seq 1 $WORKERS`
do
    echo "Starting worker $WORKER_NUMBER"

    WORKER_CONTAINER_NAME="locust-worker-$SAFE_LOCUSTFILE_NAME-${MASTER_CONTAINER_ID:0:0}-$WORKER_NUMBER"
#    docker run \
#        --rm \
#        -- detach \
#        --name $WORKER_CONTAINER_NAME \
#        --network=host \
#        --env LOCUST_LOCUSTFILE=$LOCUST_FILE \
#        --env LOCUST_MASTER_HOST=$(curl http://localhost:8080/latest/meta-data/local-ipv4) \
#        --env LOCUST_MASTER_PORT=5557 \
done

keys()
{
    INPUT_DICT=("$@")
    KEYS=()
    for DATA in "${INPUT_DICT[@]}" ; do
        KEYS+=("${DATA%%:*}")
    done
    echo "${KEYS[@]}"
}

values()
{
    INPUT_DICT=("$@")
    VALUES=()
    for DATA in "${INPUT_DICT[@]}" ; do
        VALUES+=("${DATA##*:}")
    done
    echo "${VALUES[@]}"
}

createNodes()
{
    INPUT_DICT=("$@")
    for DATA in "${INPUT_DICT[@]}" ; do
        LOCUST_FILE1="${DATA%%:*}"
        USERS1="${DATA##*:}"
        echo "File: $LOCUST_FILE1"
        echo "User: $USERS1"
        echo "${DATA%%:*}:${DATA##*:}"
    done
}

#echo "KEYS=$(keys "${LOCUST_FILE[@]}")"
#echo "VALUES=$(values "${LOCUST_FILE[@]}")"
createNodes "${LOCUST_FILE[@]}"