Feature: `layout_*' action keywords

  Background:
    Given a file named layout.rb with:
      """
      class Layout
        def register _; end

        def handle_some_action arg
          puts arg
        end
      end
      """

  Scenario: delegates messages matching `layout_*' to `layout_handle_*'
    Given uhwm is running with this run control file:
      """
      key(:f) { layout_some_action :testing_some_action }
      """
    When I press the alt+f keys
    Then the output must contain ":testing_some_action"

  Scenario: logs an error about unimplemented messages
    Given uhwm is running with this run control file:
      """
      key(:f) { layout_unknown_action }
      """
    When I press the alt+f keys
    Then the output must match /layout.+no.+implem.+handle_unknown_action/i
