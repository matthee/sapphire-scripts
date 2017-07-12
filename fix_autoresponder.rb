load Rails.root.join("lib/email/inm/web_research.rb")

$mail_config = YAML.load_file(Rails.root.join("config/mail.yml")).symbolize_keys

Mail.defaults do
  retriever_method :imap,
    address: $mail_config[:address],
    port: $mail_config[:port],
    enable_ssl: $mail_config[:enable_ssl],
    authentication: $mail_config[:authentication],
    user_name: $mail_config[:user_name],
    password: $mail_config[:password]
end

class AutoResponderMailer < ActionMailer::Base
  default from: $mail_config[:from_address]

  def answer(args)
    mail(
      to: args[:to],
      reply_to: args[:reply_to],
      subject: args[:subject],
      body: args[:body]
    )
  end
end


def submitter_for_email(parsed_email, exercise)
  mnr = parsed_email.subject.scan(/\d{7}/)

  possible_submitters = []

  if mnr.present?
    possible_submitters = exercise.term.term_registrations.joins(:account).where{ account.matriculation_number == my{mnr} }
  end

  unless possible_submitters.any?
    emails = []
    emails += parsed_email.from
    emails += parsed_email.reply_to if parsed_email.reply_to.present?

    possible_submitters = exercise.term.term_registrations.joins(:account).where{ account.email.in(my{emails}) }
  end

  if possible_submitters.size == 1
    possible_submitters.first
  else
    nil
  end
end


def deliver_mail(args)
  AutoResponderMailer.answer(args).deliver
end

ex = Exercise.find(19)

submissions = ex.submissions.select("submissions.*").where(submitter_id: nil); nil


submissions.each do |submission|
  submission_asset = submission.submission_assets.first

  raw_mail = submission_asset.file.read
  parsed_mail = Mail.new(raw_mail)

  tr = submitter_for_email(parsed_mail, ex)
  if tr.present?
    exercise_registration = tr.exercise_registrations.find_by_exercise_id(ex.id)

    if exercise_registration.present?
      puts "#{tr.account.fullname} (#{tr.account.id}) has an existing submission, no email will be sent"

      # add submission asset to other submission
      submission_asset.submission = exercise_registration.submission
      submission_asset.save

      # delete this submission
      submission.destroy

      # update submitted at
      new_submission = exercise_registration.submission
      new_submission.submitted_at = new_submission.submission_assets.maximum(:created_at)
    else
      puts "fresh submission for #{tr.account.fullname}"

      # register for this exercise
      ExerciseRegistration.create!(exercise_id: ex.id, submission_id: submission.id, term_registration_id: tr.id)
      submission.submitter = tr.account
      submission.save

      # send email
      execute(parsed_mail, ex)
    end
  else
    puts "could not match: #{parsed_mail.from}"
  end
end.count

