class SetupFlashcards < ActiveRecord::Migration
  def self.create_tables
    #Set up tables and relationships
    create_table :categories do |column|
    column.string :category
    end
    create_table :questions do |column|
    column.belongs_to :category
    column.text :question
    column.integer :attempts
    column.boolean :last_attempt_correct
    end
    create_table :answers do |column|
    column.belongs_to :question
    column.text :answer
    end
  end
  def self.seed_tables
    #Populate tables with example data
    #Seed General category
    category = Category.create(category: "General")
    question = category.questions.create(
               question: "What type of acid is found in vinegar?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "acetic"},
                 {answer: "acetic acid"}])
    question = category.questions.create(
               question: "What name is given to a word that reads the same both ways?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "palindrome"},
                 {answer: "a palindrome"}])
    question = category.questions.create(
               question: "The nursery rhyme Ring Around the Rosie refers to which major disease outbreak?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "plague"},
                 {answer: "the plague"},
                 {answer: "bubonic plague"},
                 {answer: "the bubonic plague"},
                 {answer: "black death"},
                 {answer: "the black death"},
                 {answer: "yersinia pestis"}])
    #Seed Geography category         
    question = category.questions.create(
               question: "Which river flows through the Grand Canyon?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "colorado"},
                 {answer: "colorado river"},
                 {answer: "the colorado river"}])
    question = category.questions.create(
               question: "On Earth, the lithosphere is broken up into which type of plates?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "tectonic"}])
    #Seed Geography category
    category = Category.create(category: "Geography")
    question = category.questions.create(
               question: "Which is the only borough of New York's that is located on the mainland?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "bronx"},
                 {answer: "the bronx"}])
    question = category.questions.create(
               question: "What is the largest country that the equator passes through?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "brazil"}])
    question = category.questions.create(
               question: "Which river flows through the Grand Canyon?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "colorado"},
                 {answer: "colorado river"},
                 {answer: "the colorado river"}])
    question = category.questions.create(
               question: "On Earth, the lithosphere is broken up into which type of plates?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "tectonic"}])
    #Seed Music category
    category = Category.create(category: "Music")
    question = category.questions.create(
               question: "Who had a hit in the 00s with 'The Fear'?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "lily allen"}])
    question = category.questions.create(
               question: "Who had a hit in the 90s with 'U Can't Touch This'?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "hammer"},
                 {answer: "mc hammer"},
                 {answer: "m.c. hammer"},
                 {answer: "stanley burrell"}])
    question = category.questions.create(
               question: "Who had a best-selling single in 2005 with 'Mockingbird'?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "eminem"},
                 {answer: "slim shady"},
                 {answer: "marshall mathers"}])

    question = category.questions.create(
               question: "Which country does singer Rihanna come from?",
               attempts: 0,
               last_attempt_correct: false)
                 question.answers.create([
                 {answer: "barbados"}])
    end
  def self.revert_tables
    #Erase records
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end