Feature: `modifier' run control keyword

  Scenario: configures the modifier key
    Given a run control file with:
      """
      modifier :ctrl
      """
    And uhwm is running
    When I press the ctrl+q keys
    Then uhwm must terminate successfully
