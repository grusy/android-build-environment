# Android Dockerfile

FROM ubuntu:14.04

MAINTAINER Mobile Builds Eng "mobile-builds-eng@uber.com"

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

ENV DOCKER_ANDROID_LANG en_US
ENV DOCKER_ANDROID_DISPLAY_NAME mobileci-docker

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

ENV ANDROID_COMPONENTS platform-tools,android-25,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository,build-tools-25.0.2,build-tools-24.0.3
# Environment variables
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV PATH ${INFER_HOME}/bin:${PATH}
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_SDK_HOME/build-tools/25.0.2
ENV PATH $PATH:$ANDROID_SDK_HOME/build-tools/24.0.3

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Update apt-get
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
  autoconf \
  build-essential \
  bzip2 \
  curl \
  gcc \
  git \
  groff \
  lib32stdc++6 \
  lib32z1 \
  lib32z1-dev \
  lib32ncurses5 \
  lib32bz2-1.0 \
  libc6-dev \
  libgmp-dev \
  libmpc-dev \
  libmpfr-dev \
  libxslt-dev \
  libxml2-dev \
  m4 \
  make \
  ncurses-dev \
  ocaml \
  openssh-client \
  pkg-config \
  python-software-properties \
  rsync \
  software-properties-common \
  unzip \
  wget \
  zip \
  zlib1g-dev \
  --no-install-recommends \

  # Install Java
  && apt-add-repository ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get -y install openjdk-8-jdk \
  --no-install-recommends \

  # Clean Up Apt-get
  && apt-get clean \ 
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN wget https://dl.google.com/android/repository/tools_r25.2.5-linux.zip \
  && unzip tools_r25.2.5-linux.zip \
  && mkdir -p /usr/local/android-sdk \
  && mv tools /usr/local/android-sdk/ \
  && rm tools_r25.2.5-linux.zip \

# Install Android tools
  && echo y | /usr/local/android-sdk/tools/android update sdk --filter "${ANDROID_COMPONENTS}" --no-ui -a \


# Creating project directories prepared for build when running
# `docker run`
ENV PROJECT /project
RUN mkdir $PROJECT
RUN chown -R $RUN_USER:$RUN_USER $PROJECT
WORKDIR $PROJECT

RUN touch /usr/local/android-sdk/.android/repositories.cfg 
RUN echo "sdk.dir=$ANDROID_HOME" > local.properties
