resource "aws_ssm_document" "run_locust_test" {
    name            = "Meena-RunLocustTest"
    document_type   = "Command"
    document_format ="JSON"
    target_type     ="/AWS::EC2:Instance"

    content =<<DOC
    {
        "schemaVersion": "2.2",
        "description": "Run performance test using Locust infrastructure",
        "parameters": {
            "locustFile": {
                "type": "String",
                "description": "Path to the locust file including 'locustfiles/'"
            },
            "locustFileTest": {
                "type": "StringMap",
                "description": "Path to the locust file including 'locustfiles/'",
                "default":{
                    "locustfile/Onboarding/Onboarding.py":"100",
                    "locustfile/CustomerProfile/CustomerProfile.py":"100"
                },
                "maxItems":"25"
            },
            "workers":{
                "type": "String",
                "description": "How many worker nodes to use"
            },
            "users": {
                "type": "String",
                "description": "Number of concurrent users"
            },
            "spawnRate":{
                "type": "String",
                "description": "The rate per second in which the users are spawned"
            },
            "stopTimeout": {
                "type": "String",
                "description": "Timeout before exiting after completing"
            },
            "runTime":{
                "type": "String",
                "description": "Stop after the specified amount of time "
            },
            "additionalTestParameters": {
                "type": "String",
                "description": "Any additional parameters",
                "default": "latest"
            },
            "dockerImageTag": {
                "type": "String",
                "description": "Tag of the performance-test docker image to use"
            },
            "resultBucketName":{
                "type": "String",
                "description": "AWS Bucker name",
                "default": "locust-results-s3-bucket",
                 "allowedValues": ["locust-results-s3-bucket"]
            },
            "awsRegion":{
                "type": "String",
                "description": "Target region",
                "default": "us-east-2",
                 "allowedValues": ["us-east-2"]
            }
        },
        "mainSteps": [
           {
               "action": "aws:runShellScript",
               "name": "runTest",
               "inputs": {
                "timeoutSeconds":"120",
                "runCommand": [${jsonencode(file("/Users/macbookpro/Documents/Meenu/meena_projects/pythonworkspace/learn-terraform-docker-container/run-test.sh"))}]
               }
           }
        ]
    }
    DOC
}