-module(test_task_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Pid = test_task_service:start_link(),
    test_task_service:create_table(),
    io:format("~p~n", [Pid]),
    Dispatch = cowboy_router:compile([
        {'_',[
            {"/api/currency", test_task_h, [{pid, Pid}]}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    test_task_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
