Feature: layout registration

  Scenario: sends the #register message to the layout with the display
    Given a file named layout.rb with:
      """
      class Layout
        def register display
          puts display
        end
      end
      """
    When I run uhwm with option -r./layout -l Layout
    Then the output must contain current display
