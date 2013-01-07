#!/bin/bash
# By Eduardo Mayoral (edu.mayoral@gmail.com) Orig. Dec 2012
# Link on /etc/cron.daily/
BACKUPPATH=/var/backup/data/
BASENAME=XXXX
OLDHOURS=350
tar --absolute-names --files-from=/var/backup/scripts/filelist.txt --listed-incremental ${BACKUPPATH}weekly/${BASENAME}-backup-weekly-$(date +%Y%m%d).snar --lzma -cf ${BACKUPPATH}weekly/${BASENAME}-backup-weekly-$(date +%Y%m%d).tar.lzma
rm -f ${BACKUPPATH}${BASENAME}-backup-current.snar
ln -s ${BACKUPPATH}weekly/${BASENAME}-backup-weekly-$(date +%Y%m%d).snar ${BACKUPPATH}${BASENAME}-backup-current.snar 
tmpwatch -m ${OLDHOURS} ${BACKUPPATH}/weekly
