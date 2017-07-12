load 'persistent/auto_responder_paper_data.rb'

f = File.open("/home/sapphire/autoresponder_assignments.html", "w")
f.puts "<!DOCTYPE html>"
f.puts "<html>"
f.puts "  <head>"
f.puts "    <title>Autoresponder Assignments</title>"
f.puts "    <meta charset=\"UTF-8\">"
f.puts "  </head>"
f.puts "  <body>"
f.puts "    <h1>Autoresponder Assignments</h1>"
f.puts "    <table>"
f.puts "      <thead>"
f.puts "        <th>Student</th>"
f.puts "        <th>Matriculation Number</th>"
f.puts "        <th>Famous Person</th>"
f.puts "      </thead>"

f.puts "      <tbody>"

Term.find(6).term_registrations.students.joins(:account).order{accounts.forename}.order{accounts.surname}.each do |term_registration|
  student = term_registration.account
  throw NotFoundExeception unless student
  mn = student.matriculation_number

  tutorial_group = term_registration.tutorial_group
  throw NotFoundExeception unless tutorial_group

  tutorial_group_index = tutorial_group.term.tutorial_groups.index tutorial_group
  throw NotFoundExeception unless tutorial_group_index

  student_index = tutorial_group.student_accounts.index student
  throw NotFoundExeception unless student_index

  famous_person = $famous_persons[tutorial_group_index][student_index % 5]

  f.puts "        <tr>"
  f.puts "          <td>#{student.fullname}</td>"
  f.puts "          <td>#{student.matriculation_number}</td>"
  f.puts "          <td>#{famous_person[:name]}</td>"
  f.puts "        </tr>"
end

f.puts "      </tbody>"
f.puts "    </table>"
f.puts "  </body>"
f.puts "</html>"
f.close