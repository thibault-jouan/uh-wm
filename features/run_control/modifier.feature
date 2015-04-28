Feature: `modifier' run control keyword

  Scenario: configures the modifier key
    Given uhwm is running with this run control file:
      """
      modifier :ctrl
      """
    When I press the ctrl+shift+q keys
    Then uhwm must terminate successfully
