#!/bin/bash

# 同步上游操作

function tongbu_0() {
# 第一步下载上游仓库
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f repogx/build operates
else
  rm -rf shangyou && git clone -b main https://github.com/281677160/autobuild shangyou
  if [[ ! -d "operates" ]]; then
    cp -Rf shangyou/build operates
  fi
fi
}

function tongbu_1() {
# 删除上游的seed和备份diy-part.sh、settings.ini
rm -rf shangyou/build/*/{diy,files,patches,seed}
for X in $(find "operates" -name "diy-part.sh" |sed 's/\/diy-part.sh//g'); do mv "${X}"/diy-part.sh "${X}"/diy-part.sh.bak; done
for X in $(find "operates" -name "settings.ini" |sed 's/\/settings.ini//g'); do mv "${X}"/settings.ini "${X}"/settings.ini.bak; done


# 从上游仓库覆盖文件到本地仓库
for X in $(grep "\"COOLSNOWWOLF\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lede/* "${X}"; done
for X in $(grep "\"LIENOL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Lienol/* "${X}"; done
for X in $(grep "\"IMMORTALWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Immortalwrt/* "${X}"; done
for X in $(grep "\"XWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Xwrt/* "${X}"; done
for X in $(grep "\"OFFICIAL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Official/* "${X}"; done
for X in $(grep "\"AMLOGIC\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do cp -Rf shangyou/build/Amlogic/* "${X}"; done

# 云仓库的修改文件
case "${TONGBU_CANGKU}" in
1)
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/README.md repogx/README.md
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/LICENSE repogx/LICENSE
  for X in $(ls -1 ${GITHUB_WORKSPACE}/repogx/.github/workflows |grep -Eo .*.yml); do 
    cp -Rf ${GITHUB_WORKSPACE}/repogx/.github/workflows/${X} ${GITHUB_WORKSPACE}/repogx/.github/workflows/${X}.bak
  done 
  
  for W in $(ls -1 ${GITHUB_WORKSPACE}/repogx/.github/workflows |grep -Eo .*.yml |grep -v '.bak'); do
    X="${GITHUB_WORKSPACE}/repogx/.github/workflows/${W}"
    aa="$(grep 'target: \[.*\]' "${X}" |sed 's/^[ ]*//g' |grep -v '^#' | sed -r 's/target: \[(.*)\]/\1/')"
    TARGE1="target: \\[.*\\]"
    TARGE2="target: \\[${aa}\\]"
    yml_name1="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    if [[ -d "${GITHUB_WORKSPACE}/operates/${aa}" ]]; then
      SOURCE_CODE1="$(grep 'SOURCE_CODE=' "${GITHUB_WORKSPACE}/operates/${aa}/settings.ini" | cut -d '"' -f2)"
    else
      echo "build文件夹里面没发现有${SOURCE_CODE1}此文件夹存在"
    fi
    if [[ "${SOURCE_CODE1}" == "AMLOGIC" ]]; then
      cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Amlogic.yml ${X}
    elif [[ "${SOURCE_CODE1}" == "IMMORTALWRT" ]]; then
      cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Immortalwrt.yml ${X}
    elif [[ "${SOURCE_CODE1}" == "COOLSNOWWOLF" ]]; then
      cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lede.yml ${X}
    elif [[ "${SOURCE_CODE1}" == "LIENOL" ]]; then 
      cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Lienol.yml ${X}
    elif [[ "${SOURCE_CODE1}" == "OFFICIAL" ]]; then
      cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Official.yml ${X}
    elif [[ "${SOURCE_CODE1}" == "XWRT" ]]; then 
      cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/Xwrt.yml ${X}
    else
      echo ""
    fi
    yml_name2="$(grep 'name:' "${X}"  |grep -v '^#' |awk 'NR==1')"
    sed -i "s?${TARGE1}?${TARGE2}?g" ${X}
    sed -i "s?${yml_name2}?${yml_name1}?g" "${X}"
  done
  
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/compile.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/compile.yml
  cp -Rf ${GITHUB_WORKSPACE}/shangyou/.github/workflows/synchronise.yml ${GITHUB_WORKSPACE}/repogx/.github/workflows/synchronise.yml
;;
esac

# 修改本地文件
if [[ ! "${TONGBU_CANGKU}" == "1" ]]; then
rm -rf operates/*/relevance
for X in $(find "operates" -name "settings.ini" |sed 's/\/settings.ini//g'); do 
  mkdir -p "${X}/relevance"
  echo "BENDI_VERSION=${BENDI_VERSION}" > "${X}/relevance/bendi_version"
  echo "bendi_version文件为检测版本用,请勿修改和删除" > "${X}/relevance/README.md"
done
for X in $(find "operates" -name "settings.ini"); do
  sed -i '/SSH_ACTIONS/d' "${X}"
  sed -i '/UPLOAD_FIRMWARE/d' "${X}"
  sed -i '/UPLOAD_WETRANSFER/d' "${X}"
  sed -i '/UPLOAD_RELEASE/d' "${X}"
  sed -i '/INFORMATION_NOTICE/d' "${X}"
  sed -i '/CACHEWRTBUILD_SWITCH/d' "${X}"
  sed -i '/COMPILATION_INFORMATION/d' "${X}"
  sed -i '/UPDATE_FIRMWARE_ONLINE/d' "${X}"
  sed -i '/CPU_SELECTION/d' "${X}"
  sed -i '/RETAIN_DAYS/d' "${X}"
  sed -i '/KEEP_LATEST/d' "${X}"
  echo 'MODIFY_CONFIGURATION="true"         # 是否每次都询问您要不要设置自定义文件（true=开启）（false=关闭）' >> "${X}"
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    echo 'WSL_ROUTEPATH="false"               # 关闭询问改变WSL路径（true=开启）（false=关闭）' >> "${X}"
  fi
  echo 'MAKE_CONFIGURATION="false"          # 单纯制作.config配置文件,不编译固件（true=开启）（false=关闭）' >> "${X}"
done
fi

# 恢复settings.ini设置
# Amlogic
for X in $(grep "\"AMLOGIC\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# 天灵
for X in $(grep "\"IMMORTALWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# 大雕
for X in $(grep "\"COOLSNOWWOLF\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# LI大
for X in $(grep "\"LIENOL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# 官方的
for X in $(grep "\"OFFICIAL\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done

# x_wrt
for X in $(grep "\"XWRT\"" -rl "operates" |grep "settings.ini" |sed 's/\/settings.*//g' |uniq); do
  aa="$(grep "REPO_BRANCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "REPO_BRANCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  cc="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |cut -d '"' -f2)"
  if [[ ! "${cc}" == ".config" ]]; then
    aa="$(grep "CONFIG_FILE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    bb="$(grep "CONFIG_FILE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
    if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
     sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
    fi
  fi
  aa="$(grep "DIY_PART_SH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "DIY_PART_SH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COLLECTED_PACKAGES" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "MODIFY_CONFIGURATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "PACKAGING_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "WSL_ROUTEPATH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "WSL_ROUTEPATH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  
  aa="$(grep "SSH_ACTIONS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "SSH_ACTIONS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_FIRMWARE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_WETRANSFER" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPLOAD_RELEASE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPLOAD_RELEASE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "INFORMATION_NOTICE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "INFORMATION_NOTICE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CACHEWRTBUILD_SWITCH" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "UPDATE_FIRMWARE_ONLINE" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "COMPILATION_INFORMATION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "CPU_SELECTION" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "CPU_SELECTION" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "RETAIN_DAYS" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "RETAIN_DAYS" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
  aa="$(grep "KEEP_LATEST" "${X}/settings.ini" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  bb="$(grep "KEEP_LATEST" "${X}/settings.ini.bak" |sed 's/^[ ]*//g' |grep -v '^#' |awk '{print $(1)}')"
  if [[ -n "${aa}" ]] && [[ -n "${bb}" ]]; then
   sed -i "s?${aa}?${bb}?g" "${X}/settings.ini"
  fi
