#!/bin/bash
FILENAME="$1"
DIFF="diff"
LN=0
LS=0
FLAG=0

#function while_read_bottm(){

	while read -r LINE
	do
	VALUE="${LINE:0:4}"
	if [ "$VALUE" = "$DIFF" ]
	then	
		if [ $FLAG -eq 1 ]
		then
			echo "$LN $LS"
			FLAG=0
		fi
		echo ${LINE:10}
	else	if [ "${LINE:0:2}" = "@@" ]
     		then
			if [ $FLAG -eq 1 ]
			then 
				echo "$LN $LS"
				FLAG=0
			fi
			echo ${LINE:3:21}
			LN=0
			LS=0
		else	if [ "${LINE:1:1}" != "-" ]&&[ "${LINE:0:1}" = "-" ]
			then
				LN=$((LN+1))
				FLAG=1
				#echo $LN
			else 	if [ "${LINE:1:1}" != "+" ]&&[ "${LINE:0:1}" = "+" ]
				then
					LS=$((LS+1))
					FLAG=1
				#echo $LN
				fi
			fi
		fi
	fi
	done < $FILENAME
        echo "$LN $LS"
#}
