Feature: `rule' run control keyword

  Scenario: defines code to run when given selector match a managed client
    Given uhwm is running with this run control file:
      """
      rule /some_window_class/ do
        puts :testing_client_rule
      end
      """
    When a window with class "some_window_class" requests to be mapped
    Then the output must contain "testing_client_rule"
