#!/bin/bash
# Starting from a Lustre kernel SRPM, prepare the kernel source code for
# compiling Lustre. This script is based on page
# https://wiki.hpdd.intel.com/pages/viewpage.action?pageId=8126821
# with Yan's fixes for some known errors on that page.
#
# Copyright (c) 2015, 2016 University of California, Santa Cruz, CA, USA.
# Created by Yan Li <yanli@ucsc.edu, elliot.li.tech@gmail.com>,
# Department of Computer Science, Baskin School of Engineering.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the Storage Systems Research Center, the
#       University of California, nor the names of its contributors
#       may be used to endorse or promote products derived from this
#       software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# REGENTS OF THE UNIVERSITY OF CALIFORNIA BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
set -e -u

echo "Not tested yet. Use at your own risk!"

SRPM=$1
LUSTRE_SRC=$2
RPMBUILD_ROOT=/root/rpmbuild/

rpm -ihv "$SRPM"
cd "${RPMBUILD_ROOT}"
rpmbuild -bp --target=`uname -m` ./SPECS/kernel.spec

cd "${RPMBUILD_ROOT}/BUILD"/kernel*/linux*
cp "${2}/lustre/kernel_patches/kernel_configs/kernel-2.6.32-2.6-rhel6-x86_64.config" .config
make oldconfig || make menuconfig
make include/asm
make include/linux/version.h
make SUBDIRS=scripts
make include/linux/utsrelease.h
# the following step is missing from the official guide
make prepare
make rpm
