Feature: manager client unmanagement on destroy notifications

  Background:
    Given uhwm is running
    And a window is mapped

  Scenario: unmanages client on destroy notify X events
    When the window is destroyed
    Then the output will match /unmanag.+xclient/i
