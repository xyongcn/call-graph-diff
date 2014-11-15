

filename=Array.new(10)
line = ""
def find(s,b)
        b=b[0]
        i=0
        s.each_byte do|c|

                if(b==c)
                        i+=1
                end
        end
        return i
end


i = 0
ARGV.each do|arg|
filename[i]=arg
i=i+1
end


file = File.new(filename[0],"r")

line = file.gets
i = 0
while i < 3
        puts line
        line = file.gets
        i=i+1
end
linearray = line
num=1

while line.index("->") == nil
	temp = line.split(/\[/)
	temp[0] = temp[0].gsub("\"","")
	
		linearray = linearray+"`"+line
		num=num+1
		line = file.gets
end
#sort
linearray = linearray.split("`")
linearray.sort!
#puts
#puts lastcount
j = 0
while j < num
	puts linearray[j]
	j=j+1
end

linearray = ""
num=0
lastcount=0
while line.index("}") == nil
	temp = line.split(/\[/)
	if num == 0
		linearray = line	
	else
		linearray = linearray+"`"+line
	end	
	num=num+1
	line = file.gets

end
#sort
linearray = linearray.split("`")
linearray.sort!
#puts
#puts lastcount
j = 0
while j < num
	puts linearray[j]
	j=j+1
end
puts "}"
