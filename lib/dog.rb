require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("create table if not exists dogs (
      id INTEGER primary key,
      name text,
      breed text
      )")
  end

  def self.drop_table
    DB[:conn].execute("drop table if exists dogs")
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    DB[:conn].execute("select * from dogs where name = ? limit 1", name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    DB[:conn].execute("update dogs set name = ?, breed = ? where id = ?", self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("insert into dogs (name, breed) values (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(breed: breed, name: name)
    dog.save
    dog
  end

  def self.find_by_id(id)
    DB[:conn].execute("select * from dogs where id = ? limit 1", id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("select * from dogs where name = ? and breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = Dog.create(breed: breed, name: name)
    end
    dog
  end

end
