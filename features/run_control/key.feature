Feature: `key' run control keyword

  Scenario: defines code to run when given key is pressed
    Given uhwm is running with this run control file:
      """
      key(:f) { puts 'trigger f key code' }
      """
    When I press the alt+f keys
    Then the output must contain "trigger f key code"

  Scenario: defines code to run when given keys are pressed
    Given uhwm is running with this run control file:
      """
      key(:f, :shift) { puts 'trigger f key code' }
      """
    When I press the alt+shift+f keys
    Then the output must contain "trigger f key code"

  Scenario: translates common key names to their X equivalent
    Given uhwm is running with this run control file:
      """
      key(:enter) { puts 'trigger return key code' }
      """
    When I press the alt+Return keys
    Then the output must contain "trigger return key code"

  Scenario: translates upcased key names to combination with shift key
    Given uhwm is running with this run control file:
      """
      key(:F) { puts 'trigger shift+f key code' }
      """
    When I press the alt+shift+f keys
    Then the output must contain "trigger shift+f key code"
