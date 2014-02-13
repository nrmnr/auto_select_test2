#! ruby
# -*- coding: utf-8 -*-

require "./auto_selecter"

def puts_sentences status, selected, overlap
  if status
    puts overlap
    puts selected.map{|s| s.to_s}.join(" / ")
  else
    puts "not detected."
  end
end

task :default do
  rs = AutoSelector.new "testdata.txt"
  puts_sentences(*(rs.auto_select [1001,1002], [3,3]))
  puts_sentences(*(rs.auto_select [1002,1004], [5,3]))
  puts_sentences(*(rs.auto_select [1001,1002], [5,5]))
  puts_sentences(*(rs.auto_select [1003,1004], [5,3]))
end
