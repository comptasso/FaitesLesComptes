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
(function(a){a.jqplot.PointLabels=function(b){this.show=a.jqplot.config.enablePlugins,this.location="n",this.labelsFromSeries=!1,this.seriesLabelIndex=null,this.labels=[],this._labels=[],this.stackedValue=!1,this.ypadding=6,this.xpadding=6,this.escapeHTML=!0,this.edgeTolerance=-5,this.formatter=a.jqplot.DefaultTickFormatter,this.formatString="",this.hideZeros=!1,this._elems=[],a.extend(!0,this,b)};var b=["nw","n","ne","e","se","s","sw","w"],c={nw:0,n:1,ne:2,e:3,se:4,s:5,sw:6,w:7},d=["se","s","sw","w","nw","n","ne","e"];a.jqplot.PointLabels.init=function(b,c,d,e,f){var g=a.extend(!0,{},d,e);g.pointLabels=g.pointLabels||{},this.renderer.constructor===a.jqplot.BarRenderer&&this.barDirection==="horizontal"&&!g.pointLabels.location&&(g.pointLabels.location="e"),this.plugins.pointLabels=new a.jqplot.PointLabels(g.pointLabels),this.plugins.pointLabels.setLabels.call(this)},a.jqplot.PointLabels.prototype.setLabels=function(){var b=this.plugins.pointLabels,c;b.seriesLabelIndex!=null?c=b.seriesLabelIndex:this.renderer.constructor===a.jqplot.BarRenderer&&this.barDirection==="horizontal"?c=0:c=this._plotData.length===0?0:this._plotData[0].length-1,b._labels=[];if(b.labels.length===0||b.labelsFromSeries)if(b.stackedValue){if(this._plotData.length&&this._plotData[0].length)for(var d=0;d<this._plotData.length;d++)b._labels.push(this._plotData[d][c])}else{var e=this._plotData;this.renderer.constructor===a.jqplot.BarRenderer&&this.waterfall&&(e=this._data);if(e.length&&e[0].length)for(var d=0;d<e.length;d++)b._labels.push(e[d][c]);e=null}else b.labels.length&&(b._labels=b.labels)},a.jqplot.PointLabels.prototype.xOffset=function(a,b,c){b=b||this.location,c=c||this.xpadding;var d;switch(b){case"nw":d=-a.outerWidth(!0)-this.xpadding;break;case"n":d=-a.outerWidth(!0)/2;break;case"ne":d=this.xpadding;break;case"e":d=this.xpadding;break;case"se":d=this.xpadding;break;case"s":d=-a.outerWidth(!0)/2;break;case"sw":d=-a.outerWidth(!0)-this.xpadding;break;case"w":d=-a.outerWidth(!0)-this.xpadding;break;default:d=-a.outerWidth(!0)-this.xpadding}return d},a.jqplot.PointLabels.prototype.yOffset=function(a,b,c){b=b||this.location,c=c||this.xpadding;var d;switch(b){case"nw":d=-a.outerHeight(!0)-this.ypadding;break;case"n":d=-a.outerHeight(!0)-this.ypadding;break;case"ne":d=-a.outerHeight(!0)-this.ypadding;break;case"e":d=-a.outerHeight(!0)/2;break;case"se":d=this.ypadding;break;case"s":d=this.ypadding;break;case"sw":d=this.ypadding;break;case"w":d=-a.outerHeight(!0)/2;break;default:d=-a.outerHeight(!0)-this.ypadding}return d},a.jqplot.PointLabels.draw=function(b,e,f){var g=this.plugins.pointLabels;g.setLabels.call(this);for(var h=0;h<g._elems.length;h++)g._elems[h].emptyForce();g._elems.splice(0,g._elems.length);if(g.show){var i="_"+this._stackAxis+"axis";g.formatString||(g.formatString=this[i]._ticks[0].formatString,g.formatter=this[i]._ticks[0].formatter);var j=this._plotData,k=this._xaxis,l=this._yaxis,m,n;for(var h=0,o=g._labels.length;h<o;h++){var p=g._labels[h];g.hideZeros&&parseInt(g._labels[h],10)==0&&(p=""),p!=null&&(p=g.formatter(g.formatString,p)),n=document.createElement("div"),g._elems[h]=a(n),m=g._elems[h],m.addClass("jqplot-point-label jqplot-series-"+this.index+" jqplot-point-"+h),m.css("position","absolute"),m.insertAfter(b.canvas),g.escapeHTML?m.text(p):m.html(p);var q=g.location;if(this.fillToZero&&j[h][1]<0||this.fillToZero&&this._type==="bar"&&this.barDirection==="horizontal"&&j[h][0]<0||(this.waterfall&&parseInt(p,10))<0)q=d[c[q]];var r=k.u2p(j[h][0])+g.xOffset(m,q),s=l.u2p(j[h][1])+g.yOffset(m,q);this.renderer.constructor==a.jqplot.BarRenderer&&(this.barDirection=="vertical"?r+=this._barNudge:s-=this._barNudge),m.css("left",r),m.css("top",s);var t=r+m.width(),u=s+m.height(),v=g.edgeTolerance,w=a(b.canvas).position().left,x=a(b.canvas).position().top,y=b.canvas.width+w,z=b.canvas.height+x;(r-v<w||s-v<x||t+v>y||u+v>z)&&m.remove(),m=null,n=null}}},a.jqplot.postSeriesInitHooks.push(a.jqplot.PointLabels.init),a.jqplot.postDrawSeriesHooks.push(a.jqplot.PointLabels.draw)})(jQuery)