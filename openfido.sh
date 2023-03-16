#!/bin/sh
#
# GridLAB-D environment for OpenFIDO
#

TEMPLATE=electrification

error()
{
    echo '*** ABNORMAL TERMINATION ***'
    echo 'See error Console Output stderr for details.'
    echo "See https://github.com/openfido/electrification for help"
    exit 1
}

trap on_error 1 2 3 4 6 7 8 11 13 14 15

set -x # print commands
set -e # exit on error
set -u # nounset enabled
shopt -s extglob

export OG_PATH=$PWD
cd $OPENFIDO_INPUT
if [ -f "$OPENFIDO_INPUT/config.csv" ]; then 
    echo 'Adding config CSV conversion file'
    gridlabd "$OG_PATH/config-csv-convert.glm"
    if [ ! -f "$OPENFIDO_INPUT/weather.glm" ]; then 
        WEATHER=$(grep ^WEATHER, "$OPENFIDO_INPUT/config.csv" | cut -f2- -d, | tr ',' ' ')
        gridlabd weather get $WEATHER
        # echo "#weather get $WEATHER" > "$OPENFIDO_INPUT/weather.glm"
    fi
    rm -rf "$OPENFIDO_INPUT/config.csv"
fi
cd - 

if [ ! -f "/usr/local/bin/gridlabd" ]; then
    echo "ERROR [openfido.sh]: '/usr/local/bin/gridlabd' not found" > /dev/stderr
    error
elif [ ! -f "$OPENFIDO_INPUT/gridlabd.rc" ]; then
    OPTIONS=$(cd $OPENFIDO_INPUT; ls -1 | tr '\n' ' ')
    if [ ! -z "$OPTIONS" ]; then
        echo "WARNING [openfido.sh]: '$OPENFIDO_INPUT/gridlabd.rc' not found, using all input files by default" 
    else
        echo "ERROR [openfido.sh]: no input files" > /dev/stderr
        error
    fi
else
    OPTIONS=$(cd $OPENFIDO_INPUT ; cat gridlabd.rc | tr '\n' ' ')
fi

echo '*** INPUTS ***'
ls -l $OPENFIDO_INPUT

if [ -f template.rc ]; then
    TEMPLATE_CFG=$(cat template.rc | tr '\n' ' ' )
else
    TEMPLATE_CFG=""
fi

cd $OPENFIDO_OUTPUT
cp -R $OPENFIDO_INPUT/* .
ls -l $OPENFIDO_OUTPUT
( gridlabd template $TEMPLATE_CFG && gridlabd template get $TEMPLATE && gridlabd --redirect all $OPTIONS -t $TEMPLATE  ) || error

echo '*** OUTPUTS ***'
ls -l $OPENFIDO_OUTPUT

echo '*** RUN COMPLETE ***'
echo 'See Data Visualization and Artifacts for results.'

echo '*** END ***'
