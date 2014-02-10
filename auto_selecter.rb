#! ruby
# -*- coding: utf-8 -*-

class Sentence
  def initialize info
    @id, @keyword, @question, @sentence = *info
    @id = @id.to_i
    @question = @question.to_i
  end
  attr_reader :id, :keyword, :question, :sentence

  def to_s
    "#{@id} #{@question}"
  end
end

class AutoSelector
  def initialize data_file
    @sentences = open(data_file, "r:utf-8").readlines[1..-1].map{|line|
       Sentence.new(line.chomp.split /\t/)
    }
    kqset = Set.new
    @sentences.each do |s|
      kq = { :k => s.keyword, :q => s.question }
      kqset << kq
    end
    @kidqids = kqset.to_a
    p @kidqids
  end

  def auto_select questions, count
    def auto_select_sub result, sentences, count
      return result
    end
    sentences = @sentences.select{|s| questions.include? s.question}.shuffle
    result = auto_select_sub({}, sentences, count)
    return result.values.flatten
  end
end

