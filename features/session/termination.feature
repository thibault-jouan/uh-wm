Feature: program termination

  Scenario: terminates when requested to quit
    Given uhwm is running
    When I tell uhwm to quit
    Then uhwm must terminate successfully
