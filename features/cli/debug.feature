Feature: debug CLI option

  Scenario: raises the logger level to DEBUG
    When I start the program with option -d
    Then the output will match /log.+debug.+level/i
