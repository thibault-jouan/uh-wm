Feature: clients window properties updating

  Scenario: logs when the window properties of a client change
    Given uhwm is running
    And a window is mapped
    When the window name changes to "testing_new_name"
    Then the output must match /updat.+testing_new_name/i
