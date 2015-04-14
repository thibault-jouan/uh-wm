@mocked_home_directory
Feature: run control file evaluation

  Scenario: evaluates the default run control file when it exists
    Given a file named .uhwmrc.rb with:
      """
      puts 'run control evaluation'
      """
    When I start uhwm
    Then the output must contain "run control evaluation"
