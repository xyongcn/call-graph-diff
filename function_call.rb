require 'find'
require 'mysql'

$mydb=Mysql.connect('localhost', 'cgrtl', '9-410', 'callgraph')
$sql_fdifflist = ""
$sql_filedifflist = ""
$addline_num = ""
$subline_num = ""
$filenum = ""


filename=""
filename=Array.new(10)
i=0
$maxpercent = 0
$percent = 0
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
def finddir(path)
	if path.index(".c")==nil
		path = path + "/"
	end
	rd=$mydb.query("SELECT DISTINCT addline,subline,num FROM `#{$sql_filedifflist}` WHERE path = \"#{path}\"")
		rd.each_hash do |row1|
		$addline_num = row1['addline']
		$subline_num = row1['subline']
		$filenum = row1['num']
		return 1
	end
	return 0
end 
def findfun(f_dfile,f_name)
	rd=$mydb.query("SELECT DISTINCT addline,subline,num FROM `#{$sql_fdifflist}` WHERE path = \"#{f_dfile}\" and fname = \"#{f_name}\" ")
	rd.each_hash do |row1|
		$addline_num=row1['addline']		
		$subline_num=row1['subline']
		$filenum = row1['num']
		return 1
	end
	return 0
end 
def func(str)
	pos_c = str.rindex(".c")
	pos_x = str.rindex("/")
	if pos_x == nil
		return finddir(str)
	elsif pos_c == nil
		return finddir(str)
	elsif pos_x < pos_c
		return finddir(str)
	elsif pos_x > pos_c#xx.c/ff
		
		path = str.slice(0..pos_x-1)
		name = str.gsub(path+'/',"")
		return findfun(path,name)
	end
	#puts $addline_num
	#puts $subline_num
end 
def modify_node(str)
	tip = str.split("\"")
	#puts tip[3]	
	time = tip[3].slice(/[0-9]+/)

	temp = ($percent*100).to_i
	newtip = "#{time},+#{$addline_num},-#{$subline_num},#{temp}%"
	str = str.gsub(tip[3],newtip)
	return str
end
def compute_max(f0,f1)
	
	file0 = File.new(f0,"r")
	file1 = File.new(f1,"r")

	i=0
	while i < 4
	
		line0 = file0.gets
		line1 = file1.gets
		i=i+1
	end



	while line0.index("->") == nil

		temp0 = line0.split(/\[/)		
		temp0[0] = temp0[0].gsub("\"","")	

		flag = func(temp0[0]) #flag is judge "have diff"
		if flag == 0
			$percent = 0
		elsif $filenum != 0
			$percent = ($addline_num.to_i + $subline_num.to_i)/$filenum.to_f
		end
		if $percent > 1
			$percent = 1.0
		end
		if $maxpercent < $percent 
			$maxpercent = $percent
		end
		line0 = file0.gets
		#puts temp0[0],$percent
	end
	while line1.index("->") == nil       	 	
	
		temp1 = line1.split(/\[/)
		temp1[0] = temp1[0].gsub("\"","")

		flag = func(temp1[0])
		if flag == 0
                        $percent = 0
		elsif $filenum != 0
			$percent = ($addline_num.to_i + $subline_num.to_i)/$filenum.to_f
		end
		if $percent > 1
			$percent = 1.0
		end
		if $maxpercent < $percent 
			$maxpercent = $percent
		end
		line1 = file1.gets
		
	end
	if $maxpercent > 1
	#	puts $maxpercent
		$maxpercent = 1.0
	end
#	puts $maxpercent
end


ARGV.each do|arg|
filename[i]=arg
i=i+1
end
$sql_fdifflist = ARGV[2]
$sql_filedifflist = ARGV[3]
#puts $sql_fdifflist,$sql_filedifflist
compute_max(filename[0],filename[1])
file0 = File.new(filename[0],"r")
file1 = File.new(filename[1],"r")
#wfile = File.new(filename[2],"w") 

line0 = file0.gets
line1 = file1.gets

i=0
while i < 3
	puts line0
	line0 = file0.gets
	line1 = file1.gets
	i=i+1
end
while (line0.index("->") == nil) && (line1.index("->") == nil)
	
	temp0 = line0.split(/\[/)		
	temp1 = line1.split(/\[/)
	
	temp0[0] = temp0[0].gsub("\"","")	
	temp1[0] = temp1[0].gsub("\"","")


	if (temp0[0] <=> temp1[0]) == 0
		flag = func(temp0[0])
		
		if $filenum != 0
			$percent = ($addline_num.to_i + $subline_num.to_i)/$filenum.to_f
			if $percent > 1.0
				$percent = 1.0
			end
		elsif flag == 0
			$percent = 0
		else
			$percent = 1.0
		end
		line0 = modify_node(line0)
                $addline_num = 0
                $subline_num = 0
		$filenum = 0
		
		if $percent < ($maxpercent * 0.2)
			line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=\"#DDDDDD\"")
		elsif $percent < ($maxpercent * 0.4)
			line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=\"#BBBBBB\"")
		elsif $percent < ($maxpercent * 0.6)
			line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=\"#999999\"")
		elsif $percent < ($maxpercent * 0.8)
			line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=\"#777777\"")
		else
			line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=\"#555555\"")
		end


		puts line0
		line0 = file0.gets
		line1 = file1.gets
	elsif (temp0[0] <=> temp1[0]) > 0 #把后一个版本的顶点值换掉
		func(temp1[0])
		$percent = 1
		line1 = modify_node(line1)
		$addline_num = 0
                $subline_num = 0
		$filenum = 0
		line1 = line1.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=green")
		puts line1
		line1 = file1.gets
	end
	
	if (temp0[0] <=> temp1[0]) < 0
		func(temp0[0])
		$percent = 1
                
		
		line0 = modify_node(line0)
		$addline_num = 0
                $subline_num = 0
		$filenum = 0
		
		line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=red")
		puts line0
		line0 = file0.gets
	end
