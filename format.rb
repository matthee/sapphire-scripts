#
#  compare.rb
#  scripts
#
#  Created by Matthias Link on 2014-05-04.
#  Copyright 2014 Matthias Link. All rights reserved.
#

require "csv"


first = true
File.open("hci_new_2014-06-24.txt", "w+") do |f|
  File.read("TN_LV706021_2014-06-22.csv").split(/\n/).map{|l| l.split(",").map {|c| c[1..-2]} }.each do |line|
    if first
      first = false
      next
    end

    f.write [line[0], line[3], line[4], line[6], line[11]].join("\t") + "\n"
  end
end