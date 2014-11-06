require 'find'

ver1 = "/mnt/freenas/source-code/"+ARGV[0]
ver2 = "/mnt/freenas/source-code/"+ARGV[1]
system "diff -ruNa #{ver1} #{ver2} > con"
puts "==========diff done=========="
system "./simplify.sh con > con1"
system "cat con1|cut -d ' ' -f 1 > input1 "
system "cat con1|cut -d ' ' -f 2 > input2 "
puts "==========simplify.sh done=========="
system "ruby rfile.rb ARGV[0] ARGV[1]"
system "ruby wsql.rb ARGV[0] ARGV[1]"
puts "==========writefunction done=========="
system "ruby rpath.rb con ARGV[0] > rpath"
system "ruby cpath.rb rpath ARGV[0] ARGV[1]"

