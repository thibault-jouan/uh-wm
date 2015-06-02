Feature: `modifier' run control keyword

  Scenario: configures the modifier key
    Given uhwm is running with this run control file:
      """
      modifier :ctrl
      """
    When I press the ctrl+shift+q keys
    Then uhwm must terminate successfully

  Scenario: configures ignored modifier keys
    Given uhwm is running with this run control file:
      """
      modifier :mod1, ignore: :mod2
      """
    When I press the Num_Lock key
    And I press the alt+shift+q keys
    Then uhwm must terminate successfully
