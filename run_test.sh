#!/bin/bash

####################################################################################################
# Copyright (c) 2018 Marcus Geelnard
#
# This software is provided 'as-is', without any express or implied warranty. In no event will the
# authors be held liable for any damages arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose, including commercial
# applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#  1. The origin of this software must not be misrepresented; you must not claim that you wrote
#     the original software. If you use this software in a product, an acknowledgment in the
#     product documentation would be appreciated but is not required.
#
#  2. Altered source versions must be plainly marked as such, and must not be misrepresented as
#     being the original software.
#
#  3. This notice may not be removed or altered from any source distribution.
####################################################################################################

WORKDIR=out
GHDL=ghdl
GHDLFLAGS="--std=08 --work=work --workdir=${WORKDIR}"

for i in {0..5}; do
  if [ "$1" = "--vcd" ]; then
    VCD=yes
    shift
  fi
  if [ "$1" = "--wave" ]; then
    WAVE=yes
    shift
  fi
  if [ "$1" = "--assert" ]; then
    GHDLRUNFLAGS="${GHDLRUNFLAGS} --assert-level=warning --backtrace-severity=warning"
    shift
  fi
done

for i in $*; do
  echo "** TEST: $i"
  if [ "x${VCD}" = "xyes" ]; then
    ${GHDL} -r ${GHDLFLAGS} "$i" "--vcd=${WORKDIR}/$i.vcd" ${GHDLRUNFLAGS}
  elif [ "x${WAVE}" = "xyes" ]; then
    ${GHDL} -r ${GHDLFLAGS} "$i" "--wave=${WORKDIR}/$i.ghw" ${GHDLRUNFLAGS}
  else
    ${GHDL} -r ${GHDLFLAGS} "$i" ${GHDLRUNFLAGS}
  fi
  echo ""
done

