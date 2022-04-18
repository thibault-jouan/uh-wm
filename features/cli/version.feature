Feature: version CLI option

  Scenario: prints the current version on standard output
    When I run the program with option --version
    Then the exit status must be 0
    And the output must contain exactly the version
