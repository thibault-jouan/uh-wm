Feature: layout client management

  Background:
    Given uhwm is running

  Scenario: maps new client window
    When a window requests to be mapped
    Then the window must be mapped

  Scenario: focuses new client window
    When a window requests to be mapped
    Then the window must be focused
