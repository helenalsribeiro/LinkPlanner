function sbcmplx(varargin)
%SBCMPLX  Signal Browser Complex Popup callback routine.
%   Internal function.
%  SBCMPLX(type_flag) sets the signal ydata in the signal
%  browser according to the 'type_flag' parameter
%    type_flag = 0 or undefined <-- prompt user
%                1              <-- real
%                2              <-- imag
%                3              <-- mag
%                4              <-- anlge

%   Copyright 1988-2012 The MathWorks, Inc.

%   TPK 12/5/95
%   TPK 5/31/99 added type_flag parameter
%   TPK 6/19/99 changed to radio buttons

if nargin < 1
    type_flag = 0;
elseif isstr(varargin{1})
    % call internal function
    if (nargout == 0)
        feval(varargin{:});
    else
       [varargout{1:nargout}] = feval(varargin{:});
    end
    return
else
    type_flag = varargin{1};
end

ud = get(gcf,'UserData');

if ud.pointer==2   % help mode
    spthelp('exit','complex_selection')
    return
end

% Old complex selection value:
pv_old = get(ud.toolbar.complex,'UserData');

% New one:
if ~any(type_flag == [0 1 2 3 4])
    %illegal input, just return
    return
elseif type_flag == 0

    %pv = listdlg('PromptString',{'Select how you would like' ...
    %    'to display the signal(s):'},...
    %    'selectionmode','single',...
    %    'liststring',{'real part' 'imaginary part' 'magnitude' 'angle'},...
    %    'initialvalue',pv_old,...
    %    'listsize',[200 100]);

    fpos=get(gcf,'Position');
    pt = fpos(1:2)+[40 fpos(4)];
    fig1 = complexdlg(pt);
    ud_d = get(fig1,'UserData');
    set(ud_d.rb(pv_old),'Value',1) % <-- set radio button to current
                                   % value of real/imag/mag/angle display
    waitfor(fig1,'userdata')     
    ud_d = get(fig1,'UserData');  % userdata of dialog
    switch(ud_d.msg)
    case 'ok'
        for k=1:4
            if get(ud_d.rb(k),'Value')
                pv = k;
            end
        end
    case 'cancel'
        pv = [];
    end
    delete(fig1)
    if isempty(pv), return, end
else
    pv = type_flag;
end

if isequal(pv,pv_old)
    return
end
set(ud.toolbar.complex,'UserData',pv)  % save value
switch pv
case 1
    selectStr = getString(message('signal:sptoolgui:LReal'));
case 2
    selectStr = getString(message('signal:sptoolgui:LImaginary'));
case 3
    selectStr = getString(message('signal:sptoolgui:LMagnitude'));
case 4
    selectStr = getString(message('signal:sptoolgui:LAngle'));
end
set(ud.toolbar.complex,'TooltipString',...
     sprintf('%s',getString(message('signal:sptoolgui:ComplexSignalsCurrentDisplay',selectStr))))

for i = 1:length(ud.lines)
    var = ud.lines(i).data;
    switch pv
    case 1    % real
        var = real(var);
    case 2    % imaginary
        var = imag(var);
    case 3    % magnitude
        var = abs(var);
    case 4    % angle
        var = angle(var);
    end
    for j = 1:length(ud.lines(i).h)
        set(ud.lines(i).h(j),'YData',var(:,j))
        if ud.prefs.tool.panner
            set(ud.lines(i).ph(j),'YData',var(:,j))
        end
    end

end

if length(ud.lines)>0
    set(ud.mainaxes,'YLimMode','auto')  % auto range ylimits
    if ud.prefs.tool.ruler
        set(ud.ruler.lines,'Visible','off')   % don't let these lines effect the
                                              % ylimit computation
        set(ud.ruler.markers,'Visible','off')
    end
    ylim = get(ud.mainaxes,'YLim');
    set(ud.mainaxes,'YLim',ylim)  % set ylimmode to maunal
    ud.limits.ylim = ylim;
    set(gcf,'UserData',ud)

    if ud.prefs.tool.panner
        panaxes = ud.panner.panaxes;
        set(panaxes,'XLim',ud.limits.xlim,'YLim',ylim)
        panner('update')
    end

    % update the ruler lines
    if ud.prefs.tool.ruler
        ruler('showlines',gcf)
        ruler('newlimits')
        ruler('newsig')
    end

end

function fig = complexdlg(pt)
% Create complex dialog with 4 radio buttons
% Places upper left corner of dialog at pixel location pt

