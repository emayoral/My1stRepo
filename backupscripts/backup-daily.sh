#!/bin/bash
# By Eduardo Mayoral (edu.mayoral@gmail.com) Orig. Dec 2012
# Link on /etc/cron.daily/
BACKUPPATH=/var/backup/data/
DATABASES='wordpress piwik'
BASENAME=XXXX
rpm --query --all --queryformat '%{NAME}\t%{VERSION}\t%{RELEASE}\t%{EPOCH}\t%{ARCH}\t%{INSTALLTIME}\n' > ${BACKUPPATH}rpmlist.txt
mysqldump --defaults-file=/root/.my.cnf --databases ${DATABASES} --triggers --opt --delayed-insert | lzma -c > ${BACKUPPATH}/daily/mysqlDBs-$(date +%Y%m%d).sql.lzma
cp ${BACKUPPATH}${BASENAME}-backup-current.snar ${BACKUPPATH}${BASENAME}-backup-tmp.snar
SNARFILE=$(basename $(readlink ${BACKUPPATH}${BASENAME}-backup-current.snar ) .snar)
tar --absolute-names --files-from=/var/backup/scripts/filelist.txt --listed-incremental ${BACKUPPATH}${BASENAME}-backup-tmp.snar --lzma -cf ${BACKUPPATH}/daily/${BASENAME}-backup-daily-$(date +%Y%m%d)-ref-${SNARFILE}.tar.lzma
rm -f ${BACKUPPATH}${BASENAME}-backup-tmp.snar
OLDESTFILE=$(ls -1t ${BACKUPPATH}/weekly/| tail -1)
find ${BACKUPPATH}daily -type f -a -not -cnewer ${BACKUPPATH}weekly/${OLDESTFILE} -print0 | xargs -0 rm -f 
