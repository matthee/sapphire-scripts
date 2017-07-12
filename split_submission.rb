# logfile-ex

ex = Exercise.find(36)

account = 997
submitter_a = Account.find(997)

* s = Submission.find 111
* a = Account.find 111
* tr = a.term_registrations.find_by(term: Term.find(9))
* ns = Submission.new(submitted_at: s.submitted_at, submitter: submitter_a, exercise: ex)
* ns.save
* er = ExerciseRegistration.new(exercise: ex, term_registration: tr, submission: ns)
* er.save
* s.submission_assets
* sa = s.submission_assets.find 111
* filename = File.basename sa.file.to_s
* nsa_path = File.join("/home/sapphire/tmp/", filename)
* FileUtils.cp(sa.file.path, nsa_path)
* nsa = SubmissionAsset.new(asset_identifier: sa.asset_identifier, import_identifier: sa.import_identifier, path: sa.path, content_type: sa.content_type, submitted_at: sa.submitted_at)
* nsa.submission = ns
* nsa.file = File.open(nsa_path, "r")
* nsa.save
