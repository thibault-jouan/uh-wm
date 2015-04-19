Feature: manager client management

  Background:
    Given uhwm is running

  Scenario: logs when a new client is managed
    When a window requests to be mapped
    Then the output must match /manage.+xclient/i

  Scenario: manages a given client only once
    When a window requests to be mapped 2 times
    And I quit uhwm
    Then the output must not match /manage.*\n.*manage/mi
    And the output must not match /xerror/i
