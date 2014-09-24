require 'find'

require 'pathname'
p = Pathname.new(File.dirname(__FILE__)).realpath
puts p
Find.find('/home/jdi/ysx/plugin') do |path|
	if path.index(".graph")

		dotPath = path.gsub(".graph",".dot")
		tempSvgPath = path.gsub(".graph","_temp.svg")
		svgPath = path.gsub(".graph","_done.svg")
		
	  system "ruby dot.rb #{path} #{dotPath}"
	  system "dot -Tsvg #{dotPath} -o #{tempSvgPath}"
	  system "ruby th_pic.rb #{tempSvgPath} #{svgPath} aaa bbb ccc"
	end
end 

