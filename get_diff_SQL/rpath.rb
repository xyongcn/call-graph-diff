#!/usr/bin/ruby -w
require 'find'
require 'pathname'


path = Pathname.new(File.dirname(__FILE__)).realpath

file = File.new(path+ARGV[0],"r")
add_num=0
sub_num=0
flag=0

maxdir = 0
while line = file.gets
	if line.index("diff --git") == 0 
		if flag==1
			#puts line
			#puts path
			path = path.gsub("a/linux/","")
			tnum = path.count "/"
			if maxdir < tnum
				maxdir = tnum
			end
			arr = File.open("linux-3.8/"+path).readlines
			flinenum = arr.size
			puts path + " "+sub_num.to_s+" "+add_num.to_s+" "+flinenum.to_s
		end
		temp = line.split
		path = temp[2]
		add_num=0
		sub_num=0
		flag=1
		
	elsif line.index("-") == 0 and  line.index("--") != 0
		sub_num+=1 
	elsif line.index("+") == 0 and  line.index("++") != 0
		add_num+=1 
	end
end
path = path.gsub("a/linux/","")
arr = File.open("linux-3.8/"+path).readlines
flinenum = arr.size
puts path + " "+sub_num.to_s+" "+add_num.to_s+" "+flinenum.to_s




