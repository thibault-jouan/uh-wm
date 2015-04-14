Feature: run control file path CLI option

  Scenario: changes the path to run control file
    Given a file named uhwmrc.rb with:
      """
      puts 'run control evaluation'
      """
    When I run uhwm with option -f uhwmrc.rb
    Then the output must contain "run control evaluation"