done
}

function tongbu_2() {
  for X in $(find "operates" -name "settings.ini" |sed 's/\/settings.ini//g'); do rm -rf "${X}"/*.bak; done
  rm -rf ${GITHUB_WORKSPACE}/repogx/.github/workflows/*.bak
  
}

function tongbu_3() {
# 上游仓库用完，删除了
if [[ "${TONGBU_CANGKU}" == "1" ]]; then
  mv -f operates repogx/build
else
  rm -rf shangyou
fi
}

function menu4() {
rm -rf repogx/*
cp -Rf shangyou/* repogx/
rm -rf repogx/.github/workflows/*
cp -Rf shangyou/.github/workflows/* repogx/.github/workflows/
}

function github_establish() {
if [[ ! -d "shangyou" ]]; then
  git clone -b main https://github.com/281677160/autobuild.git shangyou
fi
if [[ ! -d "repogx" ]]; then
  git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
fi
aa="${inputs_establish_sample}"
bb="${inputs_establish_name}"
if [[ ! -d "repogx/build/${bb}" ]]; then
  cp -Rf repogx/build/"${aa}" repogx/build/"${bb}"
  rm -rf repogx/build/${bb}/relevance/*ini
  echo "[${bb}]文件夹创建完成"
else
  echo "[${bb}]文件夹已存在"
fi

SOURCE_CODE1="$(source "repogx/build/${bb}/settings.ini" && echo ${SOURCE_CODE})"
if [[ "${SOURCE_CODE1}" == "AMLOGIC" ]]; then
  cp -Rf shangyou/.github/workflows/Amlogic.yml repogx/.github/workflows/${bb}.yml
  nn="Amlogic"
elif [[ "${SOURCE_CODE1}" == "IMMORTALWRT" ]]; then
  cp -Rf shangyou/.github/workflows/Immortalwrt.yml repogx/.github/workflows/${bb}.yml
  nn="Immortalwrt"
elif [[ "${SOURCE_CODE1}" == "COOLSNOWWOLF" ]]; then
  cp -Rf shangyou/.github/workflows/Lede.yml repogx/.github/workflows/${bb}.yml
  nn="Lede"
elif [[ "${SOURCE_CODE1}" == "LIENOL" ]]; then
  cp -Rf shangyou/.github/workflows/Lienol.yml repogx/.github/workflows/${bb}.yml
  nn="Lienol"
elif [[ "${SOURCE_CODE1}" == "OFFICIAL" ]]; then
  cp -Rf shangyou/.github/workflows/Official.yml repogx/.github/workflows/${bb}.yml
  nn="Official"
elif [[ "${SOURCE_CODE1}" == "XWRT" ]]; then
  cp -Rf shangyou/.github/workflows/Xwrt.yml repogx/.github/workflows/${bb}.yml
  nn="Xwrt"
fi
        
yml_name="$(grep 'name:' "repogx/.github/workflows/${bb}.yml"  |grep -v '^#' |awk 'NR==1')"
sed -i "s?${yml_name}?name: ${nn}-${bb}?g" "repogx/.github/workflows/${bb}.yml"
        
TARGE1="target: \\[.*\\]"
TARGE2="target: \\[${bb}\\]"
sed -i "s?${TARGE1}?${TARGE2}?g" repogx/.github/workflows/${bb}.yml
}

function github_deletefile() {
if [[ ! -d "repogx" ]]; then
  git clone -b main https://github.com/${GIT_REPOSITORY}.git repogx
fi
aa="${inputs_Deletefile_name}"
bb=(${aa//,/ })
for cc in ${bb[@]}; do
  if [[ -d "repogx/build/${cc}" ]]; then
    rm -rf repogx/build/"$cc"
    rm -rf $(grep -rl "target: \[$cc\]" "repogx/.github/workflows" |sed 's/^[ ]*//g' |grep -v '^#\|compile')
    echo "已删除[${cc}]文件夹"
  else
    echo "[${cc}]文件夹不存在"
  fi
done
}

function menu1() {
  tongbu_0
  tongbu_2
  tongbu_3
}
function menu2() {
  tongbu_0
  tongbu_1
  tongbu_3
}
function menu3() {
  tongbu_0
  tongbu_1
  tongbu_2
  tongbu_3
}


