Feature: verbose CLI option

  Scenario: raises the logger level to INFO
    When I start the program with option -v
    Then the output will match /log.+info.+level/i
