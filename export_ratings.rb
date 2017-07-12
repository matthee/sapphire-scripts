ex = Exercise.find(19)

def q(s)
  "\"#{(s || "").gsub('"', '\\"')}\""
end


f = File.open("/home/sapphire/ex31_import.rb", "w")

f.puts "ex = Exercise.find(insert_exercise_id_here)\n\n"

ex.rating_groups.each do |rg|
  f.puts "rg = RatingGroup.create(exercise: ex, title: #{q rg.title}, points: #{rg.points}, description: #{q rg.description}, global:#{rg.global ? "true" : "false"}, min_points:#{rg.min_points || "nil"}, max_points: #{rg.max_points || "nil"}, enable_range_points: #{rg.enable_range_points ? "true" : "false"})"

  rg.ratings.each do |r|
    f.puts "Rating.create(rating_group: rg, title: #{q r.title}, value: #{r.value || "nil"}, description: #{q r.description}, type: #{q r.type}, max_value: #{r.max_value || "nil"}, min_value: #{r.min_value || "nil"}, row_order: #{r.row_order || "nil"}, multiplication_factor: #{r.multiplication_factor || "nil"}, automated_checker_identifier: #{r.automated_checker_identifier.present? ? q(r.automated_checker_identifier) : "nil"})"
  end
end

f.close