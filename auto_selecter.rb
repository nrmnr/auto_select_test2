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
    @keywords_of_question = Hash.new(0) # QuestionごとのKeyword数
    @sentences.each do |s|
      kq = { :k => s.keyword, :q => s.question }
      kqset << kq
      @keywords_of_question[s.question] += 1
    end
    @key_qid_pairs = kqset.to_a
  end

  def auto_select questions, needs
    # ランダムシャッフルした後，Keywordの少ない順に整列
    key_qid_pairs = @key_qid_pairs.select{|kq|
      questions.include? kq[:q]
    }.shuffle.sort_by{|kq|
      @keywords_of_question[kq[:q]]
    }

    # Keyword列挙
    keywords = key_qid_pairs.inject(Set.new){|r, kq| r << kq[:k]; r}.to_a
    # 必要数合計
    needs_amount = needs.inject(:+)
    # オーバーラップ最小値
    @overlap_min = (keywords.size < needs_amount)? (needs_amount - keywords.size) : 0
    puts "overlap min:#{@overlap_min}"
    # 設問ごと必要数
    question_needs = questions.zip(needs).inject({}){|r, a| r[a[0]] = a[1]; r}
    # 探索
    @detect_count = 0
    status, selected, overlap = detect([], Hash.new(0), key_qid_pairs, 0, question_needs)
    return status, selected, overlap, @detect_count
  end

  def detect current_selected, current_count, key_qid_pairs, index, question_needs
    @detect_count += 1
    # 重複数チェック - 枝刈り
    overlap = count_overlap current_selected
    return false, nil, nil if overlap > @overlap_min

    if detected? current_count, question_needs
      return (overlap <= @overlap_min), current_selected, overlap
    end
    key_qid = key_qid_pairs[index]
    return false, nil, nil if key_qid.nil?
    qid = key_qid[:q]
    return false, nil, nil if current_count[qid] >= question_needs[qid]

    # 選ぶ
    selected = current_selected + [key_qid]
    current_count[qid] += 1
    status1, selected1, overlap1 =
      detect selected, current_count, key_qid_pairs, index+1, question_needs
    return status1, selected1, overlap1 if status1
    # 選ばない
    selected.pop
    current_count[key_qid[:q]] -= 1
    status2, selected2, overlap2 =
      detect selected, current_count, key_qid_pairs, index+1, question_needs

    return status2, selected2, overlap2
  end

  def count_overlap selected
    counts = selected.inject(Hash.new(0)){|r, kq|
      r[kq[:k]] += 1
      r
    }
    return counts.keys.count{|k| counts[k] > 1}
  end

  def detected? current_count, question_needs
    question_needs.keys.each do |q|
      return false if current_count[q] != question_needs[q]
    end
    return true
  end
end

