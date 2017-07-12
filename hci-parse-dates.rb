require "date"

cal = ""
cal << <<-EOS
BEGIN:VCALENDAR
METHOD:PUBLISH
VERSION:2.0
X-WR-CALNAME:HCI
PRODID:-//Apple Inc.//Mac OS X 10.11.3//EN
X-APPLE-CALENDAR-COLOR:#63DA38
X-WR-TIMEZONE:Europe/Vienna
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:Europe/Berlin
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
DTSTART:19810329T020000
TZNAME:MESZ
TZOFFSETTO:+0200
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
DTSTART:19961027T030000
TZNAME:MEZ
TZOFFSETTO:+0100
END:STANDARD
END:VTIMEZONE
BEGIN:VTIMEZONE
TZID:Europe/Vienna
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
DTSTART:19810329T020000
TZNAME:MESZ
TZOFFSETTO:+0200
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
DTSTART:19961027T030000
TZNAME:MEZ
TZOFFSETTO:+0100
END:STANDARD
END:VTIMEZONE
EOS


today = "20170302"
DATA.read.lines.each.with_index do |line, idx|
  date, time, room, note = line.split(",").map(&:strip)

  from_time, to_time = time.split("-").map { |p| p.sub(":", "").ljust(6,'0') }
  date = DateTime.parse(date).strftime("%Y%m%d")

  room = room.split(/\s+/,3).first(2).join(" ")
  location_title = "#{room}\\nInffeldgasse 16C\\n8010 Graz, Österreich"

  cal << "BEGIN:VEVENT\n"
  cal << "CREATED:#{today}T125521Z\n"
  cal << "UID:HCI-meeting-event-2017-#{idx}\n"
  cal << "DTEND;TZID=Europe/Vienna:#{date}T#{to_time}\n"
  cal << "TRANSP:OPAQUE\n"
  cal << "X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC\n"
  cal << "SUMMARY:HCI-Meeting\n"
  cal << "DTSTART;TZID=Europe/Vienna:#{date}T#{from_time}\n"
  cal << "SEQUENCE:0\n"
  cal << "LOCATION:#{location_title}\n"
  cal << "X-APPLE-STRUCTURED-LOCATION;VALUE=URI;X-APPLE-RADIUS=49.91305923461914;X
 -TITLE=\"#{location_title}\":geo:47.058239,15.457903"
  cal << "DESCRIPTION:#{note}\n"
  cal << "X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC\n"
  cal << "END:VEVENT\n"
end

cal << "END:VCALENDAR\n"

File.open("/Users/matthee/Desktop/HCI.ics", "w") do |f|
  f.write cal
end

__END__
Thu 01 Mar 2017, 16:00-18:00, BespRaum IICM D2.21 ID01184, prep
Thu 05 Mar 2017, 16:00-18:00, BespRaum IICM D2.21 ID01184, besprechung
