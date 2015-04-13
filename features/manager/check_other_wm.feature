Feature: checking if another window manager is running

  @other_wm_running
  Scenario: fails when another window manager is running
    Given another window manager is running
    When I start uhwm
    Then the exit status must be 70
    And the output must match /error.+other.+window.+manager/i
