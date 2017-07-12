#!/usr/bin/env ruby

require "active_support/core_ext/string"
require "active_support/core_ext/array"
require "yaml"

USAGE = "convert.rb [dumpfile]"

if ARGV.count != 1
  puts USAGE
  exit 1
else
  dump_file_path = ARGV.first
end

unless File.exists? dump_file_path
  puts "File does not exist: #{dump_file_path}"
  exit 2
end

def work(title, &block)
  print "#{title}... "
  res = block.call

  puts "done"

  res
end

INTEGER_REGEX = /\A\d+\z/.freeze
DATE_TIME_REGEX = /\A\d{4}-\d{2}-\d{2}(\s\d{2}:\d{2}:\d{2}\.\d+)?\z/.freeze

def normalize_attributes(attributes)
  attributes.map do |a|
    if %(t f).include?(a)
      if a == "t"
        true
      else
        false
      end
    elsif a == '\N'
      nil
    else
      a
    end
  end
end


raw_dump = work "reading dump" do
  File.read(dump_file_path)
end

class Record < Struct.new(:table, :values)
  def to_sql(cols)
    v = values[0..cols].dup

    while v.length < cols
      v << nil
    end

    "(#{v.map {|v| format_value(v)}.join(", ")})"
  end

  private
  def format_value(value)
    case value
    when nil
      'NULL'
    when true
      "1"
    when false
      "0"
    else
      v = if value =~ DATE_TIME_REGEX
        value.gsub("\.\d+", "").inspect
      else
        value.inspect
      end
    end
  end
end

class Table
  attr_accessor :name, :attributes, :records

  def initialize(name, attributes)
    self.name = name
    self.attributes = attributes
    self.records = []
  end


  def <<(record)
    @records << record
  end

  def to_sql
    sql = ""
    self.records.in_groups_of(5_000) do |recs|
      sql << "INSERT INTO #{self.name} (#{attributes.map {|a| '`' + a + '`'}.join(", ")}) VALUES "

      sql << recs.compact.map do |r|
        r.to_sql(attributes.length)
      end.join(", \n") +";" + "\n"*2
    end
    sql
  end

end

tables = work "parsing records" do
  tables = []
  state = :no_context
  table = nil
  table_name = nil
  raw_dump.lines.each do |line|
    case state
    when :no_context
      if line =~ /\ACOPY/
        table_name, column_names = *line.scan(/COPY (?<table_name>\w+)\s+\((?<column_names>[^\)]+)\)/).first
        unless table_name == "schema_migrations"
          state = :data_segment
          columns = column_names.split(/,/).map(&:strip).map {|column_name| column_name.gsub(/(^[\"\'])|([\"\']$)/, "")}
          table = Table.new(table_name, columns)
        end
      end
    when :data_segment
      if line == "\\.\n"
        state = :no_context
        tables << table
      else
        table << Record.new(table_name, normalize_attributes(line.strip.split(/\t/)))
      end
    end
  end
  # raw_dump.scan(/COPY (?<table_name>\w+)\s+\((?<column_names>[^\)]+)\)[^\n]+\n(?<data>.+?)(?=\\\.)/m).each do |match|
  #   table_name, column_names, data = *match
  #
  #   next if table_name == "schema_migrations"
  #
  #   columns = column_names.split(/,/).map(&:strip).map {|column_name| column_name.gsub(/(^[\"\'])|([\"\']$)/, "")}
  #
  #   table = Table.new(table_name, columns)
  #   data.split(/\n/).each do |row|
  #     # break if table.records.length >= 100
  #   end
  #   tables << table
  # end
  tables
end

work "generating SQL inserts" do
  File.open("sapphire_dev.mysql.sql", "w") do |f|
    f.puts <<-EOS
TRUNCATE `accounts`;
TRUNCATE `courses`;
TRUNCATE `email_addresses`;
TRUNCATE `evaluations`;
TRUNCATE `evaluation_groups`;
TRUNCATE `exercises`;
TRUNCATE `exercise_registrations`;
TRUNCATE `exports`;
TRUNCATE `imports`;
TRUNCATE `import_errors`;
TRUNCATE `import_mappings`;
TRUNCATE `import_options`;
TRUNCATE `import_results`;
TRUNCATE `lecturer_registrations`;
TRUNCATE `ratings`;
TRUNCATE `rating_groups`;
TRUNCATE `result_publications`;
TRUNCATE `services`;
TRUNCATE `student_groups`;
TRUNCATE `student_registrations`;
TRUNCATE `submissions`;
TRUNCATE `submission_assets`;
TRUNCATE `submission_evaluations`;
TRUNCATE `terms`;
TRUNCATE `term_registrations`;
TRUNCATE `tutorial_groups`;
TRUNCATE `tutor_registrations`;
EOS
    tables.each do |r|
      f.puts r.to_sql + "\n"
    end
  end
end