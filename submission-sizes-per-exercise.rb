ActiveRecord::Base.logger = nil
Term.find(8).exercises.each do |ex|
  per_sub = ex.submissions.map do |sub|
    sub.submission_assets.map(&:filesize).sum
  end

  puts "-" * 100
  puts ex.title
  puts "Min: #{per_sub.min}"
  puts "Avg: #{per_sub.inject(&:+) / per_sub.length}"
  puts "Max: #{per_sub.max}"
  puts "Count: #{per_sub.count}"
end
