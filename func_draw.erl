-module(func_draw).
-compile(export_all).
-include_lib("wx/include/wx.hrl").


d(Function) ->
    Wx = wx:new(),
    Frame = wxFrame:new(Wx, -1, "Function", [{size, {440, 500}}]),
    Panel = wxPanel:new(Frame),
 
    OnPaint = fun(_Evt, _Obj) ->
        PaintDC = wxPaintDC:new(Panel),
        draw(Function, PaintDC)
    end,
 
    wxFrame:connect(Panel, paint, [{callback, OnPaint}]),    
    %wxFrame:center(Frame),
    wxFrame:show(Frame).


draw(Function, PaintDC) ->
        {FormulaText, {Min, Max}, FormulaFunc} = erlang:apply(?MODULE, Function, []),

        %% draw formula text (at the top left corner)
        %wxFont:new(Size, Family, Style, Weight)
        Font = wxFont:new(12, ?wxFONTFAMILY_ROMAN, ?wxFONTSTYLE_NORMAL, ?wxFONTWEIGHT_NORMAL),
        wxDC:setFont(PaintDC, Font),
        DrawText = io_lib:format("~p (~.2f, ~.2f)", [FormulaText, erlang:float(Min), erlang:float(Max)]),
        wxDC:drawText(PaintDC, DrawText, {10, 10}),

        %% draw coordinate lines
        Pen = wxPen:new(),
        wxPen:setWidth(Pen, 1),
        wxPen:setColour(Pen, 100, 100, 100),
        wxDC:setPen(PaintDC, Pen),
        wxDC:drawLine(PaintDC, {10, 240}, {410, 240}), % X axis
        wxDC:drawLine(PaintDC, {210, 40}, {210, 440}), % Y axis

        %% draw +x, +y text
        wxFont:setPointSize(Font, 10),
        wxDC:setFont(PaintDC, Font),
        wxDC:drawText(PaintDC, "+x", {392, 217}),
        wxDC:drawText(PaintDC, "+y", {214, 35}),

        %% draw min and max text at X axis
        MinAbs = erlang:abs(Min),
        MaxAbs = erlang:abs(Max),
        if
            MinAbs > MaxAbs -> MaxVal = MinAbs;
            true -> MaxVal = MaxAbs
        end,
        wxDC:drawText(PaintDC, io_lib:format("-~.2f", [erlang:float(MaxVal)]), {9, 250}),
        wxDC:drawText(PaintDC, io_lib:format("~.2f", [erlang:float(MaxVal)]), {382, 250}),

        %% draw function
        wxPen:setWidth(Pen, 1),
        wxPen:setColour(Pen, 0, 0, 0),
        wxDC:setPen(PaintDC, Pen),
        draw_function(PaintDC, Min, Max, FormulaFunc, 200/MaxVal, MaxVal/400),

        %%clean up
        wxPen:destroy(Pen),
        wxFont:destroy(Font),
        wxPaintDC:destroy(PaintDC).


draw_function(PaintDC, Min, Max, FormulaFunc, Scale, Step) when Min =< Max ->
    {X, Y} = {Min, FormulaFunc(Min)},
    {XScale, YScale} = {erlang:round(X * Scale), erlang:round(Y * Scale)},
    {XDraw, YDraw} = get_draw_point({XScale, YScale}),
    wxDC:drawPoint(PaintDC, {XDraw, YDraw}),
    draw_function(PaintDC, Min+Step, Max, FormulaFunc, Scale, Step);

draw_function(_PaintDC, _Min, _Max, _FormulaFunc, _Scale, _Step) ->
    ok.


get_draw_point({X, Y}) ->
    {X0, Y0} = {210, 240},
    {X0+X, Y0-Y}.


%% functions =================================================================

f0() ->
    {
        "y = 1/x + 2", 
        {-5, 5}, 
        fun(X) ->
            if
                X == 0 -> 0;
                true -> 1/X + 2
            end
        end
    }.


f1() ->
    {
        "y = 10*x^x", 
        {-5, 5}, 
        fun(X) ->
            10*X*X
        end
    }.

f2() ->
    {
        "y = -x*x + 2x", 
        {-5, 5}, 
        fun(X) ->
            -X*X+2*X
        end
    }.


func2() ->
    {
        "y = x^2", 
        {-5, 5}, 
        fun(X) -> 
            X*X
        end
    }.


func3() ->
    {
        "y = x^3", 
        {-5, 5}, 
        fun(X) -> 
            X*X*X
        end
    }.


func4() ->
    {
        "y = x^4", 
        {-5, 5}, 
        fun(X) -> 
            X*X*X*X
        end
    }.



sin() ->
    {
        "y = sin(x)", 
        {-2*math:pi(), 2*math:pi()}, 
        fun(X) -> 
            math:sin(X)
        end
    }.


cos() ->
    {
        "y = cos(x)", 
        {-2*math:pi(), 2*math:pi()}, 
        fun(X) -> 
            math:cos(X)
        end
    }.
