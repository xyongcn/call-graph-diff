require 'mysql'

Path=ARGV[0]
VER1=ARGV[1]
VER2=ARGV[2]
pos=ARGV[3]

tablename = "diffpath_#{VER1}_#{VER2}"
dbh = Mysql.real_connect("localhost", "cgrtl", "9-410", "callgraph")
long=Path.length
if Path.rindex("/") == long-1
	Path1=Path.slice(0..long-2)
end
outfile=Path1.gsub("/","_")

outpath=pos+"diffe_#{VER1}_#{VER2}/#{outfile}.html"

write = File.new(outpath,"w+")



#path end no "/"

write.syswrite "<html>"
write.syswrite "	<body>"
write.syswrite "		<table>"
write.syswrite "			<tr>"
write.syswrite "				<td>Path</td><td>Subline</td><td>Addline</td>"
write.syswrite "			</tr>"


res = dbh.query("select subline,addline,path from  `#{tablename}`  where path like '#{Path1}/%'")
res.each_hash do |row|
	
	path=row["path"]
	if path
		write.syswrite "			<tr>"
		sub=row["subline"]
		add=row["addline"]
		write.syswrite "				<td>#{path}</td><td>#{sub}</td><td>#{add}</td>"
		write.syswrite "			</tr>"
	end
end

write.syswrite "		</table>"
write.syswrite "	</body>"
write.syswrite "</html>"