#!/bin/bash

set -ex
set -o pipefail

declare_env_variables() {

  # Declaring environment variables
  #
  # Some environment variables assigned externally are:
  # CIRCLE_TOKEN : This is the API token that is provided for the CircleCI user. Used for accessing artifacts
  # SLACK_CHANNEL_HOOK : This is the webhook for the Slack App where notifications will be sent from
  # DEPLOYMENT_CHANNEL : This is the channel on which the Slack notifications will be posted
  # QEMU_AUDIO_DRV : This will set the Android emulator used for integration tests to have no audio


  # Retrieving the urls for the CircleCI artifacts

  CIRCLE_ARTIFACTS_URL="$(curl https://circleci.com/api/v1.1/project/github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}/artifacts?circle-token=${CIRCLE_TOKEN} | grep -o 'https://[^"]*')"

  # Assigning slack messages based on the CircleCI job name

  if [ "$CIRCLE_JOB" == 'lint' ]; then

    # Sorting through the artifact urls to get only the lint reports

    CIRCLE_REPORT_ARTIFACTS="$(echo $CIRCLE_ARTIFACTS_URL | sed -E -e 's/[[:blank:]]+/\
/g' |  grep '\.html')"
    CIRCLE_ARTIFACTS_MESSAGE="Lint Phase Failed! :crying_cat_face: \n Get the lint reports here: \n ${CIRCLE_REPORT_ARTIFACTS}"

  elif [ "$CIRCLE_JOB" == 'test' ]; then

    # Sorting through the artifact urls to get only the unit test and integration test reports

    CIRCLE_REPORT_ARTIFACTS="$(echo $CIRCLE_ARTIFACTS_URL | sed -E -e 's/[[:blank:]]+/\
/g' |  grep 'index\.html')"
    INTEGRATION_REPORT="$(echo $CIRCLE_ARTIFACTS_URL | sed -E -e 's/[[:blank:]]+/\
/g' |  grep 'AVD')"
    CIRCLE_ARTIFACTS_MESSAGE="Test Phase Failed! :scream: \n Get the test reports here: \n ${CIRCLE_REPORT_ARTIFACTS} \n ${INTEGRATION_REPORT}"

  elif [ "$CIRCLE_JOB" == 'deploy_test_build' ]; then
    CIRCLE_ARTIFACTS_MESSAGE="Test Build for Deployment Failed! :scream: \n Get the build reports here:  \n ${CIRCLE_REPORT_ARTIFACTS}"

  elif [ "$CIRCLE_JOB" == 'deploy_staging_build' ]; then
    CIRCLE_ARTIFACTS_MESSAGE="Staging Build for Deployment Failed! :scream: \n Get the build reports here:  \n ${CIRCLE_REPORT_ARTIFACTS}"

  elif [ "$CIRCLE_JOB" == 'deploy_production_build' ]; then
    CIRCLE_ARTIFACTS_MESSAGE="Production Build for Deployment Failed! :scream: \n Get the build reports here:  \n ${CIRCLE_REPORT_ARTIFACTS}"

  else
    CIRCLE_ARTIFACTS_MESSAGE="Unknown job failed"
  fi

  # Some template for the Slack message

  COMMIT_LINK="https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/commit/${CIRCLE_SHA1}"
  IMG_TAG="$(git rev-parse --short HEAD)"
  CIRCLE_WORKFLOW_URL="https://circleci.com/workflow-run/${CIRCLE_WORKFLOW_ID}"
  SLACK_DEPLOYMENT_TEXT="CircleCI Build <$CIRCLE_WORKFLOW_URL|#$CIRCLE_BUILD_NUM> \n Branch: $CIRCLE_BRANCH \n Executed Git Commit <$COMMIT_LINK|${IMG_TAG}> by ${CIRCLE_USERNAME} \n ${CIRCLE_ARTIFACTS_MESSAGE}"
}

send_notification() {

  # Sending the Slack notification

  curl -X POST --data-urlencode \
  "payload={
      \"channel\": \"${DEPLOYMENT_CHANNEL}\", 
      \"username\": \"DeployNotification\", 
      \"text\": 
      \"${SLACK_DEPLOYMENT_TEXT}\", 
      \"icon_emoji\": \":rocket:\"}" \
  "${SLACK_CHANNEL_HOOK}"  
}

main() {
  echo "Declaring environment variables"
  declare_env_variables

  echo "Sending notification"
  send_notification

}

main "$@"
