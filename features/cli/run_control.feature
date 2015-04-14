Feature: run control file path CLI option

  Scenario: specifies run control file path
    Given a file named uhwmrc.rb with:
      """
      puts 'run control evaluation'
      """
    When I run uhwm with option -f uhwmrc.rb
    Then the output must contain "run control evaluation"
