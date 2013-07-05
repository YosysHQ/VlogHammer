#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: $0 <job_id>" >&2
	exit 1
fi

job="$1"
set -ex --

rm -rf temp/syn_quartus_$job
mkdir -p temp/syn_quartus_$job
cd temp/syn_quartus_$job

cp ../../rtl/$job.v .
/opt/altera/13.0/quartus/bin/quartus_map $job --source=$job.v --family="Cyclone III"
/opt/altera/13.0/quartus/bin/quartus_fit $job
/opt/altera/13.0/quartus/bin/quartus_eda $job --formal_verification --tool=conformal

sed -i 's,^// DATE.*,,;' fv/conformal/$job.vo

mkdir -p ../../syn_quartus
cp fv/conformal/$job.vo ../../syn_quartus/$job.v

sync
echo READY.
