#!/bin/bash -e
cd /home/ysxun/call-graph-diff
INPUTPATH="/usr/local/share/cg-rtl/lxr/source1/"
zoom=0
DIFF=""
if [ $# -eq 8 ]
then
	#echo "8"
	VER1=$1
	F=$2
	A=$3
	if [ ${4:0-1:1} = "/" ]
	then 
		P0=${4%?}
		P0=$(echo $P0|sed 's/\//_/g')
		#echo $P0
	else
		P0=$(echo $4|sed 's/\//_/g')
		#echo $P0
	fi	

	if [ "$P0" = "NULL" ]
	then
		P0="root"
	fi
	P1=""

	Path0=$4
	if [ "$Path0" = "NULL" ]
	then
		Path0=""
		Path1=""
	fi
	VER2=$5
	INPUTPATH=$6
	DIFF=$7"/diffe?"
	Further=$7"/call?"

	OUTPUTPATH1=$INPUTPATH$VER1"/"$A"/"$F"-"$P0".graph"
	#echo $OUTPUTPATH1
	if [ ! -f "$OUTPUTPATH1" ]
	then
		ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $Path0 -o $OUTPUTPATH1 $DIFF $VER1 $A $Further $F 
	fi
	OUTPUTPATH2=$INPUTPATH$VER2"/"$A"/"$F"-"$P0".graph"
	if [ ! -f "$OUTPUTPATH2" ]
	then	
		echo "start sec"
		ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $Path0 -o $OUTPUTPATH2 $DIFF $VER2 $A $Further $F
	fi
	if [ $8 -eq 1 ]
	then
		zoom=1
	fi
elif [ $# -eq 9 ]
then
	#echo "9"
	VER1=$1
	F=$2
	A=$3
	if [ ${4:0-1:1} = "/" ]
	then 
		P0=${4%?}
		P0=$(echo $P0|sed 's/\//_/g')
	else
		P0=$(echo $4|sed 's/\//_/g')	
	fi
	if [ ${5:0-1:1} = "/" ]
	then 
		P1=${5%?}
		P1=$(echo $P1|sed 's/\//_/g')
	else
		P1=$(echo $5|sed 's/\//_/g')
	fi
	if [ "$P0" = "NULL" ]
	then
		P0="root"
	fi
	if [ "$P1" = "NULL" ]
	then
		P1="root"
	fi
	VER2=$6
	INPUTPATH=$7
	
	DIFF=$8
	Further=$8"/call?"
	Path0=$4

	
	if [ "$Path0" = "NULL" ] 
	then
		Path0=""
	fi
	Path1=$5
	if [ "$Path1" = "NULL" ]
	then
		Path1=""
	fi

	OUTPUTPATH1=$INPUTPATH$VER1"/"$A"/"$F"-"$P0"-"$P1".graph"
	if [ ! -f "$OUTPUTPATH1" ]
	then
		ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $Path0 $Path1 -o $OUTPUTPATH1 $DIFF $VER1 $A $Further $F 
	fi

	OUTPUTPATH2=$INPUTPATH$VER2"/"$A"/"$F"-"$P0"-"$P1".graph"
	if [ ! -f "$OUTPUTPATH2" ]
	then
		ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $Path0 $Path1 -o $OUTPUTPATH2 $DIFF $VER2 $A $Further $F 
	fi
	P1="-"$P1

	if [ $9 -eq 1 ]
	then
		zoom=1
	fi
else 
	echo "wrong count of argv $#"
	exit 0
fi

out_graph1=$OUTPUTPATH1"t"
out_graph2=$OUTPUTPATH2"t"

pre="URL=\""$7"/diffe?v="$VER1"&f="$F"&a="$A"&depth="$VER2"&"


GRAPHNAME="/usr/local/share/cg-rtl/lxr/source1/diffe_"$VER1"_"$VER2"/"$A"/"$F"-"$P0$P1".graph"
ZOOMNAME="/usr/local/share/cg-rtl/lxr/source1/diffe_"$VER1"_"$VER2"/"$A"/zoom_"$F"-"$P0$P1".graph"

diffsql="diff_"$VER1"_"$VER2
diffpathsql="diffpath_"$VER1"_"$VER2

ruby graphsort.rb $OUTPUTPATH1 > $out_graph1
ruby graphsort.rb $OUTPUTPATH2 > $out_graph2

ruby function_call.rb $out_graph1 $out_graph2 $diffsql $diffpathsql $pre> $GRAPHNAME

#permision
rm $out_graph1
rm $out_graph2
rm $OUTPUTPATH1
rm $OUTPUTPATH2

if [ $zoom -eq 1 ]
then
	if [ "$Path0" = "" -a "$Path1" = "" ]
	then
		echo "wrong amplify"
		exit 0
	fi
	if [ "$Path0" = "" ]
	then
		Path0=$Path1
		Path1="full"
	fi
	if [ "$Path1" = "" ]
	then
		Path1="full"
	fi

	if [ ${Path0:0-1:1} = "/" ]
	then 
		Path0=${Path0%?}
		#echo $Path0
	fi

	if [ ${Path1:0-1:1} = "/" ]
	then 
		Path1=${Path1%?}
		#echo $Path1
	fi

	ruby amplify.rb $GRAPHNAME $ZOOMNAME $zoom $Path0 $Path1
	ruby plugin/getFileName.rb $ZOOMNAME
else
	
	ruby plugin/getFileName.rb $GRAPHNAME
	#echo $svgPath
	#rm $GRAPHNAME
fi
