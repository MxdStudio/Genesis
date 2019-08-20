#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       Project Genesis - System initialization for CentOS 7          #
#       For more information please visit https://xxx                 #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

mxdroot_dir=$(dirname "`readlink -f $0`")
pushd ${mxdroot_dir} > /dev/null

. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/download.sh

# Authentication
while :; do echo
  echo "${CMSG}User Authentication${CEND}"
  read -e -p "Auth Token: " AUTH_TOKEN
  if [[ -z ${AUTH_TOKEN} ]]; then
    echo "${CWARNING}input error! Please input auth-token${CEND}"
  else
    break
  fi
done

genesis_options_flag=N
. <(curl -H 'Authorization: token ${AUTH_TOKEN}' -H 'Accept: application/vnd.github.v4.raw' -s -L https://api.github.com/repos/MxdStudio/all-inclusive/contents/genesis/auth.conf)
if [ "${genesis_options_flag}" == 'N' ]; then
  echo "${CFAILURE}Authentication failed!${CEND}"
  exit 1
fi

version() {
  echo "version: 1.0"
  echo "updated date: 2019-08-15"
}

#Show_Help() {
#  version
#  echo "Usage: $0  command ...[parameters]....
#  --help, -h                  Show this help message, More: https://oneinstack.com/auto
#  --version, -v               Show version info
#  --nginx_option [1-3]        Install Nginx server version
#  --apache_option [1-2]       Install Apache server version
#  --apache_mode_option [1-2]  Apache2.4 mode, 1(default): php-fpm, 2: mod_php
#  --apache_mpm_option [1-3]   Apache2.4 MPM, 1(default): event, 2: prefork, 3: worker
#  --php_option [1-8]          Install PHP version
#  --mphp_ver [53~73]          Install another PHP version (PATH: ${php_install_dir}\${mphp_ver})
#  --mphp_addons               Only install another PHP addons
#  --phpcache_option [1-4]     Install PHP opcode cache, default: 1 opcache
#  --php_extensions [ext name] Install PHP extensions, include zendguardloader,ioncube,
#                              sourceguardian,imagick,gmagick,fileinfo,imap,ldap,calendar,phalcon,
#                              yaf,yar,redis,memcached,memcache,mongodb,swoole,xdebug
#  --tomcat_option [1-4]       Install Tomcat version
#  --jdk_option [1-4]          Install JDK version
#  --db_option [1-15]          Install DB version
#  --dbinstallmethod [1-2]     DB install method, default: 1 binary install
#  --dbrootpwd [password]      DB super password
#  --pureftpd                  Install Pure-Ftpd
#  --redis                     Install Redis
#  --memcached                 Install Memcached
#  --phpmyadmin                Install phpMyAdmin
#  --hhvm                      Install HHVM
#  --python                    Install Python (PATH: ${python_install_dir})
#  --ssh_port [No.]            SSH port
#  --iptables                  Enable iptables
#  --reboot                    Restart the server after installation
#  "
#}

ARG_NUM=$#
#TEMP=`getopt -o hvV --long help,version,nginx_option:,apache_option:,apache_mode_option:,apache_mpm_option:,php_option:,mphp_ver:,mphp_addons,phpcache_option:,php_extensions:,tomcat_option:,jdk_option:,db_option:,dbrootpwd:,dbinstallmethod:,pureftpd,redis,memcached,phpmyadmin,hhvm,python,ssh_port:,iptables,reboot -- "$@" 2>/dev/null`
#[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
#eval set -- "${TEMP}"
#while :; do
#  [ -z "$1" ] && break;
#  case "$1" in
#    -h|--help)
#      Show_Help; exit 0
#      ;;
#    -v|-V|--version)
#      version; exit 0
#      ;;
#    --nginx_option)
#      nginx_option=$2; shift 2
#      [[ ! ${nginx_option} =~ ^[1-3]$ ]] && { echo "${CWARNING}nginx_option input error! Please only input number 1~3${CEND}"; exit 1; }
#      [ -e "${nginx_install_dir}/sbin/nginx" ] && { echo "${CWARNING}Nginx already installed! ${CEND}"; unset nginx_option; }
#      [ -e "${tengine_install_dir}/sbin/nginx" ] && { echo "${CWARNING}Tengine already installed! ${CEND}"; unset nginx_option; }
#      [ -e "${openresty_install_dir}/nginx/sbin/nginx" ] && { echo "${CWARNING}OpenResty already installed! ${CEND}"; unset nginx_option; }
#      ;;
#    --ssh_port)
#      ssh_port=$2; shift 2
#      ;;
#    --iptables)
#      iptables_flag=y; shift 1
#      ;;
#    --reboot)
#      reboot_flag=y; shift 1
#      ;;
#    --)
#      shift
#      ;;
#    *)
#      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
#      ;;
#  esac
#done

# Use default SSH port 22. If you use another SSH port on your server
if [ -e "/etc/ssh/sshd_config" ]; then
  [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && now_ssh_port=22 || now_ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1`
  while :; do echo
    [ ${ARG_NUM} == 0 ] && read -e -p "Please input SSH port(Default: ${now_ssh_port}): " ssh_port
    ssh_port=${ssh_port:-${now_ssh_port}}
    if [ ${ssh_port} -eq 22 >/dev/null 2>&1 -o ${ssh_port} -gt 1024 >/dev/null 2>&1 -a ${ssh_port} -lt 65535 >/dev/null 2>&1 ]; then
      break
    else
      echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
      exit 1
    fi
  done

  #if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "${ssh_port}" != '22' ]; then
  #  sed -i "s@^#Port.*@&\nPort ${ssh_port}@" /etc/ssh/sshd_config
  #elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ]; then
  #  sed -i "s@^Port.*@Port ${ssh_port}@" /etc/ssh/sshd_config
  #fi
fi

if [ ${ARG_NUM} == 0 ]; then

  # check Server type
  while :; do echo
    echo 'Please select server type:'
    echo -e "\t${CMSG}1${CEND}. KVM"
    echo -e "\t${CMSG}2${CEND}. OpenVZ/LXC"
    echo -e "\t${CMSG}3${CEND}. Physical server"
    read -e -p "Please input a number:(Default 1 press Enter) " server_option
    server_option=${server_option:-1}
    if [[ ! ${server_option} =~ ^[1-3]$ ]]; then
      echo "${CWARNING}input error! Please only input number 1~3${CEND}"
    else
      if [ ${server_option} -eq 1 >/dev/null 2>&1 -o ${server_option} -eq 3 >/dev/null 2>&1 ]; then
        while :; do echo
          free -mt
          read -e -p "Do you want to add Swap file? [y/n]: " add_swap_flag
          if [[ ! ${add_swap_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
          else
            if [ "${add_swap_flag}" == 'Y' ]; then
              while :; do echo
                read -e -p "How many swap(MB) you want to add(Default: 0, means 0MB): " swap_size
                swap_size=${swap_size:-0}
                if [ ${swap_size} -lt 0 >/dev/null 2>&1 ]; then
                  echo "$${CWARNING}input error! Please input a number >= 0${CEND}"
                else
                  break
                fi
              done
            else
              swap_size=0
            fi
            break
          fi
        done
      else
        swap_size=0
      fi
      break
    fi
  done

  # Hostname/Domain
  while :; do echo
    read -e -p "Please input hostname/domain(example: www.example.com): " hostname_domain
    if [ -z "$(echo ${domain} | grep '.*\..*')" ]; then
      echo "${CWARNING}Your ${hostname_domain} is invalid! ${CEND}"
    else
      break
    fi
  done

  # DDNS
  while :; do echo
    read -e -p "Do you want to use DDNS? [y/n]: " ddns_flag
    if [[ ! ${ddns_flag} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  # SSL cert
  while :; do echo
    read -e -p "Do you want to get SSL cert? [y/n]: " getssl_flag
    if [[ ! ${getssl_flag} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  # check ports
  while :; do echo
    read -e -p "Please input Supervisor WebUI port(Default: 27999): " spv_port
    spv_port=${spv_port:-27999}
    if [ ${spv_port} -nq ${ssh_port} >/dev/null 2>&1 -o ${spv_port} -gt 1024 >/dev/null 2>&1 -a ${spv_port} -lt 65535 >/dev/null 2>&1 ]; then
      break
    else
      echo "${CWARNING}input error! Input range: 1025~65534 except ${ssh_port}${CEND}"
    fi
  done
  while :; do echo
    read -e -p "Please input HTTPS port(Default: 443): " https_port
    https_port=${https_port:-443}
    if [ ${https_port} -eq 443 >/dev/null 2>&1 -o ${https_port} -nq ${ssh_port} >/dev/null 2>&1 -o ${https_port} -nq ${spv_port} >/dev/null 2>&1 -o ${https_port} -gt 1024 >/dev/null 2>&1 -a ${https_port} -lt 65535 >/dev/null 2>&1 ]; then
      break
    else
      echo "${CWARNING}input error! Input range: 443, 1025~65534 except ${ssh_port} ${spv_port}${CEND}"
    fi
  done
  while :; do echo
    read -e -p "Please input HTTP port(Default: 80): " http_port
    ss_port=${http_port:-80}
    if [ ${http_port} -eq 80 >/dev/null 2>&1 -o ${http_port} -nq ${ssh_port} >/dev/null 2>&1 -o ${http_port} -nq ${spv_port} >/dev/null 2>&1 -o ${http_port} -nq ${https_port} >/dev/null 2>&1 -o ${http_port} -gt 1024 >/dev/null 2>&1 -a ${http_port} -lt 65535 >/dev/null 2>&1 ]; then
      break
    else
      echo "${CWARNING}input error! Input range: 80, 1025~65534 except ${ssh_port} ${spv_port} ${https_port}${CEND}"
    fi
  done
fi

## Check download source packages
#. ./include/check_download.sh
#checkDownload 2>&1 | tee -a ${mxdroot_dir}/install.log

# get OS Memory
. ./include/memory.sh

# Install oneinstack
file_url=http://mirrors.linuxeye.com/oneinstack.tar.gz && Download_file
tar xzf oneinstack.tar.gz && ./oneinstack/install.sh --nginx_option 1 --iptables  --ssh_port ${ssh_port}

# V2Ray
. include/v2ray.sh
Install_V2Ray 2>&1 | tee -a ${mxdroot_dir}/install.log


if [ ${ARG_NUM} == 0 ]; then
  while :; do echo
    echo "${CMSG}Please restart the server and see if the services start up fine.${CEND}"
    read -e -p "Do you want to restart OS ? [y/n]: " reboot_flag
    if [[ ! "${reboot_flag}" =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done
fi
[ "${reboot_flag}" == 'y' ] && reboot
