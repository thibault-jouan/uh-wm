Feature: expose events handling

  Scenario: logs when an expose event is handled
    Given uhwm is running
    Then the output must match /expos.+window.+\d+/i
