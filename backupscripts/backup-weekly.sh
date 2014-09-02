#!/bin/bash
source $(dirname "$(realpath "$0")")/backup-config.sh
exec 1>> ${LOG} 2>&1
echo "[" $(date +'%F %T' ) "] Start weekly backup"
# Lower priorities
renice +10 -p $$
ionice -c 2 -n 7 -p $$ -t 1>> ${LOG} 2>&1

BACKUPPATH=/var/backup/data/
OLDHOURS=350
tar --files-from=/var/backup/scripts/filelist.txt --listed-incremental ${BACKUPPATH}weekly/${NAME}-backup-weekly-$(date +%Y%m%d).snar --lzma -cf ${BACKUPPATH}weekly/${NAME}-backup-weekly-$(date +%Y%m%d).tar.lzma
rm -f ${BACKUPPATH}${NAME}-backup-current.snar
ln -s ${BACKUPPATH}weekly/${NAME}-backup-weekly-$(date +%Y%m%d).snar ${BACKUPPATH}${NAME}-backup-current.snar 
tmpwatch -m ${OLDHOURS} ${BACKUPPATH}/weekly
echo "[" $(date +'%F %T' ) "] End weekly backup"

