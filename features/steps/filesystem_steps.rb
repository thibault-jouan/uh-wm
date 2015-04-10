Given /^a file named ([^ ]+) with:$/ do |path, content|
  write_file path, content
end
