#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

if [ -e "/usr/bin/yum" ]; then
  PM=yum
  command -v lsb_release >/dev/null 2>&1 || { yum -y install redhat-lsb-core; clear; }
fi

command -v lsb_release >/dev/null 2>&1 || { echo "${CFAILURE}${PM} source failed! ${CEND}"; kill -9 $$; }

# Get OS Version
if [ -e /etc/redhat-release ]; then
  OS=CentOS
  CentOS_ver=$(lsb_release -sr | awk -F. '{print $1}')
  [[ "$(lsb_release -is)" =~ ^Aliyun$|^AlibabaCloudEnterpriseServer$ ]] && { CentOS_ver=7; Aliyun_ver=$(lsb_release -rs); }
  [ "$(lsb_release -is)" == 'Fedora' ] && [ ${CentOS_ver} -ge 19 >/dev/null 2>&1 ] && { CentOS_ver=7; Fedora_ver=$(lsb_release -rs); }
elif [ -n "$(grep 'Amazon Linux' /etc/issue)" -o -n "$(grep 'Amazon Linux' /etc/os-release)" ]; then
  OS=CentOS
  CentOS_ver=7
else
  OS=CentOS
  CentOS_ver=0
fi

# Check OS Version
if [ ${CentOS_ver} -lt 7 >/dev/null 2>&1 ]; then
  echo "${CFAILURE}Does not support this OS, Please install CentOS 7 ${CEND}"
  kill -9 $$
fi

# install wget gcc curl python
echo "${CMSG}Installing dependencies packages...${CEND}"
[ "${PM}" == 'yum' ] && yum clean all
${PM} -y install wget gcc curl python
if command -v curl >/dev/null 2>&1; then
  #echo 'already initialize' > ~/.genesis
	echo "${CMSG}Finished.${CEND}"
else
  echo "${CFAILURE}Installing dependencies packages failed${CEND}"
  exit 1
fi