#!/bin/bash
# Script de limpieza de archivos temporales del plugin "assignfeedback_editpdf"
# Basado en https://moodle.org/mod/forum/discuss.php?d=412169#p1701840
# Autor: Paul Bernal <paul.bernal@cedia.org.ec>
# @id:   20210702

mpath=$(dirname "${BASH_SOURCE[0]}")
sname=$(basename "${0}")
user=apache
editpdffiles=$mpath/$sname.list
tmpfile=$mpath/$sname.tmp
logfile=$mpath/$sname.log

cd $mpath
for cat in $(/usr/bin/sudo -u $user /usr/local/bin/moosh category-list | awk {'print $1'} | grep -v id); do
	echo "CAT: $cat"
	/usr/bin/sudo -u $user /usr/local/bin/moosh course-list -c $cat | awk -F, '{ print $1 }' | tr -d \" >$tmpfile

	rm -f $editpdffiles 2>/dev/null
	i=0
	while read -r cid; do
		i=$((i + 1))
		[ $i -eq 1 ] && continue;
		echo -n -e "CID: ${cid}                                        \r"
		/usr/bin/sudo -u $user /usr/local/bin/moosh file-list course=$cid \
			| grep -e "assignfeedback_editpdf" \
			| grep -v -e ":stamps:" \
			>>$editpdffiles
	done < $tmpfile
	if [ -f $editpdffiles ]; then
		echo $(date +'%c') - CAT:$cat - Encontradas $(wc -l $editpdffiles|awk {'print $1'}) ocurrencias >> $logfile
		cat $editpdffiles | /usr/bin/sudo -u $user /usr/local/bin/moosh -n file-delete -s
	fi
done
cd -

rm -f $editpdffiles $tmpfile

