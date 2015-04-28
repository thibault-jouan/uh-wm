Feature: `layout_*' action keywords

  Scenario: delegates messages matching `layout_*' to `layout_handle_*'
    Given a file named layout.rb with:
      """
      class Layout
        def register _; end

        def handle_some_action arg
          puts "testing_layout_action_#{arg}"
        end
      end
      """
    And a run control file with:
      """
      key(:f) { layout_some_action 'with_arg' }
      """
    And uhwm is running with options -v -r./layout.rb -l Layout
    When I press the alt+f keys
    Then the output must contain "testing_layout_action_with_arg"

  Scenario: logs an error about unimplemented messages
    Given uhwm is running with this run control file:
      """
      key(:f) { layout_unknown_action }
      """
    When I press the alt+f keys
    Then the output must match /layout.+no.+implem.+handle_unknown_action/i
