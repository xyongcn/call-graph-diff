require 'find'
#src dir have "/" at the end
ver1 = ARGV[0]+ARGV[1]
ver2 = ARGV[0]+ARGV[2]
system "diff -ruNa #{ver1} #{ver2} > con"
puts "==========diff done=========="
system "./simplify.sh con > con1"
system "cat con1|cut -d ' ' -f 1 > input1 "
system "cat con1|cut -d ' ' -f 2 > input2 "
puts "==========simplify.sh done=========="
system "ruby rfile.rb #{ARGV[1]} #{ARGV[2]} #{ARGV[0]}"
system "ruby wsql.rb #{ARGV[1]} #{ARGV[2]} #{ARGV[0]}"
puts "==========writefunction done=========="
system "ruby rpath.rb con #{ver1} > rpath"
system "ruby cpath.rb rpath #{ARGV[1]} #{ARGV[2]}"

