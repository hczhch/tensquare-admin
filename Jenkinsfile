def harborUrl = "harbor.zhch.lan"
def harborAuth = "7e2f3356-45b3-4d89-b727-967569d5c2ae"
def harborProject = "tensquare-front"

def gitUrl = "git@git.zhch.lan:test/tensquareadmin.git"
def gitAuth = "4488bfb8-2d68-4419-a79e-ccbb9928c3fe"

def projectName = "tensquare-front"
def version = new Date().format("yyyy.MMdd.HHmmss", TimeZone.getTimeZone('Asia/Shanghai'))
def workDir = "/root/docker/build"
def contextPath = "${workDir}/${projectName}/${version}"

node {
    stage('Clone') {
        echo "Create contextPath: ${contextPath}"
        sh "mkdir -p ${contextPath}"
        dir("${contextPath}") {
            echo "Checkout start"
            checkout scmGit(branches: [[name: '*/${BRANCH_NAME}']], extensions: [], userRemoteConfigs: [[credentialsId: "${gitAuth}", url: "${gitUrl}"]])
            echo "Checkout done."
        }
    }

    stage('Build') {
        dir("${contextPath}") {
            nodejs('nodejs12') {
                sh '''
                    npm install
                    npm run build
                '''
            }
        }
    }

    def containerName = "${projectName}-${BRANCH_NAME}"
    def image = "${harborUrl}/${harborProject}/${containerName}:${version}"
    stage('Create image') {
        dir("${contextPath}") {
            sh "docker build -t ${image} ."

            // 登录 harbor
            withCredentials([usernamePassword(credentialsId: "$harborAuth", passwordVariable: 'PASSWD', usernameVariable: 'UNAME')]) {
                sh "echo $PASSWD | docker login -u $UNAME --password-stdin $harborUrl"
            }
            // 推送镜像
            sh "docker push ${image}"

            // 删除本地镜像
            sh "docker rmi ${image}"
        }
    }

    stage('Publish') {
        dir("${contextPath}") {
            //获取当前选择的服务器名称
            def selectedHosts = "${HOST_NAME}".split(",")
            // 部署
            for(int j=0; j<selectedHosts.length; j++){
                def host = selectedHosts[j]
                sshPublisher(publishers: [sshPublisherDesc(configName: "$host", transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/root/tensquare-front/deploy.sh ${harborUrl} ${image} ${containerName}", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }

    stage("Clean") {
        echo "Start clean ..."
        sh "rm -rf ${contextPath}"
        sh "rm -rf ${contextPath}@tmp"
        echo "Clean done."
    }
}
