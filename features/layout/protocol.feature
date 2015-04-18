Feature: layout protocol

  Background:
    Given a file named layout.rb with:
      """
      class Layout
        def register display
          puts display
        end

        def << client
          puts client
        end
      end
      """

  Scenario: tells the layout to register with #register message
    When I run uhwm with option -r./layout -l Layout
    Then the output must contain current display

  Scenario: tells the layout to manage a client with #<< message
    Given uhwm is running with options -v -r./layout -l Layout
    When a window requests to be mapped
    Then the output must contain the window name
