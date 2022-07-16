#!/bin/bash

WD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export GOPATH=$WD
export GOPATH=${GOPATH#:}
export GOPATH=${GOPATH%:}

export PATH=${PATH#:}
export PATH=${PATH%:}
export PATH=${PATH//:$WD\/bin/}
export PATH=${PATH//$WD\/bin:/}
export PATH=${PATH}:$WD/bin
[ -f .env ] && source .env || true
