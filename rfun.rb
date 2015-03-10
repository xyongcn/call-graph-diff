require 'find'
require 'pathname'
require "mysql"

dbh = Mysql.real_connect("localhost", "cgrtl", "9-410", "callgraph")

input=""
path =""
count1 = 0
count2 = 0
line1 = 0
line2 = 0

ARGV.each do |arg|
input+=arg+" "
end


a=input.split(" ")#a[0] is path ,a[5] is name
src=a[1]
outpath=a[2]
v1=a[3]
v2=a[4]
name=a[5]
if src.rindex('/')!=(src.length+1)
        src=src+"/"
end
if outpath.rindex('/')!=(outpath.length+1)
        outpath=outpath+"/"
end

if "#{name}-"=="-"
#	puts "ruby pathdiff.rb #{a[0]} #{v1} #{v2} #{outpath}"
	system "ruby pathdiff.rb #{a[0]} #{v1} #{v2} #{outpath}"
	exit
end
diffpath=outpath+"diffe_#{v1}_#{v2}/#{name}.diff"
outpath=outpath+"diffe_#{v1}_#{v2}/#{name}.html"


path = Pathname.new(File.dirname(__FILE__)).realpath
#puts src+v1+"/"+a[0]
file1 = File.new(src+v1+"/"+a[0],"r")
file2 = File.new(src+v2+"/"+a[0],"r")
write1 = File.new(name+"_"+v1,"w+")
write2 = File.new(name+"_"+v2,"w+")

filename1 = name+"_"+v1
filename2 = name+"_"+v2

tablename1="`#{v1}_R_x86_32_FDLIST`"
tablename2="`#{v2}_R_x86_32_FDLIST`"

res = dbh.query("select f_dline,f_rline,f_name from " + tablename1 + " where f_dfile = \"#{a[0]}\" and f_name = \"#{name}\"")
                        while row = res.fetch_hash do
                                fdline1 = row["f_dline"].to_i
                                frline1 = row["f_rline"].to_i
			end

res = dbh.query("select f_dline,f_rline,f_name from " + tablename2 + " where f_dfile = \"#{a[0]}\" and f_name = \"#{name}\"")
                        while row = res.fetch_hash do
                                fdline2 = row["f_dline"].to_i
                                frline2 = row["f_rline"].to_i
                        end

puts fdline1,fdline2
=======
a[1]=a[1]+"("


zflag=0
while line = file1.gets
	count1 = count1+1
	
	if count1 == fdline1	
		zflag = 1
	end
	if count1 == frline1
		zflag = -1
	end
	if zflag == 1 or zflag == -1
	flag = line.include?name
	if flag == true
		if line1 == 0
			line1 = count1
		end
		write1.syswrite(line);
	end
	if zflag == -1
		break
	end
	
end
zflag=0
while line = file2.gets
	count2 = count2+1
	if count2 == fdline2
                zflag = 1
        end
	if count2 == frline2
                zflag = -1
        end
	
	if zflag == 1 or zflag == -1
	flag = line.include?name
	if flag == true
		if line2 == 0
			line2 = count2
		end
		write2.syswrite(line);
	end
	if zflag == -1
                break
        end
end
if (fdline1 == nil)
	fdline1 = 0
else
fdline1=fdline1-1
end
if (fdline2 == nil)
        fdline2 = 0
else
fdline2=fdline2-1
end


file1.close
file2.close
write1.close
write2.close

system "diff --unified=50 #{filename1} #{filename2} > #{diffpath}"
if File.new(diffpath).stat.zero?
	diffpath=filename1
end
system "cat #{diffpath} | python diff2html.py #{fdline1} #{fdline2} > #{outpath}"
#system "cat #{diffpath} | python diff2html.py 0 0 > #{outpath}"

system "rm -rf #{filename1}"
system "rm -rf #{filename2}"
line1=line1-1
line2=line2-1

system "cat #{diffpath} | python diff2html.py #{line1} #{line2} > #{outpath}"
#system "rm -rf #{filename1}"
#system "rm -rf #{filename2}"
