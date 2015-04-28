Feature: blocking worker

  Scenario: processes initial events
    Given uhwm is running with options -d -w block
    Then the output must match /xevent/i at least 2 times

  Scenario: processes generated events
    Given a run control file with:
      """
      key(:f) { puts 'testing_worker_read' }
      """
    And uhwm is running with options -v -w block
    When I press the alt+f key 3 times
    And I quit uhwm
    Then the output must match /(testing_worker_read)/ exactly 3 times
