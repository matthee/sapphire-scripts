require "fileutils"

EXPORT_PATH = "/home/sapphire/exports/inm-2014/inm-2014-ex5"
ex = Exercise.find(22)

ex.submissions.includes(:submission_assets).each do |submission|
  tr = submission.term_registrations.first

  a = tr.account
  tg = tr.tutorial_group

  name_parts = ["inm", "ws2014", tg.title, "ex5", a.surname, a.forename, a.matriculation_number]

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

  export_dir = File.join(EXPORT_PATH, "#{name_parts.join("-")}".downcase)
  FileUtils.mkdir_p(export_dir)

  submission.submission_assets.each do |sa|
    filename = File.basename(sa.file.to_s)
    export_path = File.join(export_dir, filename)

    FileUtils.cp(sa.file.to_s, export_path)
    print "."
  end
end

print "\n"

puts "done"