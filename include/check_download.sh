#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

checkDownload() {
  mirrorLink=http://mirrors.linuxeye.com/oneinstack/src
  pushd ${oneinstack_dir}/src > /dev/null
  # icu
  if ! command -v icu-config >/dev/null 2>&1 || icu-config --version | grep '^3.'; then
    echo "Download icu..."
    src_url=${mirrorLink}/icu4c-${icu4c_ver}-src.tgz && Download_src
  fi

  # jemalloc
  if [[ ${nginx_option} =~ ^[1-3]$ ]]; then
    echo "Download jemalloc..."
    src_url=${mirrorLink}/jemalloc-${jemalloc_ver}.tar.bz2 && Download_src
  fi

  # nginx/tengine/openresty
  case "${nginx_option}" in
    1)
      echo "Download openSSL1.1..."
      src_url=https://www.openssl.org/source/openssl-${openssl11_ver}.tar.gz && Download_src
      echo "Download nginx..."
      src_url=http://nginx.org/download/nginx-${nginx_ver}.tar.gz && Download_src
      ;;
  esac

  # pcre
  if [[ "${nginx_option}" =~ ^[1-3]$ ]]; then
    echo "Download pcre..."
    src_url=https://ftp.pcre.org/pub/pcre/pcre-${pcre_ver}.tar.gz && Download_src
  fi

  # others
  if [ "${downloadDepsSrc}" == '1' ]; then
    if [ "${PM}" == 'yum' ]; then
      echo "Download htop for CentOS..."
      src_url=http://hisham.hm/htop/releases/${htop_ver}/htop-${htop_ver}.tar.gz && Download_src
    fi
  fi

  popd > /dev/null
}
