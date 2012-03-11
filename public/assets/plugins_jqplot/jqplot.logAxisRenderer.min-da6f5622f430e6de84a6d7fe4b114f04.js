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
(function(a){a.jqplot.LogAxisRenderer=function(){a.jqplot.LinearAxisRenderer.call(this),this.axisDefaults={base:10,tickDistribution:"power"}},a.jqplot.LogAxisRenderer.prototype=new a.jqplot.LinearAxisRenderer,a.jqplot.LogAxisRenderer.prototype.constructor=a.jqplot.LogAxisRenderer,a.jqplot.LogAxisRenderer.prototype.init=function(b){this.drawBaseline=!0,this.minorTicks="auto",this._scalefact=1,a.extend(!0,this,b),this._autoFormatString="%d",this._overrideFormatString=!1;for(var c in this.renderer.axisDefaults)this[c]==null&&(this[c]=this.renderer.axisDefaults[c]);this.resetDataBounds()},a.jqplot.LogAxisRenderer.prototype.createTicks=function(b){var c=this._ticks,d=this.ticks,e=this.name,f=this._dataBounds,g=this.name.charAt(0)==="x"?this._plotDimensions.width:this._plotDimensions.height,h,i,j,k,l,m,n,o=30;this._scalefact=(Math.max(g,o+1)-o)/300;if(d.length){for(n=0;n<d.length;n++){var p=d[n],q=new this.tickRenderer(this.tickOptions);p.constructor==Array?(q.value=p[0],q.label=p[1],this.showTicks?this.showTickMarks||(q.showMark=!1):(q.showLabel=!1,q.showMark=!1),q.setTick(p[0],this.name),this._ticks.push(q)):a.isPlainObject(p)?(a.extend(!0,q,p),q.axis=this.name,this._ticks.push(q)):(q.value=p,this.showTicks?this.showTickMarks||(q.showMark=!1):(q.showLabel=!1,q.showMark=!1),q.setTick(p,this.name),this._ticks.push(q))}this.numberTicks=d.length,this.min=this._ticks[0].value,this.max=this._ticks[this.numberTicks-1].value}else if(this.min==null&&this.max==null){i=f.min*(2-this.padMin),j=f.max*this.padMax;if(i==j){var r=.05;i*=1-r,j*=1+r}if(this.min!=null&&this.min<=0)throw"log axis minimum must be greater than 0";if(this.max!=null&&this.max<=0)throw"log axis maximum must be greater than 0";function s(a){var b=Math.pow(10,Math.floor(Math.log(a)/Math.LN10));return Math.ceil(a/b)*b}function t(a){var b=Math.pow(10,Math.floor(Math.log(a)/Math.LN10));return Math.floor(a/b)*b}var u,v;u=Math.pow(this.base,Math.floor(Math.log(i)/Math.log(this.base))),v=Math.pow(this.base,Math.ceil(Math.log(j)/Math.log(this.base)));var w=Math.round(Math.log(u)/Math.LN10);if(this.tickOptions==null||!this.tickOptions.formatString)this._overrideFormatString=!0;this.min=u,this.max=v;var x=this.max-this.min,y=this.minorTicks==="auto"?0:this.minorTicks,z;if(this.numberTicks==null)if(g>140){z=Math.round(Math.log(this.max/this.min)/Math.log(this.base)+1),z<2&&(z=2);if(y===0){var A=g/(z-1);A<100?y=0:A<190?y=1:A<250?y=3:A<600?y=4:y=9}}else z=2,y===0&&(y=1),y=0;else z=this.numberTicks;if(w>=0&&y!==3)this._autoFormatString="%d";else if(w<=0&&y===3){var A=-(w-1);this._autoFormatString="%."+Math.abs(w-1)+"f"}else if(w<0){var A=-w;this._autoFormatString="%."+Math.abs(w)+"f"}else this._autoFormatString="%d";var B,q,C,D,E,h;for(var n=0;n<z;n++){m=Math.pow(this.base,n-z+1)*this.max,q=new this.tickRenderer(this.tickOptions),this._overrideFormatString&&(q.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(q.showMark=!1):(q.showLabel=!1,q.showMark=!1),q.setTick(m,this.name),this._ticks.push(q);if(y&&n<z-1){D=Math.pow(this.base,n-z+2)*this.max,E=D-m,h=D/(y+1);for(var F=y-1;F>=0;F--)C=D-h*(F+1),q=new this.tickRenderer(this.tickOptions),this._overrideFormatString&&this._autoFormatString!=""&&(q.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(q.showMark=!1):(q.showLabel=!1,q.showMark=!1),q.setTick(C,this.name),this._ticks.push(q)}}}else if(this.min!=null&&this.max!=null){var G=a.extend(!0,{},this.tickOptions,{name:this.name,value:null}),H,I;if(this.numberTicks==null&&this.tickInterval==null){var J=Math.max(g,o+1),K=Math.ceil((J-o)/35+1),L=a.jqplot.LinearTickGenerator.bestConstrainedInterval(this.min,this.max,K);this._autoFormatString=L[3],H=L[2],I=L[4];for(var n=0;n<H;n++)G.value=this.min+n*I,q=new this.tickRenderer(G),this._overrideFormatString&&this._autoFormatString!=""&&(q.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(q.showMark=!1):(q.showLabel=!1,q.showMark=!1),this._ticks.push(q)}else if(this.numberTicks!=null&&this.tickInterval!=null){H=this.numberTicks;for(var n=0;n<H;n++)G.value=this.min+n*this.tickInterval,q=new this.tickRenderer(G),this._overrideFormatString&&this._autoFormatString!=""&&(q.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(q.showMark=!1):(q.showLabel=!1,q.showMark=!1),this._ticks.push(q)}}},a.jqplot.LogAxisRenderer.prototype.pack=function(b,c){var d=parseInt(this.base,10),e=this._ticks,f=function(a){return Math.log(a)/Math.log(d)},g=function(a){return Math.pow(Math.E,Math.log(d)*a)},h=f(this.max),i=f(this.min),j=c.max,k=c.min,l=this._label==null?!1:this._label.show;for(var m in b)this._elem.css(m,b[m]);this._offsets=c;var n=j-k,o=h-i;this.p2u=function(a){return g((a-k)*o/n+i)},this.u2p=function(a){return(f(a)-i)*n/o+k},this.name=="xaxis"||this.name=="x2axis"?(this.series_u2p=function(a){return(f(a)-i)*n/o},this.series_p2u=function(a){return g(a*o/n+i)}):(this.series_u2p=function(a){return(f(a)-h)*n/o},this.series_p2u=function(a){return g(a*o/n+h)});if(this.show)if(this.name=="xaxis"||this.name=="x2axis"){for(var p=0;p<e.length;p++){var q=e[p];if(q.show&&q.showLabel){var r;if(q.constructor==a.jqplot.CanvasAxisTickRenderer&&q.angle)switch(q.labelPosition){case"auto":q.angle<0?r=-q.getWidth()+q._textRenderer.height*Math.sin(-q._textRenderer.angle)/2:r=-q._textRenderer.height*Math.sin(q._textRenderer.angle)/2;break;case"end":r=-q.getWidth()+q._textRenderer.height*Math.sin(-q._textRenderer.angle)/2;break;case"start":r=-q._textRenderer.height*Math.sin(q._textRenderer.angle)/2;break;case"middle":r=-q.getWidth()/2+q._textRenderer.height*Math.sin(-q._textRenderer.angle)/2;break;default:r=-q.getWidth()/2+q._textRenderer.height*Math.sin(-q._textRenderer.angle)/2}else r=-q.getWidth()/2;var s=this.u2p(q.value)+r+"px";q._elem.css("left",s),q.pack()}}if(l){var t=this._label._elem.outerWidth(!0);this._label._elem.css("left",k+n/2-t/2+"px"),this.name=="xaxis"?this._label._elem.css("bottom","0px"):this._label._elem.css("top","0px"),this._label.pack()}}else{for(var p=0;p<e.length;p++){var q=e[p];if(q.show&&q.showLabel){var r;if(q.constructor==a.jqplot.CanvasAxisTickRenderer&&q.angle)switch(q.labelPosition){case"auto":case"end":q.angle<0?r=-q._textRenderer.height*Math.cos(-q._textRenderer.angle)/2:r=-q.getHeight()+q._textRenderer.height*Math.cos(q._textRenderer.angle)/2;break;case"start":q.angle>0?r=-q._textRenderer.height*Math.cos(-q._textRenderer.angle)/2:r=-q.getHeight()+q._textRenderer.height*Math.cos(q._textRenderer.angle)/2;break;case"middle":r=-q.getHeight()/2;break;default:r=-q.getHeight()/2}else r=-q.getHeight()/2;var s=this.u2p(q.value)+r+"px";q._elem.css("top",s),q.pack()}}if(l){var u=this._label._elem.outerHeight(!0);this._label._elem.css("top",j-n/2-u/2+"px"),this.name=="yaxis"?this._label._elem.css("left","0px"):this._label._elem.css("right","0px"),this._label.pack()}}}})(jQuery)