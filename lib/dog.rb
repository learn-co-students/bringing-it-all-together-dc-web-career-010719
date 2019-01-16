require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = <<-SQL
    create table dogs (
      id integer primary key,
      name text,
      breed text
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("drop table dogs;")
  end

  def save
    if self.id == nil
      sql = <<-SQL
      insert into dogs (name, breed) values (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("select last_insert_rowid()")[0][0]
      self
    else
      self.update
    end
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    select * from dogs where id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    select * from dogs where name = ? and breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    # binding.pry
    if dog.empty?
      self.create({name: name, breed: breed})
    else
      self.new_from_db(dog[0])
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    select * from dogs where name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
    update dogs set name = ?, breed = ? where id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
