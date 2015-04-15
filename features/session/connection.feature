Feature: connection to X server

  Scenario: connects to X server
    When I start uhwm
    Then it must connect to X display
