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
(function(a){a.jqplot.PyramidGridRenderer=function(){a.jqplot.CanvasGridRenderer.call(this)},a.jqplot.PyramidGridRenderer.prototype=new a.jqplot.CanvasGridRenderer,a.jqplot.PyramidGridRenderer.prototype.constructor=a.jqplot.PyramidGridRenderer,a.jqplot.CanvasGridRenderer.prototype.init=function(b){this._ctx,this.plotBands={show:!1,color:"rgb(230, 219, 179)",axis:"y",start:null,interval:10},a.extend(!0,this,b);var c={lineJoin:"miter",lineCap:"round",fill:!1,isarc:!1,angle:this.shadowAngle,offset:this.shadowOffset,alpha:this.shadowAlpha,depth:this.shadowDepth,lineWidth:this.shadowWidth,closePath:!1,strokeStyle:this.shadowColor};this.renderer.shadowRenderer.init(c)},a.jqplot.PyramidGridRenderer.prototype.draw=function(){function C(c,d,e,f,g){b.save(),g=g||{};if(g.lineWidth==null||g.lineWidth!=0)a.extend(!0,b,g),b.beginPath(),b.moveTo(c,d),b.lineTo(e,f),b.stroke();b.restore()}this._ctx=this._elem.get(0).getContext("2d");var b=this._ctx,c=this._axes,d=c.xaxis.u2p,e=c.yMidAxis.u2p,f=c.xaxis.max/1e3,g=d(0),h=d(f),i=["xaxis","yaxis","x2axis","y2axis","yMidAxis"];b.save(),b.clearRect(0,0,this._plotDimensions.width,this._plotDimensions.height),b.fillStyle=this.backgroundColor||this.background,b.fillRect(this._left,this._top,this._width,this._height);if(this.plotBands.show){b.save();var j=this.plotBands;b.fillStyle=j.color;var k,l,m,n,o;j.axis.charAt(0)==="x"?c.xaxis.show&&(k=c.xaxis):j.axis.charAt(0)==="y"&&(c.yaxis.show?k=c.yaxis:c.y2axis.show?k=c.y2axis:c.yMidAxis.show&&(k=c.yMidAxis));if(k!==undefined){var p=j.start;p===null&&(p=k.min);for(var q=p;q<k.max;q+=2*j.interval)k.name.charAt(0)==="y"&&(l=this._left,m=k.series_u2p(q+j.interval)+this._top,n=this._right-this._left,o=k.series_u2p(p)-k.series_u2p(p+j.interval),b.fillRect(l,m,n,o))}b.restore()}b.save(),b.lineJoin="miter",b.lineCap="butt",b.lineWidth=this.gridLineWidth,b.strokeStyle=this.gridLineColor;var r,s,t,u;for(var q=5;q>0;q--){var v=i[q-1],k=c[v],w=k._ticks,x=w.length;if(k.show){if(k.drawBaseline){var y={};k.baselineWidth!==null&&(y.lineWidth=k.baselineWidth),k.baselineColor!==null&&(y.strokeStyle=k.baselineColor);switch(v){case"xaxis":c.yMidAxis.show?(C(this._left,this._bottom,g,this._bottom,y),C(h,this._bottom,this._right,this._bottom,y)):C(this._left,this._bottom,this._right,this._bottom,y);break;case"yaxis":C(this._left,this._bottom,this._left,this._top,y);break;case"yMidAxis":C(g,this._bottom,g,this._top,y),C(h,this._bottom,h,this._top,y);break;case"x2axis":c.yMidAxis.show?(C(this._left,this._top,g,this._top,y),C(h,this._top,this._right,this._top,y)):C(this._left,this._bottom,this._right,this._bottom,y);break;case"y2axis":C(this._right,this._bottom,this._right,this._top,y)}}for(var z=x;z>0;z--){var A=w[z-1];if(A.show){var B=Math.round(k.u2p(A.value))+.5;switch(v){case"xaxis":A.showGridline&&this.drawGridlines&&(!A.isMinorTick||k.showMinorTicks)&&C(B,this._top,B,this._bottom);if(A.showMark&&A.mark&&(!A.isMinorTick||k.showMinorTicks)){t=A.markSize,u=A.mark;var B=Math.round(k.u2p(A.value))+.5;switch(u){case"outside":r=this._bottom,s=this._bottom+t;break;case"inside":r=this._bottom-t,s=this._bottom;break;case"cross":r=this._bottom-t,s=this._bottom+t;break;default:r=this._bottom,s=this._bottom+t}this.shadow&&this.renderer.shadowRenderer.draw(b,[[B,r],[B,s]],{lineCap:"butt",lineWidth:this.gridLineWidth,offset:this.gridLineWidth*.75,depth:2,fill:!1,closePath:!1}),C(B,r,B,s)}break;case"yaxis":A.showGridline&&this.drawGridlines&&(!A.isMinorTick||k.showMinorTicks)&&C(this._right,B,this._left,B);if(A.showMark&&A.mark&&(!A.isMinorTick||k.showMinorTicks)){t=A.markSize,u=A.mark;var B=Math.round(k.u2p(A.value))+.5;switch(u){case"outside":r=this._left-t,s=this._left;break;case"inside":r=this._left,s=this._left+t;break;case"cross":r=this._left-t,s=this._left+t;break;default:r=this._left-t,s=this._left}this.shadow&&this.renderer.shadowRenderer.draw(b,[[r,B],[s,B]],{lineCap:"butt",lineWidth:this.gridLineWidth*1.5,offset:this.gridLineWidth*.75,fill:!1,closePath:!1}),C(r,B,s,B,{strokeStyle:k.borderColor})}break;case"yMidAxis":A.showGridline&&this.drawGridlines&&(!A.isMinorTick||k.showMinorTicks)&&(C(this._left,B,g,B),C(h,B,this._right,B));if(A.showMark&&A.mark&&(!A.isMinorTick||k.showMinorTicks)){t=A.markSize,u=A.mark;var B=Math.round(k.u2p(A.value))+.5;r=g,s=g+t,this.shadow&&this.renderer.shadowRenderer.draw(b,[[r,B],[s,B]],{lineCap:"butt",lineWidth:this.gridLineWidth*1.5,offset:this.gridLineWidth*.75,fill:!1,closePath:!1}),C(r,B,s,B,{strokeStyle:k.borderColor}),r=h-t,s=h,this.shadow&&this.renderer.shadowRenderer.draw(b,[[r,B],[s,B]],{lineCap:"butt",lineWidth:this.gridLineWidth*1.5,offset:this.gridLineWidth*.75,fill:!1,closePath:!1}),C(r,B,s,B,{strokeStyle:k.borderColor})}break;case"x2axis":A.showGridline&&this.drawGridlines&&(!A.isMinorTick||k.showMinorTicks)&&C(B,this._bottom,B,this._top);if(A.showMark&&A.mark&&(!A.isMinorTick||k.showMinorTicks)){t=A.markSize,u=A.mark;var B=Math.round(k.u2p(A.value))+.5;switch(u){case"outside":r=this._top-t,s=this._top;break;case"inside":r=this._top,s=this._top+t;break;case"cross":r=this._top-t,s=this._top+t;break;default:r=this._top-t,s=this._top}this.shadow&&this.renderer.shadowRenderer.draw(b,[[B,r],[B,s]],{lineCap:"butt",lineWidth:this.gridLineWidth,offset:this.gridLineWidth*.75,depth:2,fill:!1,closePath:!1}),C(B,r,B,s)}break;case"y2axis":A.showGridline&&this.drawGridlines&&(!A.isMinorTick||k.showMinorTicks)&&C(this._left,B,this._right,B);if(A.showMark&&A.mark&&(!A.isMinorTick||k.showMinorTicks)){t=A.markSize,u=A.mark;var B=Math.round(k.u2p(A.value))+.5;switch(u){case"outside":r=this._right,s=this._right+t;break;case"inside":r=this._right-t,s=this._right;break;case"cross":r=this._right-t,s=this._right+t;break;default:r=this._right,s=this._right+t}this.shadow&&this.renderer.shadowRenderer.draw(b,[[r,B],[s,B]],{lineCap:"butt",lineWidth:this.gridLineWidth*1.5,offset:this.gridLineWidth*.75,fill:!1,closePath:!1}),C(r,B,s,B,{strokeStyle:k.borderColor})}break;default:}}}A=null}k=null,w=null}b.restore();if(this.shadow)if(c.yMidAxis.show){var D=[[this._left,this._bottom],[g,this._bottom]];this.renderer.shadowRenderer.draw(b,D);var D=[[h,this._bottom],[this._right,this._bottom],[this._right,this._top]];this.renderer.shadowRenderer.draw(b,D);var D=[[g,this._bottom],[g,this._top]];this.renderer.shadowRenderer.draw(b,D)}else{var D=[[this._left,this._bottom],[this._right,this._bottom],[this._right,this._top]];this.renderer.shadowRenderer.draw(b,D)}this.borderWidth!=0&&this.drawBorder&&(c.yMidAxis.show?(C(this._left,this._top,g,this._top,{lineCap:"round",strokeStyle:c.x2axis.borderColor,lineWidth:c.x2axis.borderWidth}),C(h,this._top,this._right,this._top,{lineCap:"round",strokeStyle:c.x2axis.borderColor,lineWidth:c.x2axis.borderWidth}),C(this._right,this._top,this._right,this._bottom,{lineCap:"round",strokeStyle:c.y2axis.borderColor,lineWidth:c.y2axis.borderWidth}),C(this._right,this._bottom,h,this._bottom,{lineCap:"round",strokeStyle:c.xaxis.borderColor,lineWidth:c.xaxis.borderWidth}),C(g,this._bottom,this._left,this._bottom,{lineCap:"round",strokeStyle:c.xaxis.borderColor,lineWidth:c.xaxis.borderWidth}),C(this._left,this._bottom,this._left,this._top,{lineCap:"round",strokeStyle:c.yaxis.borderColor,lineWidth:c.yaxis.borderWidth}),C(g,this._bottom,g,this._top,{lineCap:"round",strokeStyle:c.yaxis.borderColor,lineWidth:c.yaxis.borderWidth}),C(h,this._bottom,h,this._top,{lineCap:"round",strokeStyle:c.yaxis.borderColor,lineWidth:c.yaxis.borderWidth})):(C(this._left,this._top,this._right,this._top,{lineCap:"round",strokeStyle:c.x2axis.borderColor,lineWidth:c.x2axis.borderWidth}),C(this._right,this._top,this._right,this._bottom,{lineCap:"round",strokeStyle:c.y2axis.borderColor,lineWidth:c.y2axis.borderWidth}),C(this._right,this._bottom,this._left,this._bottom,{lineCap:"round",strokeStyle:c.xaxis.borderColor,lineWidth:c.xaxis.borderWidth}),C(this._left,this._bottom,this._left,this._top,{lineCap:"round",strokeStyle:c.yaxis.borderColor,lineWidth:c.yaxis.borderWidth}))),b.restore(),b=null,c=null}})(jQuery)