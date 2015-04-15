Feature: program termination

  Background:
    Given uhwm is running

  Scenario: terminates on quit request
    When I tell uhwm to quit
    Then uhwm must terminate successfully

  Scenario: logs about termination
    When I tell uhwm to quit
    Then uhwm must terminate successfully
    And the output must match /terminat/i
