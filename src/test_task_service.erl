-module(test_task_service).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, terminate/2, handle_info/2]).
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
	{reply, Table, State};
handle_call(currency, _From, State) ->
	case ets:lookup(?TABLE, currency) of
		[{currency, Value}] -> {reply, Value, State};
		_ ->
			Currency = get_currency(),
			Xml = gen_xml(
				jsx:decode(
					list_to_binary(Currency),
					[return_maps]
				)
			),
			ets:insert(?TABLE, {currency, Xml}),
			erlang:send_after(60000, self(), delete_currency),
			{reply, Xml, State}
	end;
handle_call(Request, From, State) ->
	erlang:error(not_implemented).

handle_info(delete_currency, State) ->
	ets:delete(?TABLE, currency),
	{noreply, State};
handle_info(_Info, State) ->
	{noreply, State}.

handle_cast(_Request, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	normal.

get_currency() ->
	inets:start(),
	ssl:start(),
	{ok, {_, _Headers, Body}} = httpc:request(get, {?API_URL_PRIVAT, []}, [{timeout, timer:seconds(5)}], []),
	ssl:stop(),
	inets:stop(),
	ets:insert(?TABLE, {currency, Body}),
	Body.

fields_to_xml(Fields) ->
	[{row, [], [{exchangerate, [
		{ccy, maps:get(?CCY, Map)},
		{base_ccy, maps:get(?BASE_CCY, Map)},
		{buy, maps:get(?BUY, Map)},
		{sale, maps:get(?SALE, Map)}
	], []}]} || Map <- Fields
	].

gen_xml(Data) ->
	Xml = xmerl:export_simple(
		[
			{exchangerates, [
				{fields_to_xml(Data)}
			]}
		],
		xmerl_xml,
		[{prolog, ""}]
	),
	unicode:characters_to_binary(Xml).
