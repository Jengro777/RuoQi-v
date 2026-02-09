#!/usr/bin/env -S v run

import log
import os

mut l := log.Log{}
l.set_output_stream(os.stdout())

log.info('${@METHOD}  ${@MOD}.${@FILE_LINE}')

// ----------------------------
// 1. 路径相关变量
// ----------------------------
log.info('@VROOT: ${@VROOT}') // V语言安装根目录（如 /usr/local/v）
log.info('@VMODROOT: ${@VMODROOT}') // 当前模块根目录（如项目根路径）
log.info('@VEXEROOT: ${@VEXEROOT}') // V编译器可执行文件所在目录
// log.info('@VMOD_FILE: ${@VMOD_FILE}')          // 当前模块的 v.mod 文件路径

// ----------------------------
// 2. 代码位置相关变量
// ----------------------------
log.info('@FILE: ${@FILE}') // 当前文件名（如 main.v）
log.info('@LINE: ${@LINE}') // 当前行号（整数）
log.info('@COLUMN: ${@COLUMN}') // 当前列号（整数）
log.info('@FILE_LINE: ${@FILE_LINE}') // 组合文件名和行号（如 main.v:42）
log.info('@LOCATION: ${@LOCATION}') // 完整位置（如 my_module/main.v:42）

// ----------------------------
// 3. 函数/结构体上下文变量
// ----------------------------
log.info('@FN: ${@FN}') // 当前函数名（如 main）
log.info('@METHOD: ${@METHOD}') // 当前方法名（结构体方法中有效）
log.info('@STRUCT: ${@STRUCT}') // 当前结构体名（结构体内部有效）
log.info('@MOD: ${@MOD}') // 当前模块名（如 my_module）

// ----------------------------
// 4. 编译元信息变量
// ----------------------------
log.info('@VEXE: ${@VEXE}') // V编译器路径（如 /usr/local/v/v）
log.info('@VHASH: ${@VHASH}') // 当前编译器版本哈希（短格式）
log.info('@VCURRENTHASH: ${@VCURRENTHASH}') // 当前代码文件的哈希值
// log.info('@VMODHASH: ${@VMODHASH}')            // 当前模块的 v.mod 文件哈希

// ----------------------------
// 5. 构建时间相关变量
// ----------------------------
log.info('@BUILD_DATE: ${@BUILD_DATE}') // 构建日期（如 2023-09-15）
log.info('@BUILD_TIME: ${@BUILD_TIME}') // 构建时间（如 14:30:00）
log.info('@BUILD_TIMESTAMP: ${@BUILD_TIMESTAMP}') // 完整时间戳（如 2023-09-15_14:30:00）
