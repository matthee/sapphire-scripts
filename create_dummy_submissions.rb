base_exercise = Exercise.find(46)
create_for_exercise = Exercise.find(47)

submissions = base_exercise.submissions
new_subs = submissions.map do |s|
  sg = s.student_group

  tg = sg.tutorial_group
  term = tg.term
  tutor = tg.tutor_accounts.first

  ns = Submission.new(exercise: create_for_exercise, submitter: tutor, submitted_at: s.submitted_at, student_group: sg)

  sg.term_registrations.each do |tr|
    ns.exercise_registrations.build(exercise: create_for_exercise, term_registration: tr)
  end

  ActiveRecord::Base.transaction do
    if ns.save
      es = EventService.new(tutor, term)
      e = es.submission_created!(ns)
      e.update(created_at: s.submitted_at)
    end
  end
  ns
end

new_subs.all?(&:valid?)

# new_subs.select { |s| !s.valid? }