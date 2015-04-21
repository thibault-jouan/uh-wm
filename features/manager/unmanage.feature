Feature: manager client unmanagement

  Scenario: logs when a new client is unmanaged
    Given uhwm is running
    And a window is mapped
    When the window requests to be unmapped
    Then the output must match /unmanag.+xclient/i
