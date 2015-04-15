Feature: run control file evaluation

  Scenario: evaluates the default run control file when present
    Given a run control file with:
      """
      puts 'run control evaluation'
      """
    When I start uhwm
    Then the output must contain "run control evaluation"

  Scenario: reports run control code in backtrace on errors
    Given a run control file with:
      """
      'no error on first line'
      fail 'fails on second line'
      """
    When I start uhwm
    Then the output must match /\.uhwmrc\.rb:2:.+fails on second line/
