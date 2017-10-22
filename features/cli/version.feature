Feature: version CLI option

  Scenario: prints the current version on standard output
    When I run the program with option --version
    Then the program must terminate successfully
    And the output must contain exactly the version
