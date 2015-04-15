Feature: `quit' action keyword

  Scenario: requests quit when invoked
    Given uhwm is running with this run control file:
      """
      key(:f) { quit }
      """
    When I press the alt+f keys
    Then uhwm must terminate successfully
