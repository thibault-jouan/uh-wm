Feature: `log_separator' action keyword

  Scenario: logs a separator
    Given uhwm is running with this run control file:
      """
      key(:f) { log_separator }
      """
    When I press the alt+f keys
    Then the output will contain "- - - - - - - - - - - - - - - - - - - - - - -"
