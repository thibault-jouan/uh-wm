require 'uh/wm'
require 'uh/wm/testing/headless'

Dir['spec/support/**/*.rb'].map { |e| require e.gsub 'spec/', '' }

RSpec.configure do |config|
  config.include Factories
  config.include Uh::WM::Testing::Headless

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!

  config.before :all do
    # Ensure current X display is not available from rspec test suite.
    ENV.delete 'DISPLAY'
  end

  config.around :example, :xvfb do |example|
    with_xvfb do
      sleep 0.05
      example.run
    end
  end
end
