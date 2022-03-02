Feature: `worker' run control keyword

  Scenario: configures the event worker
    Given uhwm is running with this run control file:
      """
      worker :mux
      """
    Then the output will match /work.+event.+mux/i
