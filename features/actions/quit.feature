Feature: quit action

  Scenario: quits on alt+q keys press
    Given uhwm is running
    When I press the alt+q keys
    Then uhwm should terminate successfully
