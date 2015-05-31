Feature: manager X errors logging

  Scenario: logs error details
    Given a file named layout.rb with:
      """
      class Layout
        def initialize **_; end

        def register _; end

        # Focusing a client before mapping will force an error
        def << client
          client.focus
        end
      end
      """
    And uhwm is running with options -v -r./layout -l Layout
    When a window requests to be mapped
    Then the output must match /x.*error.+x_setinputfocus.+/i
