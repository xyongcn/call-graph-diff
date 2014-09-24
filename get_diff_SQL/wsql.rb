begin
	tablename = "`#{ARGV[0]}`"
	tablename1 = "`#{ARGV[1]}`"
	require "mysql"
	dbh = Mysql.real_connect("localhost", "cgrtl", "9-410", "callgraph")
rescue MysqlError => e
	print "Error code: ", e.errno, "/n"
	print "Error message: ", e.error, "/n"
end
	i = 0
	flag = 0
	tpath = ""
	tfun = ""
	tvar = 0
	File.open("input2","r") do |file|
	while line  = file.gets
		if line[0,1] == "a" and line.include?".c" and !line.include?"arm" and !line.include?"linux/drivers" and !line.include?"linux/include"
			flag = 1
			l = line.length - 9
			path = "\"%" + line[8,l] + "%\""
			path1 = line[8,l]	
		elsif line[0,1] == "b" and line.include?".c" and !line.include?"arm" and !line.include?"linux/drivers" and !line.include?"linux/include"
			flag = 1
                        l = line.length - 9
                        path = "\"%" + line[8,l] + "%\""
                        path1 = line[8,l]
                elsif flag == 1 and line[0,1] != "a" and line[0,1] != "b"
                        tmp1 = line[1,15].split(",")
                        line_d = tmp1[0].to_i + 2
                        line_r = line_d + tmp1[1].to_i - 2
                        varnum = file.gets.to_i
                        #printf "%s %d %d\n",path,line_d,line_r
                        #数据库检索
                        res = dbh.query("select startline,endline,name from " + tablename + " where startline like " + path)
                        while row = res.fetch_hash do
				f_dline = row["startline"].split(":")[1].to_i
				f_rline = row["endline"].split(":")[1].to_i
                        	#printf "%d %d\n ",f_dline,f_rline
			        if line_d >= f_dline and  line_r <= f_rline
                                        printf "--%s %s %d\n",path1,row["name"],varnum

					if tpath == ""
                                                tpath = path1
                                                tfun = row["name"]
                                        end
                                        if tpath == path1 and tfun == row["name"]
                                                tvar = tvar + varnum
                                        elsif tpath != ""
						flag1 = 0						
						res2 = dbh.query("SELECT * FROM " + tablename1 + " where path = '" + tpath + "' and fname = '" + tfun +"'")
						res2.each_hash do |row1|
							flag1 = 1
							dbh.query("UPDATE " + tablename1 +" SET addline = \"" + tvar.to_s + "\" where path = '" + tpath + "' and fname = '" + tfun + "'")
						end
						if flag1 == 0
                                                	dbh.query("insert into " + tablename1 +" VALUES('" + tpath + "','" + tfun + "','" + tvar.to_s + "','0','0')")
						end
                                                tvar = varnum
                                                tpath = path1
                                                tfun = row["name"]
                                        end
					

                                elsif (line_d <= f_dline and  line_r > f_rline) or (line_d < f_dline and line_r >= f_rline)
					printf "++%s %s %d\n",path1,row["name"],f_rline - f_dline
					tvar1 = f_rline - f_dline
					flag1 = 0						
					res2 = dbh.query("SELECT * FROM " + tablename1 + " where path = '" + path1 + "' and fname = '" + row["name"] +"'")
					res2.each_hash do |row1|
						flag1 = 1
						dbh.query("UPDATE " + tablename1 +" SET addline = '" + tvar.to_s + "' where path = '" + path1 + "' and fname = '" + row["name"] + "'")
					end
					if flag1 == 0 
						dbh.query("insert into " + tablename1 +" VALUES('" + path1 + "','" + tfun + "','" + tvar1.to_s + "','0','0')")
					end
					
				end
			end
		else flag = 0
		end
		#i = i + 1
		#if i % 100 == 0
		#	puts i/100
		#end

	end


	dbh.close
end
