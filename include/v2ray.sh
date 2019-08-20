#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_V2Ray() {
  # run official script to install v2ray
  bash <(curl -L -s https://install.direct/go.sh)
  systemctl stop v2ray
  systemctl disable v2ray
  systemctl mask v2ray

  if [ -e "${v2ray_install_dir}/v2ray" ]; then
    echo "${CSUCCESS}V2Ray installed successfully! ${CEND}"
  else
    rm -rf ${v2ray_install_dir}
    echo "${CFAILURE}V2Ray install failed, Please Contact the author! ${CEND}"
    kill -9 $$
  fi
}
