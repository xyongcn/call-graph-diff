#!/bin/bash -e
INPUTPATH="/home/jdi/ysx/new/"
OUTPUTPATH1="/home/jdi/ysx/new/aaa.graph"
OUTPUTPATH2="/home/jdi/ysx/new/bbb.graph"
OUTPUTPATH3="/home/jdi/ysx/new/"
if [ $# -eq 5 ]
then
	echo "5"
	VER1=$1
	F=$2
	A=$3
	if [ ${4:0-1:1} = "/" ]
	then 
		P0=$(echo $4 | awk -F "/" '{print $(NF-1)}')
	else
		P0=$(echo $4 | awk -F "/" '{print $(NF)}')
	fi	
	VER2=$5
	GRAPHNAME=$OUTPUTPATH3$P0"_"$VER2".graph"
	
	ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $P0 -o $OUTPUTPATH1 http://124.16.141.130/lxr/watchlist $VER1 $A http://124.16.141.130/lxr/call $F
	ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $P0 -o $OUTPUTPATH2 http://124.16.141.130/lxr/watchlist $VER2 $A http://124.16.141.130/lxr/call $F
elif [ $# -eq 6 ]
then
	echo "6"
	VER1=$1
	F=$2
	A=$3
	if [ ${4:0-1:1} = "/" ]
	then 
		P0=$(echo $4 | awk -F "/" '{print $(NF-1)}')
	else
		P0=$(echo $4 | awk -F "/" '{print $(NF)}')
	fi
	if [ ${5:0-1:1} = "/" ]
	then 
		P0=$(echo $5 | awk -F "/" '{print $(NF-1)}')
	else
		P0=$(echo $5 | awk -F "/" '{print $(NF)}')
	fi
	VER2=$6
	GRAPHNAME=$OUTPUTPATH3$P0"_"$P1"_"$VER2".graph"
	ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $P0 $P1 -o $OUTPUTPATH1 http://124.16.141.130/lxr/watchlist $VER1 $A http://124.16.141.130/lxr/call $F
	ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 $INPUTPATH -d $P0 $P1 -o $OUTPUTPATH2 http://124.16.141.130/lxr/watchlist $VER2 $A http://124.16.141.130/lxr/call $F
else 
	echo "wrong count of argv"
	exit 0
fi

out_graph1=$OUTPUTPATH1"t"
out_graph2=$OUTPUTPATH2"t"

diffsql="diff_"$VER1"_"$VER2
diffpathsql="diffpath_"$VER1"_"$VER2

ruby graphsort.rb $OUTPUTPATH1 > $out_graph1
ruby graphsort.rb $OUTPUTPATH2 > $out_graph2

ruby function_call.rb $out_graph1 $out_graph2 $diffsql $diffpathsql > $GRAPHNAME

echo $GRAPHNAME
ruby plugin/getFileName.rb $GRAPHNAME

