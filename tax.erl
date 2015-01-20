%% refer to http://0.shuilv.org/499.html
-module(tax).
-export([calc/2]).

-define(TAX_EXEMPTION, 3500).

calc(Total, Security) ->
    Calculated = Total - Security - ?TAX_EXEMPTION,
    Tax = case Calculated of
              A when A =< 1500 -> A * 0.03;
              A when A =< 4500 -> A * 0.10 - 105;
              A when A =< 9000 -> A * 0.20 - 555;
              A when A =< 35000 -> A * 0.25 - 1005;
              A when A =< 55000 -> A * 0.30 - 2755;
              A when A =< 80000 -> A * 0.35 - 5505;
              A -> A * 0.45 - 13505
          end,
    Income = Total - Security - Tax,
    io:format("~p = ~p - ~p - ~p~n", [Income, Total, Security, Tax]).
