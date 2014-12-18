
require 'mysql'

def find(s,b) 
	b=b[0]
	i=0 
	s.each_byte do|c| 
		if b==c
			i+=1
		end
	end 
	return i 
end

Path=ARGV[0]
VER1=ARGV[1]
VER2=ARGV[2]
pos=ARGV[3]

tablename = "diffpath_#{VER1}_#{VER2}"
dbh = Mysql.real_connect("localhost", "cgrtl", "9-410", "callgraph")

long=Path.length

Path1=Path
if Path.rindex("/") == long-1
	Path1=Path.slice(0..long-2)
end
outfile=Path1.gsub("/","_")

outpath=pos+"diffe_#{VER1}_#{VER2}/#{outfile}.html"

write = File.new(outpath,"w+")


count=find(Path1,"/")
#puts count
#path end no "/"

write.syswrite "<html>\n"
write.syswrite "	<body>\n"
write.syswrite "		<table border=\"1\">\n"
write.syswrite "			<tr>\n"
write.syswrite "				<td>Path</td><td>Subline</td><td>Addline</td>\n"
write.syswrite "			</tr>\n"


res = dbh.query("select subline,addline,path from  `#{tablename}`  where path like '#{Path1}/%' or path = '#{Path1}' or path = '#{Path1}/'")
res.each_hash do |row|
	
	path=row["path"]
	flag=0
	subcount=find(path,"/")
	if path == Path1 or path == "#{Path1}/"
		flag=1
	elsif subcount ==count or subcount ==count+1
		flag=1
	elsif subcount == count+2 && path.rindex("/")==path.length-1
		flag=1
	end
	if flag==1
		write.syswrite "			<tr>\n"
		sub=row["subline"]
		add=row["addline"]
		write.syswrite "				<td>#{path}</td><td>#{sub}</td><td>#{add}</td>\n"
		write.syswrite "			</tr>\n"
	end
end

write.syswrite "		</table>\n"
write.syswrite "	</body>\n"
write.syswrite "</html>\n"

write.close