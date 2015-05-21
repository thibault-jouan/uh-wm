Feature: kqueue worker

  Scenario: processes initial events
    Given uhwm is running with options -d -w kqueue
    Then the output must match /xevent/i at least 2 times

  Scenario: processes generated events
    Given a run control file with:
      """
      key(:f) { puts 'testing_worker_read' }
      """
    And uhwm is running with options -v -w kqueue
    When I quickly press the alt+f key 1024 times
    And I quit uhwm
    Then the output must match /(testing_worker_read)/ exactly 1024 times
