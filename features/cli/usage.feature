Feature: CLI usage

  Scenario: prints the usage when unknown option switch is given
    When I run the program with option --unknown-option
    Then the exit status must be 64
    And the output must contain exactly the usage

  Scenario: prints the help when -h option is given
    When I run the program with option -h
    Then the exit status must be 0
    And the output must contain exactly the usage
