#!/usr/bin/env bash
set -euo pipefail

VM_NAME="ubuntu-test"
UBUNTU_VERSION="22.04"
CPU=2
MEMORY="4G"
DISK="20G"
KEEP_EXISTING=0

log_info() {
  echo "[INFO] $*"
}
log_error() {
  echo "[ERROR] $*" >&2
}

usage() {
  cat <<EOF
用法: $0 [-k] [-n <vm_name>] [-h]

选项:
  -k             保留已有虚拟机，不删除，直接进入（如果不存在则创建）
  -n <vm_name>   指定虚拟机名称，默认: ubuntu-test
  -h             显示此帮助信息
EOF
}

parse_args() {
  KEEP_EXISTING=0
  while getopts ":kn:h" opt; do
    case "$opt" in
      k)
        KEEP_EXISTING=1
        ;;
      n)
        VM_NAME="$OPTARG"
        ;;
      h)
        usage
        exit 0
        ;;
      \?)
        log_error "未知选项: -$OPTARG"
        usage
        exit 1
        ;;
      :)
        log_error "选项 -$OPTARG 需要一个参数"
        usage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))
}

install_multipass_if_needed() {
  if command -v multipass >/dev/null 2>&1; then
    log_info "multipass 已安装，跳过安装"
  else
    log_info "multipass 未检测到，开始安装..."
    if ! command -v brew >/dev/null 2>&1; then
      log_error "Homebrew 未安装，请先安装 Homebrew：https://brew.sh/"
      exit 1
    fi
    brew install --cask multipass
    log_info "multipass 安装完成"
  fi
}

delete_vm_if_exists() {
  if multipass list | grep -q "^${VM_NAME}\b"; then
    log_info "删除已有虚拟机 $VM_NAME"
    multipass delete "$VM_NAME"
    multipass purge
  else
    log_info "虚拟机 $VM_NAME 不存在，跳过删除"
  fi
}

create_vm() {
  log_info "创建新的 Ubuntu $UBUNTU_VERSION 虚拟机 $VM_NAME ..."
  multipass launch --name "$VM_NAME" --cpus "$CPU" --memory "$MEMORY" --disk "$DISK" "$UBUNTU_VERSION"
  log_info "虚拟机 $VM_NAME 创建完成"
}

enter_vm_shell() {
  log_info "进入虚拟机 shell: multipass shell $VM_NAME"
  multipass shell "$VM_NAME"
}

main() {
  parse_args "$@"

  install_multipass_if_needed

  if multipass list | grep -q "^${VM_NAME}\b"; then
    log_info "虚拟机 $VM_NAME 已存在"
    if [ "$KEEP_EXISTING" -eq 1 ]; then
      log_info "保留已有虚拟机，直接进入"
      enter_vm_shell
    else
      log_info "未指定保留，删除重建"
      delete_vm_if_exists
      create_vm
      enter_vm_shell
    fi
  else
    log_info "虚拟机 $VM_NAME 不存在，开始创建"
    create_vm
    enter_vm_shell
  fi
}

main "$@"
