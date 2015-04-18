Feature: version CLI option

  Scenario: prints the current version on standard output
    When I run uhwm with option --version
    Then uhwm must terminate successfully
    And the output must contain exactly the version
