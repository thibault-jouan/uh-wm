Feature: run control file evaluation

  Scenario: reports run control code in backtrace on errors
    Given a run control file with:
      """
      'no error on first line'
      fail 'testing_rc_failure'
      """
    When I start uhwm
    Then the output must match /\.uhwmrc\.rb:2:.+testing_rc_failure/
