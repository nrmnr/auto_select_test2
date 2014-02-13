#! ruby
# -*- coding: utf-8 -*-

require "./auto_selecter"

def puts_sentences status, selected, overlap, detect_count
  unless status
    puts "not detected."
    puts "detect : #{detect_count}"
    return
  end

  puts "overlaped : #{overlap}"
  overlap = selected.inject(Hash.new(0)){|r, kq|
    k = kq[:k]
    r[k] += 1
    r
  }
  questions = selected.inject({}){|r, kq|
    k = kq[:k]
    q = kq[:q]
    r[q] ||= []
    r[q] << k
    r
  }
  questions.keys.sort.each do |q|
    print "#{q} => "
    print questions[q].map{|k|
      if overlap[k] > 1
        "*#{k}"
      else
        k
      end
    }.join(", ")
    puts ""
  end
  puts "detect : #{detect_count}"
  puts ("-" * 20)
end

task :default do
  rs = AutoSelector.new "testdata.txt"
  puts_sentences(*(rs.auto_select [1001,1002], [3,3]))
  puts_sentences(*(rs.auto_select [1002,1004], [5,3]))
  puts_sentences(*(rs.auto_select [1001,1002], [5,5]))
  puts_sentences(*(rs.auto_select [1003,1004], [5,3]))
end
