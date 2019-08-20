#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Download_file() {
  [ -s "${file_url##*/}" ] && echo "[${CMSG}${file_url##*/}${CEND}] found" || { wget --limit-rate=10M -4 --tries=6 -c --no-check-certificate ${file_url}; sleep 1; }
  if [ ! -e "${file_url##*/}" ]; then
    echo "${CFAILURE}Download failed! Please check ${file_url}${CEND}"
    kill -9 $$
  fi
}
