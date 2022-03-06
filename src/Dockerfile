FROM jenkins/jenkins:lts
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
USER root

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# # Setting the number of executors
# COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; chmod +x ./kubectl; mv ./kubectl /usr/local/bin/kubectl

# Install default plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY wait-on-kaniko-job.sh /usr/local/bin/wait-on-kaniko-job.sh
RUN chmod +x /usr/local/bin/wait-on-kaniko-job.sh

COPY run-kaniko-job.sh /usr/local/bin/run-kaniko-job.sh
RUN chmod +x /usr/local/bin/run-kaniko-job.sh

ENTRYPOINT ["/usr/local/bin/jenkins.sh"]