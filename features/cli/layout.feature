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

  Scenario: resolves layout class from the root namespace
    When I run uhwm with option -v -l Layout
    Then the output must contain "uninitialized constant Layout"
