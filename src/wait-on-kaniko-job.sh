JOB=${JOB:-kaniko}


errorExit () {
    echo -e "\nERROR: $1"; echo
    exit 1
}

usage () {
    cat << END_USAGE
 <options>
--job  : [required] A docker file
END_USAGE

    exit 1
}

processOptions () {
    while [[ $# > 0 ]]; do
        case "$1" in
            --job)
                JOB=${2}; shift 2
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


main() {
  while true; do
    if kubectl wait --for=condition=complete --timeout=0 job/${JOB} 2>/dev/null; then
      job_result=0
      break
    fi

    if kubectl wait --for=condition=failed --timeout=0 job/${JOB} 2>/dev/null; then
      job_result=1
      break
    fi

    sleep 3
  done

  if [[ $job_result -eq 1 ]]; then
      echo "Job failed!"
      exit 1
  fi

  echo "Job succeeded"
}

processOptions $*
main