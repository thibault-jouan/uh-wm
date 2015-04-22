Feature: layout protocol

  Background:
    Given a file named layout.rb with:
      """
      class Layout
        def register display
          puts display
          display.create_subwindow(Uh::Geo.new(0, 0, 640, 16)).tap do |o|
            o.show
          end
        end

        def << client
          puts "testing_#<<_#{client.name}"
          client.show
        end

        def remove client
          puts "testing_#remove_#{client.name}"
        end

        def update client
          puts "testing_#update_#{client.name}"
        end

        def expose window
          puts "testing_#expose_#{window.id}"
        end
      end
      """

  Scenario: tells the layout to register with #register message
    When I run uhwm with option -r./layout -l Layout
    Then the output must contain current display

  Scenario: tells the layout to manage a client with #<< message
    Given uhwm is running with options -v -r./layout -l Layout
    When a window requests to be mapped
    Then the output must contain "testing_#<<_XClient/default"

  Scenario: tells the layout to unmanage a client with #remove message
    Given uhwm is running with options -v -r./layout -l Layout
    And a window is mapped
    When the window is unmapped
    Then the output must contain "testing_#remove_XClient/default"

  Scenario: tells the layout to update a changed client with #update message
    Given uhwm is running with options -v -r./layout -l Layout
    And a window is mapped
    When the window name changes to "testing_new_name"
    Then the output must contain "testing_#update_testing_new_name"

  Scenario: tells the layout about an exposed window with #expose message
    Given I run uhwm with options -r./layout -l Layout
    Then the output must match /testing_#expose_\d+/
