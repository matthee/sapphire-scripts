# TODO enter matriculation_number;message_id (seperated by newlines) and adjust the exercise id

missing = "1234567;asdasdasdsad@news.tugraz.at
1234568;asdasdasdsay@news.tugraz.at"

t = Term.find(6)
ex = Exercise.find(18)

missing.split(/\n/).map {|m| m.split(";")} .each do |mp|
  a = Account.find_by_matriculation_number(mp.first)

  s = ex.submissions.select("submissions.*").joins(:submission_assets).where(submission_assets: {import_identifier: mp.last}).first

  if a.present? && s.present?
    if s.submitter == a
      puts "already matched: #{mp.first}"
      next
    end
    tr = a.term_registrations.students.where(term: t).first
    sa = s.submission_assets.find_by_import_identifier(mp.last)

    exercise_registration = tr.exercise_registrations.find_by_exercise_id(ex.id)

    if exercise_registration.present?
      puts "reassigning"
      # reassign

      ActiveRecord::Base.transaction do
        # add submission asset to other submission
        sa.submission = exercise_registration.submission
        sa.save!

        # delete this submission
        s.destroy!

        # update submitted at
        new_submission = exercise_registration.submission
        new_submission.submitted_at = new_submission.submission_assets.maximum(:created_at)
        new_submission.save!
      end
    else
      puts "newly assigning"

      ActiveRecord::Base.transaction do
        ExerciseRegistration.create!(exercise: ex, term_registration: tr, submission: s)
        s.submitter = a
        s.save!
      end
    end
  else
    puts "account not found: #{mp.first}" unless a.present?
    puts "submission not found: #{mp.last}" unless s.present?
  end
end
