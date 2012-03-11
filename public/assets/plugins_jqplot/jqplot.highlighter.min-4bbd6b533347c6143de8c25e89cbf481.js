/**
 * jqPlot
 * Pure JavaScript plotting plugin using jQuery
 *
 * Version: 1.0.0b2_r1012
 *
 * Copyright (c) 2009-2011 Chris Leonello
 * jqPlot is currently available for use in all personal or commercial projects 
 * under both the MIT (http://www.opensource.org/licenses/mit-license.php) and GPL 
 * version 2.0 (http://www.gnu.org/licenses/gpl-2.0.html) licenses. This means that you can 
 * choose the license that best suits your project and use it accordingly. 
 *
 * Although not required, the author would appreciate an email letting him 
 * know of any substantial use of jqPlot.  You can reach the author at: 
 * chris at jqplot dot com or see http://www.jqplot.com/info.php .
 *
 * If you are feeling kind and generous, consider supporting the project by
 * making a donation at: http://www.jqplot.com/donate.php .
 *
 * sprintf functions contained in jqplot.sprintf.js by Ash Searle:
 *
 *     version 2007.04.27
 *     author Ash Searle
 *     http://hexmen.com/blog/2007/03/printf-sprintf/
 *     http://hexmen.com/js/sprintf.js
 *     The author (Ash Searle) has placed this code in the public domain:
 *     "This code is unrestricted: you are free to use it however you like."
 *
 * included jsDate library by Chris Leonello:
 *
 * Copyright (c) 2010-2011 Chris Leonello
 *
 * jsDate is currently available for use in all personal or commercial projects 
 * under both the MIT and GPL version 2.0 licenses. This means that you can 
 * choose the license that best suits your project and use it accordingly.
 *
 * jsDate borrows many concepts and ideas from the Date Instance 
 * Methods by Ken Snyder along with some parts of Ken's actual code.
 * 
 * Ken's origianl Date Instance Methods and copyright notice:
 * 
 * Ken Snyder (ken d snyder at gmail dot com)
 * 2008-09-10
 * version 2.0.2 (http://kendsnyder.com/sandbox/date/)     
 * Creative Commons Attribution License 3.0 (http://creativecommons.org/licenses/by/3.0/)
 *
 * jqplotToImage function based on Larry Siden's export-jqplot-to-png.js.
 * Larry has generously given permission to adapt his code for inclusion
 * into jqPlot.
 *
 * Larry's original code can be found here:
 *
 * https://github.com/lsiden/export-jqplot-to-png
 * 
 * 
 */
