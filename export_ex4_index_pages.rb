require "fileutils"
require "nokogiri"


TYPE = :txt


sub_path = case TYPE
  when :txt
    "txt"
  when :html
    "html"
  end

export_path = File.join("/home/sapphire/exports/inm-2014/ex4", sub_path)

FileUtils.mkdir_p(export_path)
ex = Exercise.find(21)
ex.submissions.each do |submission|
  sa = submission.submission_assets.where {import_identifier =~ "%index%"}.first
  tr = submission.term_registrations.first

  a = tr.account
  tg = tr.tutorial_group

  unless sa.present?
    puts "No index file for #{a.fullname}'s submission"

    submission.submission_assets.each do |sa|
      puts "  - #{sa.import_identifier}"
    end
    next
  end

  name_parts = ["inm", "ws2014", tg.title, "ex4", a.surname, a.forename, a.matriculation_number]

  name_parts.map! do |np|
    np.downcase.gsub(/[äöüß]/) do |m|
      case m
      when 'ß'
        "ss"
      else
        m.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'') + "e"
      end
    end.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').gsub(/_/, "-")
  end

  filename = "#{name_parts.join("-")}.#{sub_path}".downcase

  path = File.join(export_path, filename)

  if TYPE == :txt
    html = Nokogiri::HTML(sa.file.read)

    File.open(path, "w") do |export_f|
      export_f.puts html.inner_text
    end
  elsif TYPE == :html
    FileUtils.cp(sa.file.to_s, path)
  end
end