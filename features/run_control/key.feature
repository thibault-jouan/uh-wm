Feature: `key' run control keyword

  Scenario: defines code to run when given key is pressed
    Given a run control file with:
      """
      key(:f) { puts 'trigger f key code' }
      """
    And uhwm is running
    When I press the alt+f keys
    Then the output must contain "trigger f key code"
