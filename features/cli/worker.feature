Feature: worker CLI option

  Scenario: uses the blocking worker when `block' is given
    When I start the program with options -v -w block
    Then the output will match /work.+event.+block/i

  Scenario: uses the multiplexing worker when `mux' is given
    When I start the program with options -v -w mux
    Then the output will match /work.+event.+mux/i
