begin
	tablename = "`#{ARGV[1]}_R_x86_32_FDLIST`"
        tablename1 = "`diff_#{ARGV[0]}_#{ARGV[1]}`"

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
		
		if line.include?"#{ARGV[1]}" and line.include?".c" and !line.include?"arm" and !line.include?"#{ARGV[1]}/drivers" and !line.include?"#{ARGV[1]}/include"
			flag = 1
			path1 = line.gsub("/mnt/freenas/source-code/#{ARGV[1]}/","")
                        path1 = path1.gsub("\n","")
                        path =  path1	
		elsif flag == 1 and !line.include?"#{ARGV[1]}"
                        tmp1 = line[1,15].split(",")
                        line_d = tmp1[0].to_i + 3
                        line_r = line_d + tmp1[1].to_i - 3
                        varnum = file.gets.to_i
                        #printf "%s %d %d\n",path,line_d,line_r
                        #数据库检索
		#	puts "select f_dline,f_rline,f_name from " + tablename + " where f_dline = \"#{path}\""
                        res = dbh.query("select f_dline,f_rline,f_name from " + tablename + " where f_dfile = \"#{path}\"")
                        while row = res.fetch_hash do
				f_dline = row["f_dline"].to_i
                                f_rline = row["f_rline"].to_i
                        	#printf "%d %d\n ",f_dline,f_rline
			        if line_d >= f_dline and  line_r <= f_rline
                                        printf "--%s %s %d\n",path1,row["f_name"],varnum

					if tpath == ""
                                                tpath = path1
                                                tfun = row["f_name"]
                                        end
                                        if tpath == path1 and tfun == row["f_name"]
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
                                                tfun = row["f_name"]
                                        end
					

                                elsif (line_d <= f_dline and  line_r > f_rline) or (line_d < f_dline and line_r >= f_rline)
					printf "++%s %s %d\n",path1,row["f_name"],f_rline - f_dline
					tvar1 = f_rline - f_dline
					flag1 = 0						
					res2 = dbh.query("SELECT * FROM " + tablename1 + " where path = '" + path1 + "' and fname = '" + row["f_name"] +"'")
					res2.each_hash do |row1|
						flag1 = 1
						dbh.query("UPDATE " + tablename1 +" SET addline = '" + tvar.to_s + "' where path = '" + path1 + "' and fname = '" + row["f_name"] + "'")
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
