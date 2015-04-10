Feature: ruby feature require CLI option

  Scenario: requires a ruby feature
    When I run uhwm with option -v -r abbrev
    Then the current output must match /load.+abbrev.+ruby feature/i
