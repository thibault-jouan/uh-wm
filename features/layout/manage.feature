Feature: layout client management

  Scenario: sends the #<< message when telling the layout to manage a client
    Given a file named layout.rb with:
      """
      class Layout
        def register *_; end

        def << client
          # FIXME: need the Manager to manage state with clients, not windows
          #puts client.wname
          puts client.name
        end
      end
      """
    And uhwm is running with options -v -r./layout -l Layout
    When a window requests to be mapped
    Then the output must contain the window name
