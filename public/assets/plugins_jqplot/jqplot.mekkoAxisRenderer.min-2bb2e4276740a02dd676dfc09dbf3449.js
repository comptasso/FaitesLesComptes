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
(function(a){a.jqplot.MekkoAxisRenderer=function(){},a.jqplot.MekkoAxisRenderer.prototype.init=function(b){this.tickMode,this.barLabelRenderer=a.jqplot.AxisLabelRenderer,this.barLabels=this.barLabels||[],this.barLabelOptions={},this.tickOptions=a.extend(!0,{showGridline:!1},this.tickOptions),this._barLabels=[],a.extend(!0,this,b),this.name=="yaxis"&&(this.tickOptions.formatString=this.tickOptions.formatString||"%d%");var c=this._dataBounds;c.min=0;if(this.name=="yaxis"||this.name=="y2axis")c.max=100,this.tickMode="even";else if(this.name=="xaxis"){this.tickMode=this.tickMode==null?"bar":this.tickMode;for(var d=0;d<this._series.length;d++)c.max+=this._series[d]._sumy}else if(this.name=="x2axis"){this.tickMode=this.tickMode==null?"even":this.tickMode;for(var d=0;d<this._series.length;d++)c.max+=this._series[d]._sumy}},a.jqplot.MekkoAxisRenderer.prototype.draw=function(b,c){if(this.show){this.renderer.createTicks.call(this);var d=0,e,f=document.createElement("div");this._elem=a(f),this._elem.addClass("jqplot-axis jqplot-"+this.name),this._elem.css("position","absolute"),f=null,this.name=="xaxis"||this.name=="x2axis"?this._elem.width(this._plotDimensions.width):this._elem.height(this._plotDimensions.height),this.labelOptions.axis=this.name,this._label=new this.labelRenderer(this.labelOptions),this._label.show&&this._elem.append(this._label.draw(b));var g,h,f;if(this.showTicks){g=this._ticks;for(var i=0;i<g.length;i++)h=g[i],h.showLabel&&(!h.isMinorTick||this.showMinorTicks)&&this._elem.append(h.draw(b))}for(i=0;i<this.barLabels.length;i++){this.barLabelOptions.axis=this.name,this.barLabelOptions.label=this.barLabels[i],this._barLabels.push(new this.barLabelRenderer(this.barLabelOptions)),this.tickMode!="bar"&&(this._barLabels[i].show=!1);if(this._barLabels[i].show){var f=this._barLabels[i].draw(b,c);f.removeClass("jqplot-"+this.name+"-label"),f.addClass("jqplot-"+this.name+"-tick"),f.addClass("jqplot-mekko-barLabel"),f.appendTo(this._elem),f=null}}}return this._elem},a.jqplot.MekkoAxisRenderer.prototype.reset=function(){this.min=this._min,this.max=this._max,this.tickInterval=this._tickInterval,this.numberTicks=this._numberTicks},a.jqplot.MekkoAxisRenderer.prototype.set=function(){var b=0,c,d=0,e=0,f=this._label==null?!1:this._label.show;if(this.show&&this.showTicks){var g=this._ticks;for(var h=0;h<g.length;h++){var i=g[h];i.showLabel&&(!i.isMinorTick||this.showMinorTicks)&&(this.name=="xaxis"||this.name=="x2axis"?c=i._elem.outerHeight(!0):c=i._elem.outerWidth(!0),c>b&&(b=c))}f&&(d=this._label._elem.outerWidth(!0),e=this._label._elem.outerHeight(!0)),this.name=="xaxis"?(b+=e,this._elem.css({height:b+"px",left:"0px",bottom:"0px"})):this.name=="x2axis"?(b+=e,this._elem.css({height:b+"px",left:"0px",top:"0px"})):this.name=="yaxis"?(b+=d,this._elem.css({width:b+"px",left:"0px",top:"0px"}),f&&this._label.constructor==a.jqplot.AxisLabelRenderer&&this._label._elem.css("width",d+"px")):(b+=d,this._elem.css({width:b+"px",right:"0px",top:"0px"}),f&&this._label.constructor==a.jqplot.AxisLabelRenderer&&this._label._elem.css("width",d+"px"))}},a.jqplot.MekkoAxisRenderer.prototype.createTicks=function(){var a=this._ticks,b=this.ticks,c=this.name,d=this._dataBounds,e,f,g,h,i,j,k,l,m,n;if(b.length){for(m=0;m<b.length;m++){var o=b[m],k=new this.tickRenderer(this.tickOptions);o.constructor==Array?(k.value=o[0],k.label=o[1],this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(o[0],this.name),this._ticks.push(k)):(k.value=o,this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(o,this.name),this._ticks.push(k))}this.numberTicks=b.length,this.min=this._ticks[0].value,this.max=this._ticks[this.numberTicks-1].value,this.tickInterval=(this.max-this.min)/(this.numberTicks-1)}else{c=="xaxis"||c=="x2axis"?e=this._plotDimensions.width:e=this._plotDimensions.height,this.min!=null&&this.max!=null&&this.numberTicks!=null&&(this.tickInterval=null),g=this.min!=null?this.min:d.min,h=this.max!=null?this.max:d.max;if(g==h){var p=.05;g>0&&(p=Math.max(Math.log(g)/Math.LN10,.05)),g-=p,h+=p}var q=h-g,r,s,t,u,v,w=[3,5,6,11,21];if(this.name=="yaxis"||this.name=="y2axis"){this.min=0,this.max=100;if(!this.numberTicks)if(this.tickInterval)this.numberTicks=3+Math.ceil(q/this.tickInterval);else{t=2+Math.ceil((e-(this.tickSpacing-1))/this.tickSpacing);for(m=0;m<w.length;m++){v=t/w[m];if(v==1){this.numberTicks=w[m];break}if(v>1){u=v;continue}if(v<1){if(Math.abs(u-1)<Math.abs(v-1)){this.numberTicks=w[m-1];break}this.numberTicks=w[m];break}m==w.length-1&&(this.numberTicks=w[m])}this.tickInterval=q/(this.numberTicks-1)}else this.tickInterval=q/(this.numberTicks-1);for(var m=0;m<this.numberTicks;m++)l=this.min+m*this.tickInterval,k=new this.tickRenderer(this.tickOptions),this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(l,this.name),this._ticks.push(k)}else if(this.tickMode=="bar"){this.min=0,this.numberTicks=this._series.length+1,k=new this.tickRenderer(this.tickOptions),this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(0,this.name),this._ticks.push(k),t=0;for(m=1;m<this.numberTicks;m++)t+=this._series[m-1]._sumy,k=new this.tickRenderer(this.tickOptions),this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(t,this.name),this._ticks.push(k);this.max=this.max||t,this.max>t&&(k=new this.tickRenderer(this.tickOptions),this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(this.max,this.name),this._ticks.push(k))}else if(this.tickMode=="even"){this.min=0,this.max=this.max||d.max;var x=2+Math.ceil((e-(this.tickSpacing-1))/this.tickSpacing);q=this.max-this.min,this.numberTicks=x,this.tickInterval=q/(this.numberTicks-1);for(m=0;m<this.numberTicks;m++)l=this.min+m*this.tickInterval,k=new this.tickRenderer(this.tickOptions),this.showTicks?this.showTickMarks||(k.showMark=!1):(k.showLabel=!1,k.showMark=!1),k.setTick(l,this.name),this._ticks.push(k)}}},a.jqplot.MekkoAxisRenderer.prototype.pack=function(b,c){var d=this._ticks,e=this.max,f=this.min,g=c.max,h=c.min,i=this._label==null?!1:this._label.show;for(var j in b)this._elem.css(j,b[j]);this._offsets=c;var k=g-h,l=e-f;this.p2u=function(a){return(a-h)*l/k+f},this.u2p=function(a){return(a-f)*k/l+h},this.name=="xaxis"||this.name=="x2axis"?(this.series_u2p=function(a){return(a-f)*k/l},this.series_p2u=function(a){return a*l/k+f}):(this.series_u2p=function(a){return(a-e)*k/l},this.series_p2u=function(a){return a*l/k+e});if(this.show)if(this.name=="xaxis"||this.name=="x2axis"){for(var m=0;m<d.length;m++){var n=d[m];if(n.show&&n.showLabel){var o;if(n.constructor==a.jqplot.CanvasAxisTickRenderer&&n.angle){var p=this.name=="xaxis"?1:-1;switch(n.labelPosition){case"auto":p*n.angle<0?o=-n.getWidth()+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2:o=-n._textRenderer.height*Math.sin(n._textRenderer.angle)/2;break;case"end":o=-n.getWidth()+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2;break;case"start":o=-n._textRenderer.height*Math.sin(n._textRenderer.angle)/2;break;case"middle":o=-n.getWidth()/2+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2;break;default:o=-n.getWidth()/2+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2}}else o=-n.getWidth()/2;var q=this.u2p(n.value)+o+"px";n._elem.css("left",q),n.pack()}}var r;i&&(r=this._label._elem.outerWidth(!0),this._label._elem.css("left",h+k/2-r/2+"px"),this.name=="xaxis"?this._label._elem.css("bottom","0px"):this._label._elem.css("top","0px"),this._label.pack());var s,t,u;for(var m=0;m<this.barLabels.length;m++)s=this._barLabels[m],s.show&&(r=s.getWidth(),t=this._ticks[m].getLeft()+this._ticks[m].getWidth(),u=this._ticks[m+1].getLeft(),s._elem.css("left",(u+t-r)/2+"px"),s._elem.css("top",this._ticks[m]._elem.css("top")),s.pack())}else{for(var m=0;m<d.length;m++){var n=d[m];if(n.show&&n.showLabel){var o;if(n.constructor==a.jqplot.CanvasAxisTickRenderer&&n.angle){var p=this.name=="yaxis"?1:-1;switch(n.labelPosition){case"auto":case"end":p*n.angle<0?o=-n._textRenderer.height*Math.cos(-n._textRenderer.angle)/2:o=-n.getHeight()+n._textRenderer.height*Math.cos(n._textRenderer.angle)/2;break;case"start":n.angle>0?o=-n._textRenderer.height*Math.cos(-n._textRenderer.angle)/2:o=-n.getHeight()+n._textRenderer.height*Math.cos(n._textRenderer.angle)/2;break;case"middle":o=-n.getHeight()/2;break;default:o=-n.getHeight()/2}}else o=-n.getHeight()/2;var q=this.u2p(n.value)+o+"px";n._elem.css("top",q),n.pack()}}if(i){var v=this._label._elem.outerHeight(!0);this._label._elem.css("top",g-k/2-v/2+"px"),this.name=="yaxis"?this._label._elem.css("left","0px"):this._label._elem.css("right","0px"),this._label.pack()}}}})(jQuery)