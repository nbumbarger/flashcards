require "active_record"
require "pry"
require_relative "models.rb"
require_relative "migration"
require_relative 'read_char'

class Run
  def initialize
    #Set up ActiveRecord logger
    #ActiveRecord::Base.logger = Logger.new(STDOUT)

    #Connect to flashcards db
    ActiveRecord::Base.establish_connection(
      :adapter => "postgresql",
      :host => "localhost",
      :database => "flashcards"
    )

    #Migrate demonstration data
    SetupFlashcards.revert_tables
    SetupFlashcards.create_tables
    SetupFlashcards.seed_tables

    #Start UI loop
    main_menu
  end

  #Translate category id # to category string
  def catid_to_s(id)
    cat_translation = Hash.new
    Category.all.each{ |c| cat_translation[c.id] = c.category}
    return cat_translation[id]
  end

  #Clear screen and print common headers
  def clear_and_print_header(submenu = "Sub Menu", return_function = "Back", line_length = 65)
    head_padding = "-" * (line_length - (30 + return_function.length))
    subhead_padding = "-" * (line_length - (3 + submenu.length))
    system "clear"
    puts "|-Flashcard Tool #{head_padding} Return-key: #{return_function}"
    puts "|-#{submenu} #{subhead_padding}"
  end

  #Print an informational footer containing the running score
  def print_score_footer(current_cat = "All", current_score = 0, total_points = 0, line_length = 65)
    foot_padding = "-" * (line_length - (16 + current_cat.length + current_score.to_s.length + total_points.to_s.length))
    puts "|#{foot_padding} Score in #{current_cat}: #{current_score} / #{total_points}"
  end

  def main_menu
    loop do
      system "clear"
      puts "|-Flashcard Tool ------------------- Escape-key: Quit application"
      puts "|-Main Menu -----------------------------------------------------\n\n"
      puts "1) Play Flashcard Quiz"
      puts "3) Manage Flashcards"
      puts "3) Manage Categories"
      puts "4) View/Reset Statistics"
      puts "ESC) Quit applicat1ion"
      key = read_char
      case key
        when "1"
          quiz_menu
        when "2"
          manage_fcs_menu
        when "3"
          manage_cats_menu
        when "4"
          statistics_menu
        when "\e"
          puts "Goodbye"
          exit
      end
    end
  end

  def quiz_menu
    clear_and_print_header(submenu = "Flashcard Quiz", return_funtion = "Enter")
    puts "\nWelcome to the quiz. Enter the # of the category you would like to be quized on."
    puts "See the 'View/Reset Statistics' to reset your running totals."
    Category.list_all_with_qs_and_correct_as
    quiz_cat = Category.find(gets.chomp)
    cat_questions = quiz_cat.questions
    total_qs = quiz_cat.questions.count
    if total_qs > quiz_cat.questions.where("last_attempt_correct = ?", true).count
      puts "\nWould you like to be quized on all questions, or only the ones you haven't answered correctly yet?"
      puts "Press Return for all, or 'c' for only questions that haven't been answered correctly."
      if gets.chomp.downcase == "c"
        cat_questions = quiz_cat.questions.where("last_attempt_correct = ?", false)
      end
    end
    for q in cat_questions
      clear_and_print_header(submenu = "Flashcard Quiz::#{quiz_cat.category}", return_funtion = "Enter")
      puts "\nPlease enter your answer to the following question:"
      puts "#{q.question}\n\n"
      print_score_footer(
             current_cat = quiz_cat.category,
             current_score = quiz_cat.questions.where("last_attempt_correct = ?", true).count,
             total_points = total_qs)
      user_answer = gets.chomp
      acceptable_answers = Array.new
      q.answers.each do |a|
        acceptable_answers << a.answer
      end
      if acceptable_answers.include?(user_answer.downcase)
        puts "\nCorrect!"
        attempts = q.attempts + 1
        q.update(attempts: attempts, last_attempt_correct: true)
      else
        puts "\nIncorrect :("
        attempts = q.attempts + 1
        q.update(attempts: attempts, last_attempt_correct: false)
      end
      gets
    end
    clear_and_print_header(submenu = "Flashcard Quiz::#{quiz_cat.category}", return_funtion = "Back")
    current_score = quiz_cat.questions.where("last_attempt_correct = ?", true).count
    puts "\nYou have completed the #{quiz_cat.category} quiz, with a score of #{current_score} out of #{quiz_cat.questions.count}."
    puts "Press Return to go back, or 'a' to try again.\n\n"
    print_score_footer(
             current_cat = quiz_cat.category,
             current_score = current_score,
             total_points = total_qs)
    if gets.chomp == "a"
      quiz_menu
    end
  end

  def manage_fcs_menu
    loop do
      clear_and_print_header(submenu = "Manage Flashcards", return_funtion = "Back")
      puts "\n1) View all flashcards (SPOILER ALERT!)"
      puts "2) Move cards between categories"
      puts "3) Create new flashcard"
      puts "4) Edit a flashcard"
      puts "5) Delete a flashcard"
      key = read_char
      case key
      when "\r"
        return

      when "1"
        #List all cards
        clear_and_print_header(submenu = "Manage Flashcards::View All", return_funtion = "Back")
        Question.list_all_with_cats_and_as
        gets

      when "2"
        #Move cards
        clear_and_print_header(submenu = "Manage Flashcards::Move Cards", return_funtion = "Enter")
        puts "\nEnter the # of the card you'd like to move:\n\n"
        Question.list_all_with_cats
        card = Question.find(gets.chomp)
        clear_and_print_header(submenu = "Manage Flashcards::Move Cards", return_funtion = "Enter")
        puts "\nCard ##{card.id} is categorized under #{catid_to_s(card.category_id)}."
        puts "Enter the # of the category you'd like to move it to:\n\n"
        Category.list_all_with_qs
        card.update(category_id: gets.chomp)
        clear_and_print_header(submenu = "Manage Flashcards::Move Cards", return_funtion = "Back")
        puts "\nQuestion #{card.id} has been moved to the #{catid_to_s(card.category_id)} category."
        gets

      when "3"
        #Create new card
        clear_and_print_header(submenu = "Manage Flashcards::Create New Card", return_funtion = "Enter")
        puts "\nEnter the category # in which to save the new card:\n"
        Category.list_all_with_qs
        new_cat = Category.find(gets.chomp)
        clear_and_print_header(submenu = "Manage Flashcards::Create New Card", return_funtion = "Enter")
        puts "\nEnter a question for the new #{new_cat.category} card:"
        new_q = new_cat.questions.create(
                question: gets.chomp,
                attempts: 0,
                last_attempt_correct: false)
        clear_and_print_header(submenu = "Manage Flashcards::Create New Card", return_funtion = "Enter")
        puts "\nNew question under #{new_cat.category}:"
        puts "  #{new_q.question}:"
        puts "Enter all acceptable answers for the new card, separated by a comma and space ',':"
        new_as = gets.chomp.split(", ")
        new_as.each do |a|
          new_q.answers.create(answer: a)
        end
        clear_and_print_header(submenu = "Manage Flashcards::Create New Card", return_funtion = "Back")
        puts "\nNew question added to #{catid_to_s(new_q.category_id)}:"
        puts "  #{new_q.question}"
        puts "Acceptable answers:"
        new_q.answers.all.each do |a|
          puts "  #{a.answer}"
        end
        gets

      when "4"
        #Edit a card
        clear_and_print_header(submenu = "Manage Flashcards::Edit Card", return_funtion = "Enter")
        puts "\nEnter the # of the card you wish to edit:\n\n"
        Question.list_all_with_cats
        edit_q = Question.find(gets.chomp)
        clear_and_print_header(submenu = "Manage Flashcards::Edit Card", return_funtion = "Enter")
        puts "\nExisting question:"
        puts "#{edit_q.question}:"
        puts "\nEnter new content, or press Return to leave the question as-is:"
        new_q = gets.chomp
        #Update question if user inputs a text string, or skip this step if they don't
        if new_q.empty? == false
          edit_q.update(
            question: new_q,
            attempts: 0,
            last_attempt_correct: false)
        end
        clear_and_print_header(submenu = "Manage Flashcards::Edit Card", return_funtion = "Enter")
        puts "\nExisting question:"
        puts "  #{edit_q.question}:"
        puts "Existing acceptable answers:"
        edit_q.answers.all.each do |a|
          puts "  #{a.answer}"
        end
        puts "\n\nOverwrite all acceptable answers for the card, separated by a comma and space ',',"
        puts "or press Return to leave the answers as-is."
        #Update answers if user inputs a text string, or skip this step if they don't
        new_as = gets.chomp
        if new_as.empty? == false
          new_as = new_as.split(", ")
          edit_q.answers.each do |a|
            a.delete
          end
          new_as.each do |a|
            edit_q.answers.create(answer: a)
          end
        end
        clear_and_print_header(submenu = "Manage Flashcards::Edit Card", return_funtion = "Back")
        puts "\nQuestion edited under #{catid_to_s(edit_q.category_id)}:"
        puts "  #{edit_q.question}"
        puts "Acceptable answers:"
        edit_q.answers.all.each do |a|
          puts "  #{a.answer}"
        end
        gets

      when "5"
        #Delete a card
        clear_and_print_header(submenu = "Manage Flashcards::Delete Card", return_funtion = "Enter")
        puts "\nEnter the card # you wish to delete:\n\n"
        Question.list_all_with_cats
        card = Question.find(gets.chomp)
        card_id = card.id
        card.delete
        clear_and_print_header(submenu = "Manage Flashcards::Delete Card", return_funtion = "Back")
        puts "\nCard ##{card_id} has been deleted."
        gets
      end
    end
  end

  def manage_cats_menu
    loop do
      clear_and_print_header(submenu = "Manage Categories", return_funtion = "Back")
      puts "\n1) View all categories"
      puts "2) Create new category"
      puts "3) Edit a category"
      puts "4) Delete a category"
      key = read_char
      case key
      when "\r"
        #Go back to main menu
        return

      when "1"
        #List all categories
        clear_and_print_header(submenu = "Manage Categories::List All", return_funtion = "Back")
        Category.list_all_with_qs_and_correct_as
        gets

      when "2"
        #Create a new category
        clear_and_print_header(submenu = "Manage Categories::Add Category", return_funtion = "Enter")
        puts "\nEnter a name for the name category:"
        new_cat = Category.create(category: gets.chomp)
        clear_and_print_header(submenu = "Manage Categories::Add Category", return_funtion = "Back")
        puts "\n#{new_cat.category} has been created."
        gets

      when "3"
        #Edit an existing category name
        clear_and_print_header(submenu = "Manage Categories::Delete Category", return_funtion = "Enter")
        puts "\nEnter a category # to rename:"
        Category.list_all_with_qs_and_correct_as
        edit_cat = Category.find(gets.chomp)
        clear_and_print_header(submenu = "Manage Categories::Delete Category", return_funtion = "Enter")
        puts "\nEnter a new name for #{edit_cat.category}:"
        original_name = edit_cat.category
        edit_cat.update(category: gets.chomp)
        clear_and_print_header(submenu = "Manage Categories::Delete Category", return_funtion = "Back")
        puts "\n#{original_name} has been renamed #{edit_cat.category}."
        gets

      when "4"
        #Delete a category
        clear_and_print_header(submenu = "Manage Categories::Delete Category", return_funtion = "Enter")
        puts "\nEnter a category # to delete:"
        Category.list_all_with_qs_and_correct_as
        del_cat = Category.find(gets.chomp)
        del_cat_str = del_cat.category
        del_cat.delete
        clear_and_print_header(submenu = "Manage Flashcards::Delete Category", return_funtion = "Back")
        puts "\nCategory #{del_cat_str} has been deleted."
        gets
      end
    end
  end
  
  def statistics_menu
    #WTF?
    # clear_and_print_header(submenu = "View/Reset Statistics", return_funtion = "Enter")
    # Question.list_all_with_score_summary
  end

end
