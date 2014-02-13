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
    kqset = Set.new # Keyword - QuestionIDのセット列挙(重複除外)
    keywords_of_question = Hash.new(0) # QuestionごとのKeyword数
    @sentences.each do |s|
      kq = { :k => s.keyword, :q => s.question }
      kqset << kq
      keywords_of_question[s.question] += 1
    end
    # ランダムシャッフルした後，Keywordの少ない順に整列
    @key_qid_pairs = kqset.to_a.shuffle.sort_by{|kq| keywords_of_question[kq[:q]]}
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