end

while line0.index("->") == nil
	func(temp0[0])
	$percent = 1 
	line0 = modify_node(line0)
	$addline_num = 0
        $subline_num = 0
	
	line0 = line0.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=red")
	puts line0
	line0 = file0.gets
end
while line1.index("->") == nil
	func(temp1[0])
	$percent = 1
	line1 = modify_node(line1)
	line1 = line1.gsub(/color=(cyan1|orchid2|gray|red|green|yellow|thistle|lightcoral|cyan4|orange)/,"color=green")
	$addline_num = 0
        $subline_num = 0
	puts line1
	line1 = file1.gets
end
while (line0.index("}") == nil) && (line1.index("}") == nil)

	temp0 = line0.split(/\[/)		
	temp1 = line1.split(/\[/)

	if (temp0[0] <=> temp1[0]) == 0
		lab0 = temp0[1].split(/"/)
		lab1 = temp1[1].split(/"/)
		
		num0 = lab0[1].split(/,/)
		num1 = lab1[1].split(/,/)

		snum = num1[0].to_i - num0[0].to_i
		dnum = num1[1].to_i - num0[1].to_i
		#green or red
		
		str = "#{num0[0]}(#{snum}),#{num1[0]}(#{dnum})"
		
		newline = line0.gsub(lab0[1],str)

		if snum > 0
			newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=green")
		elsif snum < 0
			newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=red")
		else
			newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=black")
		end
		puts newline
		line0 = file0.gets
		line1 = file1.gets
	elsif (temp0[0] <=> temp1[0]) > 0 

		lab1 = temp1[1].split(/"/)

		num1 = lab1[1].split(/,/)

		snum = num1[0].to_i
		dnum = num1[1].to_i
		#green
		str = "0(#{snum}),0(#{dnum})"
		
		newline = line1.gsub(lab1[1],str)
		newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=green")
		puts newline
		line1 = file1.gets
	else
		#black
		lab0 = temp0[1].split(/"/)

                num0 = lab0[1].split(/,/)

                snum = num0[0].to_i
                dnum = num0[1].to_i

		str = "#{snum}(0),#{dnum}(0)"
                newline = line0.gsub(lab0[1],str)

                newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=black")
                puts newline
		line0 = file0.gets
	end
end

while line0.index("}") == nil
	#black
	lab0 = temp0[1].split(/"/)

        num0 = lab0[1].split(/,/)

        snum = num0[0].to_i
        dnum = num0[1].to_i

        str = "#{snum}(0),#{dnum}(0)"
        newline = line0.gsub(lab0[1],str)

        newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=black")
        puts newline
	line0 = file0.gets
end
while line1.index("}") == nil

	temp1 = line1.split(/\[/)

	lab1 = temp1[1].split(/"/)

	num1 = lab1[1].split(/,/)

	snum = num1[0].to_i
	dnum = num1[1].to_i
	#green
	str = "0(#{snum}),0(#{dnum})"
		
	newline = line1.gsub(lab1[1],str)
	newline = newline.gsub(/color=(black|red|blue|green|lightsalmon4|deepskyblue4|indigo|gray|chocolate|magenta)/,"color=green")
	puts newline

	line1 = file1.gets
end
puts "}"

