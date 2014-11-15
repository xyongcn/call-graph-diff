#!/usr/bin/ruby -w
require 'find'

filename=""
filename=Array.new(10)
i=0
ARGV.each do|arg|
filename[i]=arg
i=i+1
end

$moudle=filename[2].to_i
$path0=filename[3]+"/"
$path1=filename[4]+"/"
s_flag=0
if filename[4]=="full"
   s_flag=1
end
r_filename=filename[0]
w_filename=filename[1]


afile=File.new(r_filename,"r")
wfile=File.new(w_filename,"w")
 while line=afile.gets
    if !line.index("label")
       wfile.puts line
    else
       t_flag=0
       pos=line.index("[label=")
       a_line=line
       a_temp=a_line.slice(0..pos-1)
       if a_temp.index("->")
          b_temp=a_temp.split("->")
          if b_temp[0].index($path0) and b_temp[1].index($path0)
             t_flag=1
          end
          if s_flag==0
            if b_temp[0].index($path1) and b_temp[1].index($path1)
              t_flag=1
            end
            if b_temp[0].index($path0) and b_temp[1].index($path1)
              t_flag=1
            end
           if b_temp[0].index($path1) and b_temp[1].index($path0)
              t_flag=1
            end
     
          end
          
       else
         if a_temp.index($path0)
            t_flag=1
         end    
         if s_flag==0
            if a_temp.index($path1)
              t_flag=1
            end

         end
       end
       if t_flag==1
          wfile.puts line
       end
    end
 end
 afile.close
 wfile.close
