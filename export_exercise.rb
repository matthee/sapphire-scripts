require 'fileutils'

# Configuration
base_export_path = "/home/sapphire/exports/#{Date.today.strftime}/"
excercise_id = 37
term_name = "hci-ss2016"

ActiveRecord::Base.logger = nil

def tutorial_group_name_for_group(name)
  "t#{name[1]}"
end

$unknown_group_idx = 0

def unknown_group
  $unknown_group_idx += 1
  "unknown-group-#{$unknown_group_idx}"
end

ex = Exercise.find(excercise_id)
ex.submissions.each do |s|
  sg = s.student_group

  group_name = sg.try(:title).presence || unknown_group

  s.submission_assets.each do |sa|
    export_path = File.join(base_export_path, group_name, sa.path, File.basename(sa.file.path))

    FileUtils.mkdir_p(File.dirname(export_path))
    FileUtils.cp(sa.file.path, export_path)
  end
end
