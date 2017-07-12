require 'fileutils'

# Configuration
base_export_path = "/home/sapphire/exports/#{Date.today.strftime}/"
excercise_id = 37
term_name = "hci-ss2016"
exercise_name = "ex2-hereport"

ActiveRecord::Base.logger = nil

def tutorial_group_name_for_group(name)
  "t#{name[1]}"
end

ex = Exercise.find(excercise_id)
ex.submissions.each do |s|
  sg = s.student_group

  group_name = sg.try(:title).presence

  sa = s.submission_assets.where(content_type: SubmissionAsset::Mime::HTML).where { file =~ "he%" }.first

  unless sa
    puts "could not find heplan for #{s.student_group.try(:title).presence || "unknown group (submission=#{s.id}/#{group_name})"}"
    next
  end

  filename = [term_name, group_name, "#{exercise_name}"].join("-").parameterize
  tutorial_group_folder_name_html = [term_name, tutorial_group_name_for_group(group_name), "#{exercise_name}html"].join("-").parameterize

  export_html_path = File.join(base_export_path, tutorial_group_folder_name_html, filename + ".html")

  FileUtils.mkdir_p(File.dirname(export_html_path))
  FileUtils.cp(sa.file.to_s, export_html_path)
end
