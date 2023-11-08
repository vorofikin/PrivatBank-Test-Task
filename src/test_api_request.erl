-module(test_api_request).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, api_request/0, start_link/0, api/0]).

-define(SERVER, ?MODULE).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	application:start(httpc),
	{ok, []}.

handle_call({api}, _From, State) ->
	A = httpc:request("https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"),
	{reply, A, State};
handle_call(Request, From, State) ->
	erlang:error(not_implemented).

handle_cast(Request, State) ->
	erlang:error(not_implemented).

api_request() ->
	gen_server:call(?MODULE, {api}).

api() ->
	URL = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5",
	Options = [{ssl, [{verify, verify_peer}, {cacertfile, "ca-certificate.crt"}]},
		{headers, [{"Accept", "*/*"}]},
		{timeout, 5000}],
	inets:start(),
	ssl:start(),
	{ok, {_, _Headers, Body}} = httpc:request("https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"),
	ssl:stop(),
	inets:stop(),
%%	io:format("is_json~p~n", [jsx:is_json(Body)]),
%%	io:format("~p~n", [jsx:prettify(Body)]),
	Body.