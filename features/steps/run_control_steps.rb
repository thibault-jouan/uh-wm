Given /^a run control file with:$/ do |content|
  Baf::Testing.write_file '.uhwmrc.rb', content
end
