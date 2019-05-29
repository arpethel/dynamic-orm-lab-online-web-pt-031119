require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :grade => "INTEGER"
  }
  #
  # ATTRIBUTES.keys.each do |attribute_name|
  #   attr_accessor attribute_name
  # end
  #
  def self.table_name
    "#{self.to_s.downcase.pluralize}"
  end
  #
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{self.table_name} WHERE name = ?
    SQL

    rows = DB[:conn].execute(sql, name)
    self.reify_from_row(rows.first)
  end
  #
  # def self.reify_from_row(row)
  #   self.new.tap do |p|
  #     ATTRIBUTES.keys.each.with_index do |attribute_name, i|
  #       p.send("#{attribute_name}=", row[i])
  #     end
  #   end
  # end
  #
  # def self.create_sql
  #   ATTRIBUTES.collect{|attribute_name, schema| "#{attribute_name}" "#{schema}"}.join(",")
  # end
  #
  # def self.create_table
  #   sql = <<-SQL
  #     CREATE TABLE IF NOT EXISTS #{self.table_name} (
  #       #{self.create_sql}
  #     )
  #   SQL
  #
  #   DB[:conn].execute(sql)
  # end
  #
  # def ==(other_post)
  #   self.id == other_post.id
  # end
  #
  # def save
  #   persisted? ? update : insert
  # end
  #

  # def persisted?
  #   !!self.id
  # end
  #
  def table_name_for_insert
    "#{self.class.table_name}"
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  #
  # def attribute_name_for_insert
  #   ATTRIBUTES.keys[1..-1].join(",")
  # end

  # def insert
  #   sql = <<-SQL
  #     INSERT INTO #{self.class.table_name_for_insert} (#{self.class.attribute_name_for_insert}) VALUES (#{values_for_insert})
  #   SQL
  #   # binding.pry
  #   DB[:conn].execute(sql)
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  # end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    vv = values.join(", ")
    # binding.pry
  end









end
