# fbsd_update.mod: get list of installed packages.
#	written by seirios
##############################################################################
# Usage:
# fbsd_update
# RETUEN=`fbsd_update`
# Tested on FreeBSD/CentOS/Ubuntu
#
# Not POSIX Commands: freebsd-update
# Other MODs: checkos

fbsd_update() {
  _OS=`checkos -k | tr [:upper:] [:lower:]`
  _DIST=`checkos -d | tr [:upper:] [:lower:]`

  case ${_OS} in
  freebsd)
    sudo freebsd-update fetch install
  ;;
  linux)
    case "${_DIST}" in
    centos*)
    ;;
    ubuntu)
    ;;
    esac
  ;;
  *)
    echo "Not supported platform."; return 1
  esac

}

##### TEST CODE
if [ ${pkg_list_TEST} ]; then
  . ../checkos.mod
  echo "Before"
  RET=`fbsd_update`
  echo "TEST:pkg_list: ${RET}"
  echo "after"
  echo
fi
