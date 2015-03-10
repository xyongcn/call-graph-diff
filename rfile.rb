begin

	tablename = "`#{ARGV[0]}_R_x86_32_FDLIST`"
	tablename1 = "`diff_#{ARGV[0]}_#{ARGV[1]}`"
	
	require "mysql"
	dbh = Mysql.real_connect("localhost", "cgrtl", "9-410", "callgraph")
	dbh.query("drop table if exists #{tablename1}")
	dbh.query("create table #{tablename1}( path char(100), fname char(50), addline char(10), subline char(10),num char(10))")
rescue MysqlError => e
	print "Error code: ", e.errno, "/n"
	print "Error message: ", e.error, "/n"
end
	i = 0
	flag = 0
	tpath = ""
	tfun = ""
	tvar = 0
	File.open("input1","r") do |file|
	while line  = file.gets
		
		
		if line.include?"#{ARGV[0]}" and line.include?".c" and !line.include?"arm" and !line.include?"#{ARGV[0]}/drivers" and !line.include?"#{ARGV[0]}/include"
			flag = 1
			path1 = line.gsub("#{ARGV[2]}#{ARGV[0]}/","");
			path1 = path1.gsub("\n","")	
			path =  path1
			#puts path 
		elsif flag == 1 and !line.include?"#{ARGV[0]}"
                        tmp1 = line[1,15].split(",")
                        line_d = tmp1[0].to_i + 3
                        line_r = line_d + tmp1[1].to_i - 4
                        varnum = file.gets.to_i
                        #printf "%s %d %d\n",path,line_d,line_r
                        #数据库检索
			#puts "select f_dline,f_rline,f_name from " + tablename + " where f_dfile = \"#{path}\""
                        res = dbh.query("select f_dline,f_rline,f_name from " + tablename + " where f_dfile = \"#{path}\"")
                        while row = res.fetch_hash do
				f_dline = row["f_dline"].to_i 
				f_rline = row["f_rline"].to_i
                        	#printf "%d %d\n ",f_dline,f_rline
			        if line_d >= f_dline and  line_r <= f_rline
                                        printf "--%s %s %d\n",path1,row["f_name"],varnum
				        #printf " %s ",tpath
					if tpath == ""
						tpath = path1
						tfun = row["f_name"]
					end
					if tpath == path1 and tfun == row["f_name"]
						tvar = tvar + varnum #add		
					elsif tpath != ""
						tvar1 = f_rline - f_dline
						dbh.query("insert into " + tablename1 +" VALUES('" + tpath + "','" + tfun + "'," + "'0','"+ tvar.to_s + "','"+tvar1.to_s + "')")
						tvar = varnum
						tpath = path1
						tfun = row["f_name"]
					end
					

                                elsif (line_d <= f_dline and  line_r > f_rline) or (line_d < f_dline and line_r >= f_rline)
					printf "++%s %s %d\n",path1,row["f_name"],f_rline - f_dline
			                tvar1 = f_rline - f_dline
					dbh.query("insert into " + tablename1 +" VALUES('" + path1 + "','" + row["f_name"] + "'," + "'0','"+ tvar1.to_s + "','"+tvar1.to_s+"')")
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
