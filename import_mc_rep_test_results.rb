results = "1234567;3
1234568;4"

term = Term.find(10)
exercise = term.exercises.find(48)
rating_id = 3124

logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil
results.split(/\n/).each.with_index do |res, idx|
  mnr, questions = res.split(";", 2)

  a = Account.find_by_matriculation_number(mnr)

  unless a.present?
    puts "could not find account with matriculation_number: #{mnr} (line ##{idx + 1})"
    next
  end

  term_registration = a.term_registrations.students.find_by!(term: term)

  existing_submission = term_registration.submissions.find_by(exercise: exercise)

  if existing_submission.present?
    existing_submission.update(outdated: true)
    puts "#{mnr}: setting older submission as outdated"
  else
    puts "#{mnr}: did not attend first mc test"
  end

  submission = Submission.new
  submission.exercise = exercise
  submission.submitter = a
  submission.submitted_at = Time.parse("2017-07-05 15:00")
  submission.exercise_registrations.build(exercise: exercise, term_registration: term_registration)
  puts submission.valid? ? "valid" : "invalid"
  submission.save

  se = submission.reload.submission_evaluation
  se.evaluated_at = Time.now
  se.evaluator = submission.term_registrations.first.tutorial_group.tutor_accounts.first
  se.save

  ev = se.evaluations.find_by_rating_id(rating_id)
  ev.value = questions
  ev.save
end

ActiveRecord::Base.logger = logger