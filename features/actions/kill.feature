Feature: `kill' action keyword

  @icccm_window
  Scenario: kills current client
    Given uhwm is running with this run control file:
      """
      key(:f) { kill_current }
      """
    And an ICCCM compliant window is mapped
    When I press the alt+f keys
    Then the ICCCM window must be unmapped by the manager
