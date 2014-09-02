#!/bin/bash
source $(dirname "$(realpath "$0")")/backup-config.sh
exec 1>> ${LOG} 2>&1
echo "[" $(date +'%F %T' ) "] Start backup"
# Lower priorities
renice +10 -p $$
ionice -c 2 -n 7 -p $$ -t 1>> ${LOG} 2>&1


rpm --query --all --queryformat '%{NAME}\t%{VERSION}\t%{RELEASE}\t%{EPOCH}\t%{ARCH}\t%{INSTALLTIME}\n' | lzma -c > ${BACKUPPATH}daily/rpmlist-$(date +%Y%m%d).txt.lzma
ip address show > ${BACKUPPATH}/ipconfig.txt
ip route show > ${BACKUPPATH}/routeconfig.txt
chkconfig --list --type sysv |  sort | awk '{print "chkconfig " $1 " " substr($5,3,5)}' > ${BACKUPPATH}/serviceconfig.txt


(echo "use mysql ;";
$MYSQLEXEC --defaults-file=/root/.my.cnf -N -e "select concat('show grants for ''', User , '''@''', Host, ''';') from user;" mysql | $MYSQLEXEC --defaults-file=/root/.my.cnf -N mysql | awk '{print $0 " ;"}' ;
echo "flush privileges;" ;) | lzma -c > ${BACKUPPATH}/daily/mysql/CreateUsers-$(date +%Y%m%d).sql.lzma ;

for database in $(echo 'show databases;' | $MYSQLEXEC --defaults-file=/root/.my.cnf -N | sort);
	do
	$MYSQLDUMPEXEC --defaults-file=/root/.my.cnf --no-create-db --single-transaction --master-data=2 --create-options --add-drop-table --extended-insert --hex-blob  --quote-names --host localhost  $database 2>>${LOG}  |  lzma -c > ${BACKUPPATH}daily/mysql/${database}-$(date +%Y%m%d).sql.lzma
	done

/usr/local/bin/mysqladmin --defaults-file=/root/.my.cnf flush-logs

cp ${BACKUPPATH}${NAME}-backup-current.snar ${BACKUPPATH}${NAME}-backup-tmp.snar
SNARFILE=$(basename $(readlink ${BACKUPPATH}${NAME}-backup-current.snar ) .snar)
tar --files-from=/var/backup/scripts/filelist.txt --listed-incremental ${BACKUPPATH}${NAME}-backup-tmp.snar --lzma -cf ${BACKUPPATH}daily/${NAME}-backup-daily-$(date +%Y%m%d)-ref-${SNARFILE}.tar.lzma
rm -f ${BACKUPPATH}${NAME}-backup-tmp.snar
#ln -s ${BACKUPPATH}${NAME}-backup-$(date +%Y%m%d).snar ${BACKUPPATH}${NAME}-backup-current.snar 
OLDESTFILE=$(ls -1t ${BACKUPPATH}/weekly/| tail -1)
find ${BACKUPPATH}daily -type f -a -not -cnewer ${BACKUPPATH}weekly/${OLDESTFILE} -print0 | xargs -0 rm -f 
#tmpwatch 360 ${BACKUPPATH}/daily
echo "[" $(date +'%F %T' ) "] End backup"

