Feature: layout client unmanagement

  Background:
    Given uhwm is running
    And a first window is managed
    And a second window is managed

  Scenario: maps another window
    When the second window is unmapped
    Then the first window must be mapped
