#!/usr/bin/ruby -w
require 'find'
require 'pathname'
require 'mysql'
tablename = "diffpath_#{ARGV[1]}_#{ARGV[2]}"
dbh = Mysql.real_connect("localhost", "cgrtl", "9-410", "callgraph")
dbh.query("drop table if exists `#{tablename}`")
dbh.query("create table `#{tablename}`( path char(100),   subline char(10), addline char(10) , num char(10))")

path = Pathname.new(File.dirname(__FILE__)).realpath

file = File.new(path+ARGV[0],"r")

tadd_num=0
tsub_num=0

while line = file.gets
	temp = line.split
	#puts temp
	#write temp[0] into SQL
	dbh.query("insert into `" + tablename +"` VALUES('#{temp[0]}','#{temp[1]}','#{temp[2]}','#{temp[3]}')")
	length = temp[0].rindex("/")

	while length != nil
		temp[0] = temp[0].slice(0..length-1)
		puts "-------"+temp[0]
		flag = 0
		res = dbh.query("select addline,subline,num from  `#{tablename}`  where path = \"#{temp[0]}/\"")
		res.each_hash do |row|
			flag = 1
			puts "update:",temp[1],temp[2],temp[3]
			tsub = row["subline"].to_i + temp[1].to_i
			tadd = row["addline"].to_i + temp[2].to_i	
			tnum = row["num"].to_i + temp[3].to_i	
			puts "=====",row["subline"],row["addline"],row["num"],"====="
			dbh.query("UPDATE `" + tablename +"` SET subline = '#{tsub}',addline = '#{tadd}',num = '#{tnum}' where path = \"#{temp[0]}/\"")
		end
		if flag == 0#
			dbh.query("insert into `" + tablename +"` VALUES('#{temp[0]}/','#{temp[1]}','#{temp[2]}','#{temp[3]}')")
			puts "insert:"+temp[0],temp[1],temp[2]
		end
		length = temp[0].rindex("/")
	end
	
	
	
end




