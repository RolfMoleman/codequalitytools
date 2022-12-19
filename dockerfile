
###########################################
###########################################
##  Dockerfile to run codequalitytools   ##
###########################################
###########################################

# @not-generated

#############################################################################################
##                   other docker images to grab tools from                                ##
#############################################################################################
#FROM__START
FROM bridgecrew/checkov:latest as checkov
FROM infracost/infracost:latest as infracost
FROM checkmarx/kics:latest as kics
FROM oxsecurity/megalinter:latest as megalinter
FROM owasp/dependency-check:latest as owasp
FROM sonarsource/sonar-scanner-cli:latest as sonarcloud
FROM ghcr.io/terraform-linters/tflint:latest as tflint
FROM tenable/terrascan:latest as terrascan
FROM alpine/terragrunt:latest as terragrunt


#############################################################################################
##                                  Get base image                                         ##
#############################################################################################


#FROM python:3.10.4-alpine3.15
FROM ubuntu:22.04



### Infracost
#RUN curl -sLk "https://infracost.io/downloads/latest/infracost-linux-amd64.tar.gz" -o "/tmp/infracost-linux-amd64.tar.gz" \
#  && tar xzf "/tmp/infracost-linux-amd64.tar.gz" -C /tmp \
#  && rm "/tmp/infracost-linux-amd64.tar.gz" \
#  && mv "/tmp/infracost-linux-amd64" "/usr/local/bin/infracost" \
#  && infracost configure set currency GBP
#
### Terraform
#RUN wget https://releases.hashicorp.com/terraform/1.3.2/terraform_1.3.2_linux_amd64.zip \
#    && unzip terraform*.zip \
#    && mv terraform /usr/local/bin
#
### Terraform-compliance
#RUN pip install --upgrade pip \
#    && pip install "radish-bdd[coverage]" --upgrade \
#    && pip install "terraform-compliance[faster_parsing]" --upgrade 
#
### Terrascan
#RUN curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz \
#    && tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz \
#    && install terrascan /usr/local/bin && rm terrascan
#
### TFLint
#RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
#
### TFSEC
#RUN curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
#
### Trivy
#RUN curl -L "$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -o -E "https://.+?_Linux-64bit.deb" | head -1)" > trivy.deb \
#    && dpkg --install trivy.


######################
# Set the entrypoint #
######################
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]



################################
# Installs python dependencies #
################################
COPY megalinter /megalinter
#RUN python /megalinter/setup.py install \
#    && python /megalinter/setup.py clean --all \
#    && rm -rf /var/cache/apk/*
#######################################
# Copy scripts and rules to container #
#######################################
COPY megalinter/descriptors /megalinter-descriptors
COPY TEMPLATES /action/lib/.automation


#######################################
#        Add addditional tools        #
#######################################

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

### Infracost
#RUN curl -sLk "https://infracost.io/downloads/latest/infracost-linux-amd64.tar.gz" -o "/tmp/infracost-linux-amd64.tar.gz" \
#  && tar xzf "/tmp/infracost-linux-amd64.tar.gz" -C /tmp \
#  && rm "/tmp/infracost-linux-amd64.tar.gz" \
#  && mv "/tmp/infracost-linux-amd64" "/usr/local/bin/infracost" \
#  && infracost configure set currency GBP

##############
# Terraform  #
##############

RUN LATEST_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64'  | tail -1) \
    && curl ${LATEST_URL} > /tmp/terraform.zip \
    && unzip terraform*.zip \
    && mv terraform /usr/local/bin



###########################
# Get the build arguments #
###########################
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

#################################################
# Set ENV values used for debugging the version #
#################################################
ENV BUILD_DATE=$BUILD_DATE \
    BUILD_REVISION=$BUILD_REVISION \
    BUILD_VERSION=$BUILD_VERSION

ENV MEGALINTER_FLAVOR=all

#########################################
# Label the instance and set maintainer #
#########################################
LABEL maintainer="Carl Dawson <carl.dawson@outlook.com>" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$BUILD_REVISION \
    org.opencontainers.image.version=$BUILD_VERSION \
    org.opencontainers.image.authors="Carl Dawson <carl.dawson@outlook.com>" \
    org.opencontainers.image.url="https://RolfMoleman.github.io" \
    org.opencontainers.image.source="https://github.com/RolfMoleman/codequalitytools" \
    org.opencontainers.image.documentation="https://RolfMoleman.github.io" \
    org.opencontainers.image.vendor="Carl Dawson" \
    org.opencontainers.image.description="Lint your code base with GitHub Actions (DEV VERSION)"

