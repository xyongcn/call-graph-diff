require 'find'

require 'pathname'
p = Pathname.new(File.dirname(__FILE__)).realpath



system "cd #{p}"
system "./simplify.sh con > con1"
system "cat con1|cut -d ' ' -f 1 > input1 "
system "cat con1|cut -d ' ' -f 2 > input2 "
puts "==========simplify.sh done=========="
system "ruby rfile.rb linux3.8test diff_linux-3.5.4_linux-3.8"
system "ruby wsql.rb linux3.5.4test diff_linux-3.5.4_linux-3.8"
puts "==========writefunction done=========="
system "ruby rpath.rb > rpath"
system "ruby cpath.rb rpath diffpath_linux-3.5.4_linux-3.8"

