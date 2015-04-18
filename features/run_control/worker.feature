Feature: `worker' run control keyword

  Scenario: configures the modifier key
    Given a run control file with:
      """
      worker :mux
      """
    And I start uhwm
    Then the output must match /work.+event.+mux/i
