pipeline {

    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'stg', 'prod'],
            description: 'Choose the Terraform environment'
        )
    }

    environment {
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    terraform init
                '''
            }
        }

        stage('Terraform Workspace') {
            steps {
                sh '''
                    terraform workspace select ${ENV} || terraform workspace new ${ENV}
                    terraform workspace show
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                script {

                    def planStatus = sh(
                        script: """
                            terraform plan \
                            -var-file=${ENV}.tfvars \
                            -out=tfplan 2>&1 | tee terraform-plan.log
                        """,
                        returnStatus: true
                    )

                    if (planStatus != 0) {
                        error("Terraform Plan failed")
                    }
                }
            }
        }

        stage('Approval') {
            steps {
                input(
                    message: "Terraform plan is ready. Do you want to APPLY ${ENV}?",
                    ok: "Approve and Apply"
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    terraform apply -auto-approve tfplan
                '''
            }
        }
    }

    post {

        success {
            emailext(
                subject: "SUCCESS: Terraform ${ENV} - Build #${BUILD_NUMBER}",
                body: """
Terraform deployment completed successfully.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Terraform Apply: SUCCESS

Jenkins URL:
${BUILD_URL}
                """,
                to: "Yousramamdouh1405@gmail.com"
            )
        }

        failure {
            script {

                def reason = "Unknown failure"

                if (fileExists('terraform-plan.log')) {
                    reason = readFile('terraform-plan.log')
                }

                emailext(
                    subject: "FAILED: Terraform ${ENV} - Build #${BUILD_NUMBER}",
                    body: """
Terraform deployment FAILED.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Failure Reason:
${reason}

Check the complete Jenkins console output here:

${BUILD_URL}console
                    """,
                    to: "Yousramamdouh1405@gmail.com"
                )
            }
        }

        aborted {
            emailext(
                subject: "ABORTED: Terraform ${ENV} - Build #${BUILD_NUMBER}",
                body: """
Terraform deployment was ABORTED.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}

The deployment was stopped before completion.

Jenkins URL:
${BUILD_URL}console
                """,
                to: "Yousramamdouh1405@gmail.com"
            )
        }
    }
}