mat1={    getString(message('signal:sptoolgui:SelectHowYouWouldLike'))};

h0 = figure('CloseRequestFcn','sbswitch(''sbcmplx'',''cancelcallback'')', ...
	'Color',[0.8 0.8 0.8], ...
    'DockControls','off',...
    'Name',getString(message('signal:sptoolgui:ComplexSignalDisplay')),...
	'NumberTitle','off', ...
	'Position',[pt(1) pt(2)-206 232 206], ...
	'Resize','off', ...
    'WindowStyle','modal',...
	'ToolBar','none',...
   'KeyPressFcn','sbswitch(''sbcmplx'',''keypressfcn'')');
h1 = uicontrol('Parent',h0, ...
	'Position',[0 0 232 206], ...
	'Style','frame', ...
	'Tag','Frame3');
h1 = uicontrol('Parent',h0, ...
	'ListboxTop',0, ...
	'Position',[8 8 216 34], ...
	'Style','frame', ...
	'Tag','Frame2');
h1 = uicontrol('Parent',h0, ...
	'ListboxTop',0, ...
	'Position',[8 51 216 148], ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[17 155 200 40], ...
	'String',mat1, ...
	'Style','text', ...
	'Tag','StaticText1');
%h1 = uicontrol('Parent',h0, ...
%	'Callback','sbswitch(''sbcmplx'',''okcallback'')', ...
%	'ListboxTop',0, ...
%	'Position',[16 16 96 18], ...
%	'String','Ok', ...
%	'Tag','Pushbutton2');
h1 = uicontrol('Parent',h0, ...
	'Callback','sbswitch(''sbcmplx'',''cancelcallback'')', ...
	'ListboxTop',0, ...
	'Position',[64 16 96 18], ...
	'String',getString(message('signal:sptoolgui:Cancel')), ...
	'Tag','Pushbutton1');
ud.rb(1) = uicontrol('Parent',h0, ...
	'ListboxTop',0, ...
	'Callback','sbswitch(''sbcmplx'',''radiocallback'',1)', ...
	'Position',[46 133 140 20], ...
	'String',getString(message('signal:sptoolgui:RealPart')), ...
	'Style','radiobutton', ...
	'Tag','Radiobutton1');
ud.rb(2) = uicontrol('Parent',h0, ...
	'ListboxTop',0, ...
	'Callback','sbswitch(''sbcmplx'',''radiocallback'',2)', ...
	'Position',[46 109 140 20], ...
	'String',getString(message('signal:sptoolgui:ImaginaryPart')), ...
	'Style','radiobutton', ...
	'Tag','Radiobutton1');
ud.rb(3) = uicontrol('Parent',h0, ...
	'ListboxTop',0, ...
	'Callback','sbswitch(''sbcmplx'',''radiocallback'',3)', ...
	'Position',[46 84 140 20], ...
	'String',getString(message('signal:sptoolgui:Magnitude')), ...
	'Style','radiobutton', ...
	'Tag','Radiobutton1');
ud.rb(4) = uicontrol('Parent',h0, ...
	'ListboxTop',0, ...
	'Callback','sbswitch(''sbcmplx'',''radiocallback'',4)', ...
	'Position',[46 59 140 20], ...
	'String',getString(message('signal:sptoolgui:Angle')), ...
	'Style','radiobutton', ...
	'Tag','Radiobutton1');
ud.msg = '';
set(h0,'UserData',ud)
if nargout > 0, fig = h0; end


function okcallback
% OK button callback
    ud = get(gcf,'UserData');
    ud.msg = 'ok';
    set(gcf,'UserData',ud)

function cancelcallback
% cancel button callback
    ud = get(gcf,'UserData');
    ud.msg = 'cancel';
    set(gcf,'UserData',ud)

function radiocallback(ind)
% callback of each of the radio buttons
    ud=get(gcf,'UserData');
    for i=1:4
        set(ud.rb(i),'Value',i==ind)
    end
    % Now wire the dialog to accept as soon as a radio is
    % clicked:
    ud.msg = 'ok';
    set(gcf,'UserData',ud)

function keypressfcn
% if user hits esc, cancel
% if user hits return, accept
    ESC = 27;
    RET = 13;
    switch(abs(get(gcf,'CurrentCharacter')))
    case ESC
        ud = get(gcf,'UserData');
        ud.msg = 'cancel';
        set(gcf,'UserData',ud)
    case RET
        ud = get(gcf,'UserData');
        ud.msg = 'ok';
        set(gcf,'UserData',ud)
    end

