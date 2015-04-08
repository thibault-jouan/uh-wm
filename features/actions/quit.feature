Feature: quit action

  Scenario: quits on keybing press
    Given uhwm is running
    When I press the default quit key binding
    Then uhwm should terminate successfully
