require 'tempfile'

module FileSystemHelpers
  def with_file content
    Tempfile.create('uhwm_rspec') do |f|
      f.write content
      f.rewind
      yield f
    end
  end
end
