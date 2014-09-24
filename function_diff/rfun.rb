require 'find'
require 'pathname'

input=""
path =""


ARGV.each do |arg|
input+=arg+" "
end


a=input.split(" ")#a[0] is path ,a[1] is name
src=a[2]
v1=a[3]
v2=a[4]
outpath=a[5]

if src.rindex('/')!=(src.length+1)
	src=src+"/"
end
path = Pathname.new(File.dirname(__FILE__)).realpath
puts src+v1+"/"+a[0]
file1 = File.new(src+v1+"/"+a[0],"r")
file2 = File.new(src+v2+"/"+a[0],"r")
write1 = File.new(a[1]+"_"+v1,"w+")
write2 = File.new(a[1]+"_"+v2,"w+")

filename1 = a[1]+"_"+v1
filename2 = a[1]+"_"+v2

a[1]=a[1]+"("

while line = file1.gets
	flag = line.include?a[1]
	if flag == true
		write1.syswrite(line);
		while code = file1.gets
			write1.syswrite(code);
			if code[0,1] == "}"
				break 
			end
		end
		break
	end
end

while line = file2.gets
	flag = line.include?a[1]
	if flag == true
		write2.syswrite(line);
		while code = file2.gets
			write2.syswrite(code);
			if code[0,1] == "}"
				break 
			end
		end
		break
	end
end

file1.close
file2.close
write1.close
write2.close

system "git diff #{filename1} #{filename2} | python diff2html.py > #{outpath}"
