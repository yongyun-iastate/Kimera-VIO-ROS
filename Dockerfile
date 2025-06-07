FROM ros:noetic-ros-base

RUN rm /etc/apt/sources.list.d/ros1-latest.list \
  && rm /usr/share/keyrings/ros1-latest-archive-keyring.gpg

RUN apt-get update \
  && apt-get install -y ca-certificates curl

RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') ;\
    curl -L -s -o /tmp/ros-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" \
    && apt-get update \
    && apt-get install /tmp/ros-apt-source.deb \
    && rm -f /tmp/ros-apt-source.deb

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y ros-noetic-image-geometry ros-noetic-pcl-ros \
    ros-noetic-cv-bridge git cmake build-essential unzip pkg-config autoconf \
    libboost-all-dev \
    libjpeg-dev libpng-dev libtiff-dev \
    # Use libvtk5-dev, libgtk2.0-dev in ubuntu 16.04 \
    libvtk7-dev libgtk-3-dev \
    libatlas-base-dev gfortran \
    libparmetis-dev \
    python3-wstool python3-catkin-tools \
    # libtbb recommended for speed: \
    libtbb-dev

RUN mkdir -p /catkin_ws/src/
RUN git clone https://github.com/MIT-SPARK/Kimera-VIO-ROS.git /catkin_ws/src/Kimera-VIO-ROS
RUN cd /catkin_ws/src/Kimera-VIO-ROS 
    # && git checkout ___
RUN cd /catkin_ws/src/ && wstool init && \
    wstool merge Kimera-VIO-ROS/install/kimera_vio_ros_https.rosinstall && wstool update

# Build catkin workspace
RUN apt-get install -y ros-noetic-image-pipeline ros-noetic-geometry ros-noetic-rviz

RUN . /opt/ros/noetic/setup.sh && cd /catkin_ws && \
    catkin init && catkin config --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    catkin build
