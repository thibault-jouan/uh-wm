Feature: `execute' action keyword

  Scenario: executes the given command in a shell with current standard output
    Given uhwm is running with this run control file:
      """
      key(:f) { execute 'echo etucexe_tset | rev' }
      """
    When I press the alt+f keys
    Then the output will contain "test_execute"
