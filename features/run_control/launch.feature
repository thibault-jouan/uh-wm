Feature: `launch' run control keyword

  Scenario: defines code to run when the manager is connected
    Given uhwm is running with this run control file:
      """
      launch { puts :testing_launch_code }
      """
    Then the output will match /connected.*testing_launch_code/mi

  Scenario: gives access to the actions DSL
    Given uhwm is running with this run control file:
      """
      launch { execute 'echo etucexe_tset | rev' }
      """
    Then the output will contain "test_execute"

  Scenario: supports `execute!' keyword variant, waiting for client management
    Given uhwm is running with this run control file:
      """
      launch do
        execute! 'sleep 0.1; xmessage window'
        execute 'echo after_execute!'
      end
      """
    Then the output will match /execute.+manag.+xmessage.+after_execute!/mi
