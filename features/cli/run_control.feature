Feature: run control file path CLI option

  Scenario: specifies run control file path
    Given a file named uhwmrc.rb with:
      """
      puts 'testing_run_control'
      """
    When I start the program with option -f uhwmrc.rb
    Then the output will contain "testing_run_control"
