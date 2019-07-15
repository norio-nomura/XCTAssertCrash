#!/bin/zsh
function {
    readonly PREFIX="$1"
    mkdir -p "${PREFIX}/include"

    local MIG_FLAGS=(
        -server /dev/stdout
        -sheader /dev/stderr
        -user /dev/null -header /dev/null
    )
    {
    cat <<HEADER | tee /dev/stderr
#ifdef __APPLE__
#import "TargetConditionals.h"
#if TARGET_OS_OSX || TARGET_OS_IOS

HEADER

    mig "${MIG_FLAGS[@]}" <(echo '#include <mach/mach_exc.defs>') | sed 's/"stderr"/"mach_excServer.h"/'

    cat <<TAIL | tee /dev/stderr

#endif /* TARGET_OS_OSX || TARGET_OS_IOS */
#endif /* __APPLE__ */
TAIL
    } > "${PREFIX}/mach_excServer.c" 2> "${PREFIX}/include/mach_excServer.h"

} $0:a:h
