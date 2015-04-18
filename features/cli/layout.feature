Feature: layout CLI option

  Scenario: specifies the layout class
    Given a file named layout.rb with:
      """
      class MyLayout
        def register _; end
      end
      """
    When I run uhwm with option -v -r./layout -l MyLayout
    Then the output must match /layout.+mylayout/i
