require 'fileutils'

# Configuration
base_export_path = "/home/sapphire/exports/#{Date.today.strftime}/"
excercise_id = 46
term_name = "hci-ss2017"
exercise_name = "ex4-ta"
section_css_selector = "section#subsecTestMethodology"
filename_matcher = "ta%"

ActiveRecord::Base.logger = nil

def manual_group_name(s)
  # case s.id
  # else
  #   nil
  # end
  nil
end

def tutorial_group_name_for_group(name)
  "t#{name[1]}"
end

ex = Exercise.find(excercise_id)
ex.submissions.each do |s|

  sg = s.student_group

  group_name = sg.try(:title).presence || manual_group_name(s)

  sa = s.submission_assets.where(content_type: SubmissionAsset::Mime::HTML).where { file =~ my { filename_matcher } }.first

  unless sa
    puts "could not find #{exercise_name} for #{s.student_group.try(:title).presence || "unknown group (submission=#{s.id}/#{group_name})"}"
    next
  end

  filename = [term_name, group_name, "#{exercise_name}text"].join("-").parameterize
  tutorial_group_folder_name_text = [term_name, tutorial_group_name_for_group(group_name), "#{exercise_name}text"].join("-").parameterize
  tutorial_group_folder_name_html = [term_name, tutorial_group_name_for_group(group_name), "#{exercise_name}html"].join("-").parameterize

  export_html_path = File.join(base_export_path, tutorial_group_folder_name_html, filename + ".html")
  export_text_path = File.join(base_export_path, tutorial_group_folder_name_text, filename + ".txt")

  FileUtils.mkdir_p(File.dirname(export_html_path))
  FileUtils.mkdir_p(File.dirname(export_text_path))
  FileUtils.cp(sa.file.to_s, export_html_path)

  html = Nokogiri::HTML(sa.file.read)

  element = html.css(section_css_selector)
  unless element.present?
    export_text_path += ".no-id"
  end

  text = (element.presence || html).inner_text

  File.open(export_text_path, "w") do |export_f|
    export_f.puts text
  end
end
