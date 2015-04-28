Feature: layout CLI option

  Scenario: specifies the layout class
    Given a file named layout.rb with:
      """
      class MyLayout
        def register *_
          puts 'testing_cli_layout'
        end
      end
      """
    When I run uhwm with options -r./layout -l MyLayout
    Then the output must contain "testing_cli_layout"

  Scenario: resolves layout class from the root namespace
    When I run uhwm with option -l Layout
    Then the output must contain "uninitialized constant Layout"
