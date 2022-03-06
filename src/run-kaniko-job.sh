DOCKER_FILE=${DOCKER_FILE:-Dockerfile}
CONTEXT=${CONTEXT:-null}
CONTEXT_SUB_PATH=${CONTEXT_SUB_PATH:-null}
DESTINATION=${DESTINATION:-null}
CACHE_DIR=${CACHE_DIR:-null}
CACHE_REPO=${CACHE_REPO:-null}


usage () {
    cat << END_USAGE
 <options>
--dockerfile        : [required] A docker file
--context           : [required] Git repository to build
--context-sub-path  : [optional] Docker file path
--destination       : [optional] Destionation to push repository. Default is [something]
END_USAGE

    exit 1
}

processOptions () {
    while [[ $# > 0 ]]; do
        case "$1" in
            --dockerfile)
                DOCKER_FILE=${2}; shift 2
            ;;
            --context)
                CONTEXT=${2}; shift 2
            ;;
            --context-sub-path)
                CONTEXT_SUB_PATH=${2}; shift 2
            ;;
            --destination)
                DESTINATION=${2}; shift 2
            ;;
            --cache-dir)
                CACHE_DIR=${2}; shift 2
            ;; 
            --cache-repo)
                NAMESPACE=${2}; shift 2
            ;;                                                    
            -h | --help)
                usage
            ;;
            *)
                usage
            ;;
        esac
    done
}

main () {

    echo -e "\nRunning"

    echo "DOCKER_FILE: ${DOCKER_FILE}"
    echo "CONTEXT:  ${CONTEXT}"
    echo "DESTINATION:      ${DESTINATION}"  
      
   cat <<EOF | kubectl apply -f -
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: kaniko
    spec:
      ttlSecondsAfterFinished: 600
      backoffLimit: 4
      template:
        spec:
          containers:
          - name: kaniko
            image: gcr.io/kaniko-project/executor:latest
            args: ["--dockerfile=${DOCKER_FILE}",
                    "--context=${CONTEXT}",
                    "--destination=${DESTINATION}"]
            volumeMounts:
              - name: maven-storage
                mountPath: /root/.m2
              - name: kaniko-cache
                mountPath: /cache
              - name: docker-config
                mountPath: /kaniko/.docker
            resources:
              limits:
                memory: 1024Mi
                cpu: "1"
              requests:
                memory: 256Mi
                cpu: "0.2"
          restartPolicy: Never
          volumes:
            - name: docker-config
              projected:
                sources:
                - secret:
                    name: regcred
                    items:
                      - key: .dockerconfigjson
                        path: config.json
EOF
}

processOptions $*
main
