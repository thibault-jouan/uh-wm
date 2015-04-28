Feature: worker CLI option

  Scenario: uses the blocking worker when `block' is given
    When I run uhwm with options -v -w block
    Then the output must match /work.+event.+block/i

  Scenario: uses the multiplexing worker when `mux' is given
    When I run uhwm with options -v -w mux
    Then the output must match /work.+event.+mux/i
