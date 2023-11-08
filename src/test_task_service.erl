-module(test_task_service).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, terminate/2]).
-export([start_link/0, create_table/0, stop/0]).

-include("test_task.hrl").
-define(TABLE, test_task).
-define(SERVER, ?MODULE).

start_link() ->
	{ok, Pid} = gen_server:start_link({local, ?SERVER}, ?MODULE, [], []),
	Pid.

create_table() ->
	gen_server:call(?MODULE, create).

stop() ->
	gen_server:stop(?MODULE).

init([]) ->
	{ok, []}.

handle_call(create, _From, State) ->
	Table = ets:new(?TABLE, [public, ordered_set, named_table]),
	erlang:send_after(60000, self(), {delete_obsolete, ?TABLE}),
	{reply, Table, State};
handle_call(currency, _From, State) ->
	Result = case ets:lookup(?TABLE, currency) of
		 [{currency, Value}] -> Value;
		_ -> api_request()
	end,
	io:format("~p~n", [Result]),
	{reply, Result, State};
handle_call(Request, From, State) ->
	erlang:error(not_implemented).

handle_cast(Request, State) ->
	erlang:error(not_implemented).

terminate(_Reason, _State) ->
	normal.

api_request() ->
	io:format("4"),
	inets:start(),
	ssl:start(),
	{ok, {_, _Headers, Body}} = httpc:request(?API_URL_PRIVAT),
	ssl:stop(),
	inets:stop(),
	Body.
	