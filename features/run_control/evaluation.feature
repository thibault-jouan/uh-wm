Feature: run control file evaluation

  Scenario: reports run control code in backtrace on errors
    Given a run control file with:
      """
      'no error on first line'
      fail 'fails on second line'
      """
    When I start uhwm
    Then the output must match /\.uhwmrc\.rb:2:.+fails on second line/
