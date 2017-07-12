def mime_type_for_file(file_path)
  case File.extname(file_path).downcase
  when ".xhtml" || ".html"
    SubmissionAsset::Mime::HTML
  when ".css"
    SubmissionAsset::Mime::STYLESHEET
  when ".png"
    SubmissionAsset::Mime::PNG
  when ".jpg" || ".jpeg"
    SubmissionAsset::Mime::JPEG
  end
end

files = Dir.glob("/home/sapphire/import/*")
student = Account.find(736)
exercise = Exercise.find(21)

tr = student.term_registrations.last

submission = Submission.new(exercise: exercise, submitter: student, submitted_at: Time.parse("2014-11-05 18:20"))
submission.save

ExerciseRegistration.create(submission: submission, exercise: exercise, term_registration: tr)

files.each do |file|
  SubmissionAsset.create(submission: submission, file: File.open(file), content_type: mime_type_for_file(file))
end

submission.submitted_at = Time.parse("2014-11-05 18:20")
submission.save

# sub_id: 4958