require "fileutils"

t = Term.find(6)

name = "2016-02-24-2"

exports_path = "/home/sapphire/exports"

bp = File.join(exports_path, name)
tar_path = File.join(exports_path, "#{name}.tar.gz")

FileUtils.mkdir_p(bp)

t.submissions.includes(:submission_assets).each do |submission|
  submission.submission_assets.each do |sa|
    from = sa.file.to_s
    to = File.join(bp, from.sub(/^.*\/uploads/, "uploads"))

    next unless File.exists? from
    FileUtils.mkdir_p(File.dirname(to))
    FileUtils.cp(from, to)
  end
end

"tar czv #{tar_path} #{bp}"
