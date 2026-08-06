#!/bin/bash

# openSUSE's Plymouth initrd generator still asks Dracut for label.so, while
# the label package installs label-pango.so. Ensure that the actual Pango label
# plugin and its shared-library dependencies are present for password prompts.

check() {
    return 0
}

depends() {
    echo plymouth
}

install() {
    inst_libdir_file "plymouth/label-pango.so"
}
