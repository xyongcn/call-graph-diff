call-graph-diff
===============

Call graph difference between source code versions

## 功能
 1. 比较两个版本代码的对应函数的差异，并以HTML页面形式展现；
 2. 比较两个版本代码的函数调用关系图的差异，并以SVG图的形式展现；
 
## 相关信息
 1. 函数调用关系图： http://os.cs.tsinghua.edu.cn:280/lxr/call
 2. Trello上的进展情况： https://trello.com/c/53ly4Cm1/16-20140428-git-diff
 3. 

# 说明文档(2014.11.06)
### 所需条件
数据库已经存在linux函数定义列表

linux-3.5.4_R_x86_32_FDLIST

linux-3.8.13_R_x86_32_FDLIST

linux-3.5.4_R_x86_32_SOLIST

linux-3.5.4_R_x86_32_SOLIST5

linux-3.5.4_R_x86_32_DOLIST

linux-3.8.13_R_x86_32_SOLIST

linux-3.8.13_R_x86_32_SOLIST5

linux-3.8.13_R_x86_32_DOLIST

## 部署画图所需的基础：Mkdiff.rb执行下面的步骤

### 一、使用diff
获取源代码下两版本差异，保存至文件con，放置工作目录下

/mnt/freenas/source_code/linux3.8.13

/mnt/freenas/source_code/linux3.5.4

diff -ruNa /mnt/freenas/source_code/linux3.8.13 /mnt/freenas/source_code/linux3.5.4 > con

### 二、将其中增加减部分分割
运行./simplify.sh con > con1

说明：simplify.sh是将最原始生成的差异文件进行预处理，把其中每一段差异的文件名、行号范围、以及增减行数的数目提取出来。存入名为con1的文件中。

然后运行下列语句，对增、减的差异进行分割。

 cat con1|cut -d ' ' -f 1 > input1
 
 cat con1|cut -d ' ' -f 2 > input2
 
input1中是－的内容，也就是前面的版本多的部分

input2中是＋的内容，也就是后面的版本多的部分

### 三、获取文件增减数目
运行ruby rpath.rb  con linux-3.8.13 > rpath

说明：rpath.rb也是对最原始的差异文件con进行处理，要计算出每一个文件中修改的行数，存到rpath中。

运行ruby cpath.rb rpath linux-3.8.13 linux-3.5.4（ruby cpath.rb rpath 存入差异数据库表diffpath_linux-3.8.13_linux-3.5.4）

说明：cpath.rb根据rpath保存的文件差异，来算出对应路径下的差异总和，然后按路径对应差异数目存入数据库中。

路径差异信息保存完毕

### 四、获取有差异的函数名，并存入路径
运行ruby rfile.rb linux-3.8.13 linux-3.5.4（ruby rfile.rb 比较的版本1的函数定义列表 存入差异数据库表diff_linux-3.8.13_linux-3.5.4）

运行ruby wsql.rb linux-3.8.13 linux-3.5.4（ruby wsql.rb 比较的版本2的函数定义列表 存入差异数据库表diff_linux-3.8.13_linux-3.5.4）

说明：rfile.rb从input1中读原版本数据减少的部分，根据函数定义列表找到所改变的函数，存到数据库表中。wsql.rb从input2中读比较版本数据多的部分，去该版本的函数定义列表中找到改变的函数，存入数据库表。

## 画差异图

### 一、生成两个希望比较的graph
格式：
ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 /usr/local/share/cg-rtl/lxr/source1/ -d mm -o /usr/local/share/cg-rtl/lxr/source1/linux-3.8.13/x86_32/real-mm.graph http://124.16.141.130/lxr/watchlist? linux-3.8.13 x86_32 http://124.16.141.130/lxr/call? real

ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 /home/jdi/ysx/new/ -d mm -o /usr/local/share/cg-rtl/lxr/source1/linux-3.5.4/x86_32/real-mm.graph http://124.16.141.130/lxr/watchlist? linux-3.5.4 x86_32 http://124.16.141.130/lxr/call? real

### 二、合并排序两个graph
ruby graphsort.rb aaa.graph > aaa.grapht

ruby graphsort.rb ccc.graph > ccc.grapht

ruby function_call.rb ccc.grapht aaa.grapht > zzz.graph

说明：对两个graph文件分别进行排序，顺序按照字典序，然后相同节点合并，相同的边进行静态函数调用差异计算再合并。然后结果输出到新的graph中

### 三、生成SVG图
将结果放到getFileName.rb同目录下，对graph的矩阵图生成SVG，依次调用dot.rb、th_pic.rb、node.rb、edge.rb、svg.rb，动态菜单模式在该目录下的th_plugin中，script1、layer1是点击菜单，script3、layer3是浮动菜单。

ruby getFileName.rb zzz_done.svg

## 比较函数内容

在目标输出路径要建立“diff_linux-3.8.13_linux-3.5.4/x86_32/”  格式的文件夹，不然会显示没有此文件夹

### 一、将rfun.rb、pathdiff.rb、和diff2html.py放入lxr的目录下
格式：ruby rfun.rb 函数路径 函数名 源代码目录 版本1 版本2 输出html路径

ruby rfun.rb arch/x86/kernel/cpu/mcheck/mce.c /mnt/freenas/source_code /usr/local/share/cg-rtl/lxr/source1/ linux-3.8.13 linux-3.5.4 machine_check_poll

说明：根据路径和函数名取出两个版本的函数部分代码，将其存入临时文件进行diff，结果用diff2html.py显示为html文件。

## 自动部署演示
ruby Mkdiff.rb /mnt/freenas/source_code/ linux-3.8.13 linux-3.5.4 
参数为版本1、版本2、源代码位置
## 自动画图

ruby auto_diff_graph_new.sh  linux-3.8.13 real x86_32 NULL linux-3.5.4 /usr/local/share/cg-rtl/lxr/source1/ 124.16.141.184/lxr 0

ruby auto_diff_graph_new.sh  linux-3.8.13 real x86_32 mm/ tools linux-3.5.4 /usr/local/share/cg-rtl/lxr/source1/ 124.16.141.184/lxr 1

参数依次为：版本1、真实/虚拟机、平台、路径1、（路径2 可选）、版本2 、路径、diff细节位置参数（未添加）、是否放大

### 比较目录及文件
ruby pathdiff.rb arch linux-3.8.13 linux-3.5.4 /usr/local/share/cg-rtl/lxr/source1/

目录路径 版本1 版本2 生成html路径

生成的比较结果在diff_linux-3.8.13_linux-3.5.4文件夹下 函数比较的就是函数名，目录比较的是把路径中/换成_拼接成的。
