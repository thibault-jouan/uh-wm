Feature: manager client unmanagement

  Background:
    Given uhwm is running
    And a window is mapped

  Scenario: logs when a new client is unmanaged
    When the window requests to be unmapped
    Then the output must match /unmanag.+xclient/i

  Scenario: unmanages client on destroy notify X events
    When the window is destroyed
    Then the output must match /unmanag.+xclient/i
