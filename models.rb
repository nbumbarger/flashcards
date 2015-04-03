require "active_record"

class Category < ActiveRecord::Base
  has_many :questions
  def self.list_all_with_qs
    puts "\n"
    self.all.each do |c|
      puts "##{c.id} #{c.category}; Contains #{c.questions.count} flashcards."
    end
  end

  def self.list_all_with_qs_and_correct_as
    puts "\n"
    self.all.each do |c|
        total_correct = c.questions.where("last_attempt_correct = ?", true).count
      puts "##{c.id} #{c.category}; Contains #{c.questions.count} flashcards. Your current score is #{total_correct} / #{c.questions.count} correct."
    end
  end
end

class Question < ActiveRecord::Base
  has_many :answers
  belongs_to :category

  def self.list_all_with_cats
    Category.all.each do |c|
      puts "#{c.category}:"
      c.questions.each do |q|
        puts "  ##{q.id} #{q.question}"
      end
    end
  end

  def self.list_all_with_cats_and_as
    Category.all.each do |c|
      puts "\n#{c.category}:"
      c.questions.each do |q|
        puts "  ##{q.id} #{q.question}"
        answers = Array.new
        q.answers.each do |a|
          answers << a.answer
        end
        puts "     Answers: #{answers.join(", ")}"
      end
    end
  end

def self.list_all_with_score_summary
    Category.all.each do |c|
      total_correct = c.questions.where("last_attempt_correct = ?", true).count
      puts "\n#{c.category} has #{total_correct} / #{c.questions.count} answered correctly."
      c.questions.each do |q|
        puts "  ##{q.id} #{q.question}. Answered correctly: q.last_attempt_correct."
        answers = Array.new
      end
    end
  end
  
end
class Answer < ActiveRecord::Base
  belongs_to :question
end