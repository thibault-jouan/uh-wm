Feature: `key' run control keyword

  Scenario: defines code to run when given key is pressed
    Given uhwm is running with this run control file:
      """
      key(:f) { puts 'testing_rc_key' }
      """
    When I press the alt+f keys
    Then the output will contain "testing_rc_key"

  Scenario: defines code to run when given keys are pressed
    Given uhwm is running with this run control file:
      """
      key(:f, :shift) { puts 'testing_rc_key' }
      """
    When I press the alt+shift+f keys
    Then the output will contain "testing_rc_key"

  Scenario: translates common key names to their X equivalent
    Given uhwm is running with this run control file:
      """
      key(:enter) { puts 'testing_rc_key' }
      """
    When I press the alt+Return keys
    Then the output will contain "testing_rc_key"

  Scenario: translates upcased key names to combination with shift key
    Given uhwm is running with this run control file:
      """
      key(:F) { puts 'testing_rc_key' }
      """
    When I press the alt+shift+f keys
    Then the output will contain "testing_rc_key"
