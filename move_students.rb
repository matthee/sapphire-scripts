dup = ["G4-03", "G4-10", "G4-05", "G1-05", "G1-06"]
t = Term.find 5

def duplicate_group(student_group, term)
  g = StudentGroup.create(title: student_group.title, tutorial_group: student_group.tutorial_group, active: true, solitary: false)
  student_group.student_registrations.each do |reg|
    raise unless StudentRegistration.create(student: reg.student, student_group: g)
  end
  g
end

def dup_and_deactivate(student_group, term)
  student_group.update(active: false)
  duplicate_group(student_group, term)
end


ActiveRecord::Base.transaction do
  g = t.student_groups.where(title: "G4-03").active.where(solitary: false).includes(:student_registrations).first
  tg = t.student_groups.where(title: "G4-10").active.where(solitary: false).includes(:student_registrations).first

  ng = dup_and_deactivate(g, t)
  a = Account.find_by_matriculation_number("1234567")

  ng.student_registrations.where(student: a).first.destroy
  ntg = dup_and_deactivate(tg, t)

  StudentRegistration.create(student: a, student_group: ntg)

  puts "-"*100

  g = t.student_groups.where(title: "G4-05").active.where(solitary: false).includes(:student_registrations).first
  ng = dup_and_deactivate(g, t)

  tg1 = t.student_groups.where(title: "G1-06").active.where(solitary: false).includes(:student_registrations).first
  ntg1 = dup_and_deactivate(tg1, t)

  a = Account.find_by_matriculation_number("1234568")
  ng.student_registrations.where(student: a).first.destroy
  StudentRegistration.create(student: a, student_group: ntg1)

  tg2 = t.student_groups.where(title: "G1-05").active.where(solitary: false).includes(:student_registrations).first
  ntg2 = dup_and_deactivate(tg2, t)

  a = Account.find_by_matriculation_number("1234569")
  ng.student_registrations.where(student: a).first.destroy
  StudentRegistration.create(student: a, student_group: ntg2)
end