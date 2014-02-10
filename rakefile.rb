#! ruby
# -*- coding: utf-8 -*-

require "./auto_selecter"

def puts_sentences sentences
  puts sentences.map{|s| s.to_s}.join("\n")
end

task :default do
  rs = AutoSelector.new "testdata.txt"
  puts_sentences(rs.auto_select [1001,1002], 3)
end
