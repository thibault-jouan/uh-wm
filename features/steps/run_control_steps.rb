Given /^a run control file with:$/ do |content|
  write_file '.uhwmrc.rb', content
end
