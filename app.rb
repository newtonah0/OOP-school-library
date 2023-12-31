require_relative 'person'
require_relative 'book'
require_relative 'rental'
require_relative 'teacher'
require_relative 'student'
require_relative 'preserve-data/books_manager'
require_relative 'preserve-data/people_manager'
require_relative 'preserve-data/rentals_manager'

class App
  attr_reader :people, :books

  def initialize
    @people = []
    @books = []
    @rentals = []
    @books_manager = BooksManager.new
    @people_manager = PeopleManager.new
    @rental_manager = RentalsManager.new
    load_book_data
    load_rental_data
    load_people_data
  end

  def load_book_data
    @books_manager.load_books_data
    @books = @books_manager.books
  end

  def save_book_data
    @books_manager.save_books
    puts 'Book saved successfully!'
  end

  def load_rental_data
    @rental_manager.load_rental_data
    @rentals = @rental_manager.rentals
  end

  def save_rental_data
    @rental_manager.save_rentals
    puts 'Rental saved successfully!'
  end

  def load_people_data
    @people_manager.load_people_data
    @people = @people_manager.people
  end

  def save_people_data
    @people_manager.save_people
    puts 'person saved successfully!'
  end

  def add_person(person)
    @people << person
  end

  def add_book(book)
    @books << book
  end

  def list_books
    @books.dup
  end

  def list_all_books
    print_items(@books) { |book| book_info(book) }
  end

  def list_all_people
    print_items(@people) { |person| person_info(person) }
  end

  def create_person(is_teacher, id, age, name, specialization: nil)
    person = build_person(is_teacher, id, age, name, specialization)
    add_person(person)
    puts 'Person created successfully...'
    save_people_data
  end

  def create_book(id, title, author)
    book = Book.new(id, title, author)
    add_book(book)
    puts 'Book created successfully...'
    save_book_data
  end

  def create_rental(person_id, book_id, date_str)
    person = find_by_id(@people, person_id)
    book = find_by_id(@books, book_id)

    if person && book
      rental = Rental.new(date_str, book, person)
      @rentals << rental
      puts 'Rental created successfully.'
      save_rental_data
    else
      puts 'Person or book not found.'
    end
  end

  def person_book_numbers
    puts 'Enter the number of the person:'
    person_number = gets.chomp.to_i
    puts 'Enter the number of the book:'
    book_number = gets.chomp.to_i
    [person_number, book_number]
  end

  def valid_numbers?(person_number, book_number)
    people_count = @people.length
    books_count = @books.length
    person_number.between?(1, people_count) && book_number.between?(1, books_count)
  end

  def list_rentals_for_person(person_id)
    person = find_by_id(@people, person_id)
    if person
      person_rentals = @rentals.select { |rental| rental.person == person }
      display_person_rentals(person, person_rentals)
    else
      puts 'Person not found.'
    end
  end

  private

  def find_by_id(collection, id)
    collection.find { |item| item.id == id }
  end

  def print_items(items, &_)
    items.each_with_index { |item, index| puts "#{index + 1}. #{yield(item)}" }
  end

  def build_person(is_teacher, id, age, name, specialization)
    is_teacher ? Teacher.new(id, age, specialization, name) : Student.new(id, age, name)
  end

  def display_person_rentals(person, rentals)
    if rentals.empty?
      puts "No rentals for #{person.name}."
    else
      puts "Rentals for #{person.name}:"
      print_items(rentals) { |rental| "Book: #{book_info(rental.book)}, Date: #{rental.date}" }
    end
  end

  def book_info(book)
    "ID: #{book.id}, Title: #{book.title}, Author: #{book.author}"
  end

  def person_info(person)
    role = person.is_a?(Teacher) ? 'Teacher' : 'Student'
    "ID: #{person.id}, Name: #{person.name}, Age: #{person.age}, Role: #{role}"
  end
end