(function(a){function e(b,c){var d=b.plugins.highlighter,e=b.series[c.seriesIndex],f=e.markerRenderer,g=d.markerRenderer;g.style=f.style,g.lineWidth=f.lineWidth+d.lineWidthAdjust,g.size=f.size+d.sizeAdjust;var h=a.jqplot.getColorComponents(f.color),i=[h[0],h[1],h[2]],j=h[3]>=.6?h[3]*.6:h[3]*(2-h[3]);g.color="rgba("+i[0]+","+i[1]+","+i[2]+","+j+")",g.init(),g.draw(e.gridData[c.pointIndex][0],e.gridData[c.pointIndex][1],d.highlightCanvas._ctx)}function f(e,f,g){var h=e.plugins.highlighter,i=h._tooltipElem,j=f.highlighter||{},k=a.extend(!0,{},h,j);if(k.useAxesFormatters){var l=f._xaxis._ticks[0].formatter,m=f._yaxis._ticks[0].formatter,n=f._xaxis._ticks[0].formatString,o=f._yaxis._ticks[0].formatString,p,q=l(n,g.data[0]),r=[];for(var s=1;s<k.yvalues+1;s++)r.push(m(o,g.data[s]));if(typeof k.formatString=="string")switch(k.tooltipAxes){case"both":case"xy":r.unshift(q),r.unshift(k.formatString),p=a.jqplot.sprintf.apply(a.jqplot.sprintf,r);break;case"yx":r.push(q),r.unshift(k.formatString),p=a.jqplot.sprintf.apply(a.jqplot.sprintf,r);break;case"x":p=a.jqplot.sprintf.apply(a.jqplot.sprintf,[k.formatString,q]);break;case"y":r.unshift(k.formatString),p=a.jqplot.sprintf.apply(a.jqplot.sprintf,r);break;default:r.unshift(q),r.unshift(k.formatString),p=a.jqplot.sprintf.apply(a.jqplot.sprintf,r)}else switch(k.tooltipAxes){case"both":case"xy":p=q;for(var s=0;s<r.length;s++)p+=k.tooltipSeparator+r[s];break;case"yx":p="";for(var s=0;s<r.length;s++)p+=r[s]+k.tooltipSeparator;p+=q;break;case"x":p=q;break;case"y":p=r.join(k.tooltipSeparator);break;default:p=q;for(var s=0;s<r.length;s++)p+=k.tooltipSeparator+r[s]}}else{var p;typeof k.formatString=="string"?p=a.jqplot.sprintf.apply(a.jqplot.sprintf,[k.formatString].concat(g.data)):k.tooltipAxes=="both"||k.tooltipAxes=="xy"?p=a.jqplot.sprintf(k.tooltipFormatString,g.data[0])+k.tooltipSeparator+a.jqplot.sprintf(k.tooltipFormatString,g.data[1]):k.tooltipAxes=="yx"?p=a.jqplot.sprintf(k.tooltipFormatString,g.data[1])+k.tooltipSeparator+a.jqplot.sprintf(k.tooltipFormatString,g.data[0]):k.tooltipAxes=="x"?p=a.jqplot.sprintf(k.tooltipFormatString,g.data[0]):k.tooltipAxes=="y"&&(p=a.jqplot.sprintf(k.tooltipFormatString,g.data[1]))}a.isFunction(k.tooltipContentEditor)&&(p=k.tooltipContentEditor(p,g.seriesIndex,g.pointIndex,e)),i.html(p);var t={x:g.gridData[0],y:g.gridData[1]},u=0,v=.707;f.markerRenderer.show==1&&(u=(f.markerRenderer.size+k.sizeAdjust)/2);var w=b;f.fillToZero&&f.fill&&g.data[1]<0&&(w=d);switch(w[c[k.tooltipLocation]]){case"nw":var x=t.x+e._gridPadding.left-i.outerWidth(!0)-k.tooltipOffset-v*u,y=t.y+e._gridPadding.top-k.tooltipOffset-i.outerHeight(!0)-v*u;break;case"n":var x=t.x+e._gridPadding.left-i.outerWidth(!0)/2,y=t.y+e._gridPadding.top-k.tooltipOffset-i.outerHeight(!0)-u;break;case"ne":var x=t.x+e._gridPadding.left+k.tooltipOffset+v*u,y=t.y+e._gridPadding.top-k.tooltipOffset-i.outerHeight(!0)-v*u;break;case"e":var x=t.x+e._gridPadding.left+k.tooltipOffset+u,y=t.y+e._gridPadding.top-i.outerHeight(!0)/2;break;case"se":var x=t.x+e._gridPadding.left+k.tooltipOffset+v*u,y=t.y+e._gridPadding.top+k.tooltipOffset+v*u;break;case"s":var x=t.x+e._gridPadding.left-i.outerWidth(!0)/2,y=t.y+e._gridPadding.top+k.tooltipOffset+u;break;case"sw":var x=t.x+e._gridPadding.left-i.outerWidth(!0)-k.tooltipOffset-v*u,y=t.y+e._gridPadding.top+k.tooltipOffset+v*u;break;case"w":var x=t.x+e._gridPadding.left-i.outerWidth(!0)-k.tooltipOffset-u,y=t.y+e._gridPadding.top-i.outerHeight(!0)/2;break;default:var x=t.x+e._gridPadding.left-i.outerWidth(!0)-k.tooltipOffset-v*u,y=t.y+e._gridPadding.top-k.tooltipOffset-i.outerHeight(!0)-v*u}i.css("left",x),i.css("top",y),k.fadeTooltip?i.stop(!0,!0).fadeIn(k.tooltipFadeSpeed):i.show(),i=null}function g(a,b,c,d,g){var h=g.plugins.highlighter,i=g.plugins.cursor;if(h.show)if(d==null&&h.isHighlighting){var j=h.highlightCanvas._ctx;j.clearRect(0,0,j.canvas.width,j.canvas.height),h.fadeTooltip?h._tooltipElem.fadeOut(h.tooltipFadeSpeed):h._tooltipElem.hide(),h.bringSeriesToFront&&g.restorePreviousSeriesOrder(),h.isHighlighting=!1,h.currentNeighbor=null,j=null}else if(d!=null&&g.series[d.seriesIndex].showHighlight&&!h.isHighlighting)h.isHighlighting=!0,h.currentNeighbor=d,h.showMarker&&e(g,d),h.showTooltip&&(!i||!i._zoom.started)&&f(g,g.series[d.seriesIndex],d),h.bringSeriesToFront&&g.moveSeriesToFront(d.seriesIndex);else if(d!=null&&h.isHighlighting&&h.currentNeighbor!=d&&g.series[d.seriesIndex].showHighlight){var j=h.highlightCanvas._ctx;j.clearRect(0,0,j.canvas.width,j.canvas.height),h.isHighlighting=!0,h.currentNeighbor=d,h.showMarker&&e(g,d),h.showTooltip&&(!i||!i._zoom.started)&&f(g,g.series[d.seriesIndex],d),h.bringSeriesToFront&&g.moveSeriesToFront(d.seriesIndex)}}a.jqplot.eventListenerHooks.push(["jqplotMouseMove",g]),a.jqplot.Highlighter=function(b){this.show=a.jqplot.config.enablePlugins,this.markerRenderer=new a.jqplot.MarkerRenderer({shadow:!1}),this.showMarker=!0,this.lineWidthAdjust=2.5,this.sizeAdjust=5,this.showTooltip=!0,this.tooltipLocation="nw",this.fadeTooltip=!0,this.tooltipFadeSpeed="fast",this.tooltipOffset=2,this.tooltipAxes="both",this.tooltipSeparator=", ",this.tooltipContentEditor=null,this.useAxesFormatters=!0,this.tooltipFormatString="%.5P",this.formatString=null,this.yvalues=1,this.bringSeriesToFront=!1,this._tooltipElem,this.isHighlighting=!1,this.currentNeighbor=null,a.extend(!0,this,b)};var b=["nw","n","ne","e","se","s","sw","w"],c={nw:0,n:1,ne:2,e:3,se:4,s:5,sw:6,w:7},d=["se","s","sw","w","nw","n","ne","e"];a.jqplot.Highlighter.init=function(b,c,d){var e=d||{};this.plugins.highlighter=new a.jqplot.Highlighter(e.highlighter)},a.jqplot.Highlighter.parseOptions=function(a,b){this.showHighlight=!0},a.jqplot.Highlighter.postPlotDraw=function(){this.plugins.highlighter&&this.plugins.highlighter.highlightCanvas&&(this.plugins.highlighter.highlightCanvas.resetCanvas(),this.plugins.highlighter.highlightCanvas=null),this.plugins.highlighter&&this.plugins.highlighter._tooltipElem&&(this.plugins.highlighter._tooltipElem.emptyForce(),this.plugins.highlighter._tooltipElem=null),this.plugins.highlighter.highlightCanvas=new a.jqplot.GenericCanvas,this.eventCanvas._elem.before(this.plugins.highlighter.highlightCanvas.createElement(this._gridPadding,"jqplot-highlight-canvas",this._plotDimensions,this)),this.plugins.highlighter.highlightCanvas.setContext();var b=document.createElement("div");this.plugins.highlighter._tooltipElem=a(b),b=null,this.plugins.highlighter._tooltipElem.addClass("jqplot-highlighter-tooltip"),this.plugins.highlighter._tooltipElem.css({position:"absolute",display:"none"}),this.eventCanvas._elem.before(this.plugins.highlighter._tooltipElem)},a.jqplot.preInitHooks.push(a.jqplot.Highlighter.init),a.jqplot.preParseSeriesOptionsHooks.push(a.jqplot.Highlighter.parseOptions),a.jqplot.postDrawHooks.push(a.jqplot.Highlighter.postPlotDraw)})(jQuery)