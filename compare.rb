#
#  compare.rb
#  scripts
#
#  Created by Matthias Link on 2014-05-04.
#  Copyright 2014 Matthias Link. All rights reserved.
#

class Group
  attr_reader :title

  def self.find(title)
    @groups ||= Hash.new {|h,k| h[k] = Group.new(k)}
    @groups[title]
  end

  def initialize(title)
    @title = title
  end

  def to_s
    @title
  end

  def ==(other)
    other.is_a?(Group) && other.title == @title
  end

  def <=>(other)
    title <=> other.title
  end

end

class Student
  attr_reader :group, :forename, :surname, :email, :matriculation_number
  attr_accessor :is_new, :new_group
  def initialize_with_text_line(line, is_new)
    group_title, @surname, @forename, @matriculation_number, @email = *line.split(/\t/)
    @is_new = is_new
    @group = Group.find group_title
    self
  end


  def interesting?
    new? || moved? || deleted?
  end

  def moved?
    !(@new_group == @group)
  end

  def new?
    @is_new
  end

  def deleted?
    !@group.nil? && @new_group.nil?
  end

  def to_s
    parts = [:forename, :surname, :email, :matriculation_number].map { |m| send(m) }

    if new?
      "NEW:     #{@group} #{parts.join(" ")}"
    elsif deleted?
      "REMOVED: #{@group} #{parts.join(" ")}"
    elsif moved?
      "MOVED:   #{@group} -> #{@new_group} | #{parts.join " "}"
    end
  end
end

@students = {}

def read_students(file, is_new: false)
  File.read(file).split("\n").each do |line|
    student = Student.new.initialize_with_text_line(line, is_new)

    if @students[student.matriculation_number]
      student = @students[student.matriculation_number]
      student.is_new = false
      student.new_group = Group.find line.split("\t", 2).first
    else
      @students[student.matriculation_number] = student
    end
  end
end

read_students "students_hci.txt", is_new: true
read_students "hci_new_2014-06-24.txt"

interesting_students = @students.values.select {|s| s.interesting? }

puts interesting_students
puts "#{interesting_students.count} interesting students (of #{@students.count})"

puts "Affected Groups: "
puts interesting_students.map{ |s| [s.group, s.new_group] }.flatten.uniq.sort.join(", ")