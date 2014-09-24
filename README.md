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

# 说明文档
### 所需条件
数据库已经存在linux函数列表

## 文件夹内容
get_diff_SQL 把diff结果放入数据库的脚本

merge_graph  生成不同的graph图，合并，附加差异的脚本

draw_SVG_workplace  画SVG图的工作位置

function_diff  画函数差异html的脚本


## 部署画图所需的基础：Mkdiff.rb执行下面的步骤

### 一、使用git diff
获取源代码下两版本差异，保存至文件con，放置工作目录下

### 二、将其中增加减部分分割
运行./simplify.sh con > con1

然后运行

 cat con1|cut -d ' ' -f 1 > input1
 
 cat con1|cut -d ' ' -f 2 > input2
 
input1中是＋的内容，也就是后面的版本多的部分

input2中是－的内容，也就是前面的版本多的部分

### 三、获取文件增减数目
运行ruby rpath.rb con > rpath

运行ruby cpath.rb rpath diffpath_linux-3.5.4_linux-3.8（ruby cpath.rb rpath 存入差异数据库表）

路径差异信息保存完毕

### 四、获取有差异的函数名，并存入路径
运行ruby rfile.rb linux3.8test diff_linux-3.5.4_linux-3.8（ruby rfile.rb 比较的版本1的函数定义列表 存入差异数据库表）

运行ruby wsql.rb linux3.5.4test diff_linux-3.5.4_linux-3.8（ruby wsql.rb 比较的版本2的函数定义列表 存入差异数据库表）

## 画差异图

### 一、生成两个希望比较的graph
格式：
ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 /home/jdi/ysx/new/ -d mm -o /home/jdi/ysx/plugin/aaa.graph http://124.16.141.130/lxr/watchlist linux-3.5.4 x86_32 http://124.16.141.130/lxr/call real

ruby 20140623-callgraph-sql_e-服务器测试脚本.rb -2 /home/jdi/ysx/new/ -d mm -o /home/jdi/ysx/plugin/ccc.graph http://124.16.141.130/lxr/watchlist linux-3.8 x86_32 http://124.16.141.130/lxr/call real

### 二、合并排序两个graph
ruby graphsort.rb aaa.graph > aaa1.graph

ruby graphsort.rb ccc.graph > ccc1.graph

ruby function_call.rb ccc1.graph aaa1.graph > zzz.graph

### 三、生成SVG图
将结果放到getFileName.rb同目录下

ruby getFileName.rb

## 比较函数内容

### 一、将rfun.rb和diff2html.py放入存放源代码的目录下
格式：ruby rfun.rb 函数路径 函数名 源代码目录 版本1 版本2 输出html路径

ruby rfun.rb arch/x86/kernel/cpu/mcheck/mce.c machine_check_poll /home/20140721-gitdiff脚本/src linux-3.8 linux-3.5.4 new.html


