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
(function(a){a.jqplot.OHLCRenderer=function(){a.jqplot.LineRenderer.call(this),this.candleStick=!1,this.tickLength="auto",this.bodyWidth="auto",this.openColor=null,this.closeColor=null,this.wickColor=null,this.fillUpBody=!1,this.fillDownBody=!0,this.upBodyColor=null,this.downBodyColor=null,this.hlc=!1,this.lineWidth=1.5,this._tickLength,this._bodyWidth},a.jqplot.OHLCRenderer.prototype=new a.jqplot.LineRenderer,a.jqplot.OHLCRenderer.prototype.constructor=a.jqplot.OHLCRenderer,a.jqplot.OHLCRenderer.prototype.init=function(b){b=b||{},this.lineWidth=b.lineWidth||1.5,a.jqplot.LineRenderer.prototype.init.call(this,b),this._type="ohlc";var c=this._yaxis._dataBounds,d=this._plotData;if(d[0].length<5){this.renderer.hlc=!0;for(var e=0;e<d.length;e++){if(d[e][2]<c.min||c.min==null)c.min=d[e][2];if(d[e][1]>c.max||c.max==null)c.max=d[e][1]}}else for(var e=0;e<d.length;e++){if(d[e][3]<c.min||c.min==null)c.min=d[e][3];if(d[e][2]>c.max||c.max==null)c.max=d[e][2]}},a.jqplot.OHLCRenderer.prototype.draw=function(b,c,d){var e=this.data,f=this._xaxis.min,g=this._xaxis.max,h=0,i=e.length,j=this._xaxis.series_u2p,k=this._yaxis.series_u2p,l,m,n,o,p,q,r,s,t,u=this.renderer,v=d!=undefined?d:{},w=v.shadow!=undefined?v.shadow:this.shadow,x=v.fill!=undefined?v.fill:this.fill,y=v.fillAndStroke!=undefined?v.fillAndStroke:this.fillAndStroke;u.bodyWidth=v.bodyWidth!=undefined?v.bodyWidth:u.bodyWidth,u.tickLength=v.tickLength!=undefined?v.tickLength:u.tickLength,b.save();if(this.show){var z,A,B,C,D;for(var l=0;l<e.length;l++)e[l][0]<f?h=l:e[l][0]<g&&(i=l+1);var E=this.gridData[i-1][0]-this.gridData[h][0],F=i-h;try{var G=Math.abs(this._xaxis.series_u2p(parseInt(this._xaxis._intervalStats[0].sortedIntervals[0].interval,10))-this._xaxis.series_u2p(0))}catch(H){var G=E/F}u.candleStick?typeof u.bodyWidth=="number"?u._bodyWidth=u.bodyWidth:u._bodyWidth=Math.min(20,G/1.65):typeof u.tickLength=="number"?u._tickLength=u.tickLength:u._tickLength=Math.min(10,G/3.5);for(var l=h;l<i;l++)z=j(e[l][0]),u.hlc?(A=null,B=k(e[l][1]),C=k(e[l][2]),D=k(e[l][3])):(A=k(e[l][1]),B=k(e[l][2]),C=k(e[l][3]),D=k(e[l][4])),t={},u.candleStick&&!u.hlc?(q=u._bodyWidth,r=z-q/2,D<A?(u.wickColor?t.color=u.wickColor:u.downBodyColor&&(t.color=u.upBodyColor),n=a.extend(!0,{},v,t),u.shapeRenderer.draw(b,[[z,B],[z,D]],n),u.shapeRenderer.draw(b,[[z,A],[z,C]],n),t={},o=D,p=A-D,u.fillUpBody?t.fillRect=!0:(t.strokeRect=!0,q-=this.lineWidth,r=z-q/2),u.upBodyColor&&(t.color=u.upBodyColor,t.fillStyle=u.upBodyColor),s=[r,o,q,p]):D>A?(u.wickColor?t.color=u.wickColor:u.downBodyColor&&(t.color=u.downBodyColor),n=a.extend(!0,{},v,t),u.shapeRenderer.draw(b,[[z,B],[z,A]],n),u.shapeRenderer.draw(b,[[z,D],[z,C]],n),t={},o=A,p=D-A,u.fillDownBody?t.fillRect=!0:(t.strokeRect=!0,q-=this.lineWidth,r=z-q/2),u.downBodyColor&&(t.color=u.downBodyColor,t.fillStyle=u.downBodyColor),s=[r,o,q,p]):(u.wickColor&&(t.color=u.wickColor),n=a.extend(!0,{},v,t),u.shapeRenderer.draw(b,[[z,B],[z,C]],n),t={},t.fillRect=!1,t.strokeRect=!1,r=[z-q/2,A],o=[z+q/2,D],q=null,p=null,s=[r,o]),n=a.extend(!0,{},v,t),u.shapeRenderer.draw(b,s,n)):(m=v.color,u.openColor&&(v.color=u.openColor),u.hlc||u.shapeRenderer.draw(b,[[z-u._tickLength,A],[z,A]],v),v.color=m,u.wickColor&&(v.color=u.wickColor),u.shapeRenderer.draw(b,[[z,B],[z,C]],v),v.color=m,u.closeColor&&(v.color=u.closeColor),u.shapeRenderer.draw(b,[[z,D],[z+u._tickLength,D]],v),v.color=m)}b.restore()},a.jqplot.OHLCRenderer.prototype.drawShadow=function(a,b,c){},a.jqplot.OHLCRenderer.checkOptions=function(a,b,c){c.highlighter||(c.highlighter={showMarker:!1,tooltipAxes:"y",yvalues:4,formatString:'<table class="jqplot-highlighter"><tr><td>date:</td><td>%s</td></tr><tr><td>open:</td><td>%s</td></tr><tr><td>hi:</td><td>%s</td></tr><tr><td>low:</td><td>%s</td></tr><tr><td>close:</td><td>%s</td></tr></table>'})}})(jQuery)