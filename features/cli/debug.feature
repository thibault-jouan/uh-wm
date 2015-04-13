Feature: debug CLI option

  Scenario: raises the logger level to DEBUG
    When I run uhwm with option -d
    Then the output must match /log.+debug.+level/i
