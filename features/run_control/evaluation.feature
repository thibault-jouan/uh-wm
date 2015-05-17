Feature: run control file evaluation

  Scenario: reports syntax errors in run control code
    Given a run control file with:
      """
      'no error on first line'
      { # this will trigger a syntax error
      """
    When I start uhwm
    Then the output must match /RunControlEvaluationError:.*\.uhwmrc\.rb:2:/

  Scenario: reports errors with run control code backtrace in debug mode
    Given a run control file with:
      """
      'no error on first line'
      fail 'testing_rc_failure'
      """
    When I run uhwm with option -d
    Then the output must match /\.uhwmrc\.rb:2:in.*\w+/
