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
(function(a){function b(b,c,d){d=d||{},d.axesDefaults=d.axesDefaults||{},d.grid=d.grid||{},d.legend=d.legend||{},d.seriesDefaults=d.seriesDefaults||{};var e=!1;if(d.seriesDefaults.renderer===a.jqplot.PyramidRenderer)e=!0;else if(d.series)for(var f=0;f<d.series.length;f++)d.series[f].renderer===a.jqplot.PyramidRenderer&&(e=!0);e&&(d.axesDefaults.renderer=a.jqplot.PyramidAxisRenderer,d.grid.renderer=a.jqplot.PyramidGridRenderer,d.seriesDefaults.pointLabels={show:!1})}function c(){this.plugins.pyramidRenderer&&this.plugins.pyramidRenderer.highlightCanvas&&(this.plugins.pyramidRenderer.highlightCanvas.resetCanvas(),this.plugins.pyramidRenderer.highlightCanvas=null),this.plugins.pyramidRenderer={highlightedSeriesIndex:null},this.plugins.pyramidRenderer.highlightCanvas=new a.jqplot.GenericCanvas,this.eventCanvas._elem.before(this.plugins.pyramidRenderer.highlightCanvas.createElement(this._gridPadding,"jqplot-pyramidRenderer-highlight-canvas",this._plotDimensions,this)),this.plugins.pyramidRenderer.highlightCanvas.setContext(),this.eventCanvas._elem.bind("mouseleave",{plot:this},function(a){e(a.data.plot)})}function d(a,b,c,d){var e=a.series[b],f=a.plugins.pyramidRenderer.highlightCanvas;f._ctx.clearRect(0,0,f._ctx.canvas.width,f._ctx.canvas.height),e._highlightedPoint=c,a.plugins.pyramidRenderer.highlightedSeriesIndex=b;var g={fillStyle:e.highlightColors[c],fillRect:!1};e.renderer.shapeRenderer.draw(f._ctx,d,g),f=null}function e(a){var b=a.plugins.pyramidRenderer.highlightCanvas;b._ctx.clearRect(0,0,b._ctx.canvas.width,b._ctx.canvas.height);for(var c=0;c<a.series.length;c++)a.series[c]._highlightedPoint=null;a.plugins.pyramidRenderer.highlightedSeriesIndex=null,a.target.trigger("jqplotDataUnhighlight"),b=null}function f(a,b,c,f,g){if(f){var h=[f.seriesIndex,f.pointIndex,f.data],i=jQuery.Event("jqplotDataMouseOver");i.pageX=a.pageX,i.pageY=a.pageY,g.target.trigger(i,h);if(g.series[h[0]].highlightMouseOver&&(h[0]!=g.plugins.pyramidRenderer.highlightedSeriesIndex||h[1]!=g.series[h[0]]._highlightedPoint)){var j=jQuery.Event("jqplotDataHighlight");j.pageX=a.pageX,j.pageY=a.pageY,g.target.trigger(j,h),d(g,f.seriesIndex,f.pointIndex,f.points)}}else f==null&&e(g)}a.jqplot.PyramidAxisRenderer===undefined&&a.ajax({url:a.jqplot.pluginLocation+"jqplot.pyramidAxisRenderer.js",dataType:"script",async:!1}),a.jqplot.PyramidGridRenderer===undefined&&a.ajax({url:a.jqplot.pluginLocation+"jqplot.pyramidGridRenderer.js",dataType:"script",async:!1}),a.jqplot.PyramidRenderer=function(){a.jqplot.LineRenderer.call(this)},a.jqplot.PyramidRenderer.prototype=new a.jqplot.LineRenderer,a.jqplot.PyramidRenderer.prototype.constructor=a.jqplot.PyramidRenderer,a.jqplot.PyramidRenderer.prototype.init=function(b,d){b=b||{},this._type="pyramid",this.barPadding=10,this.barWidth=null,this.fill=!0,this.highlightMouseOver=!0,this.highlightMouseDown=!1,this.highlightColors=[],this.offsetBars=!1,b.highlightMouseDown&&b.highlightMouseOver==null&&(b.highlightMouseOver=!1),this.side="right",a.extend(!0,this,b),this.renderer.options=b,this._highlightedPoint=null,this._dataColors=[],this._barPoints=[],this.fillAxis="y",this._primaryAxis="_yaxis",this._xnudge=0;var e={lineJoin:"miter",lineCap:"butt",fill:this.fill,fillRect:this.fill,isarc:!1,strokeStyle:this.color,fillStyle:this.color,closePath:this.fill,lineWidth:this.lineWidth};this.renderer.shapeRenderer.init(e);var g=b.shadowOffset;g==null&&(this.lineWidth>2.5?g=1.25*(1+(Math.atan(this.lineWidth/2.5)/.785398163-1)*.6):g=1.25*Math.atan(this.lineWidth/2.5)/.785398163);var h={lineJoin:"miter",lineCap:"butt",fill:this.fill,fillRect:this.fill,isarc:!1,angle:this.shadowAngle,offset:g,alpha:this.shadowAlpha,depth:this.shadowDepth,closePath:this.fill,lineWidth:this.lineWidth};this.renderer.shadowRenderer.init(h),d.postDrawHooks.addOnce(c),d.eventListenerHooks.addOnce("jqplotMouseMove",f);if(this.side==="left")for(var i=0,j=this.data.length;i<j;i++)this.data[i][1]=-Math.abs(this.data[i][1])},a.jqplot.PyramidRenderer.prototype.setGridData=function(a){var b=this._xaxis.series_u2p,c=this._yaxis.series_u2p,d=this._plotData,e=this._prevPlotData;this.gridData=[],this._prevGridData=[];var f=d.length,g=!1,h;for(h=0;h<f;h++)d[h][1]<0&&(this.side="left");this._yaxis.name==="yMidAxis"&&this.side==="right"&&(this._xnudge=this._xaxis.max/2e3,g=!0);for(h=0;h<f;h++)d[h][0]!=null&&d[h][1]!=null?this.gridData.push([b(d[h][1]),c(d[h][0])]):d[h][0]==null?this.gridData.push([b(d[h][1]),null]):d[h][1]==null&&this.gridData.push(null,[c(d[h][0])]),d[h][1]===0&&g&&(this.gridData[h][0]=b(this._xnudge))},a.jqplot.PyramidRenderer.prototype.makeGridData=function(a,b){var c=this._xaxis.series_u2p,d=this._yaxis.series_u2p,e=[],f=a.length,g=!1,h;for(h=0;h<f;h++)a[h][1]<0&&(this.side="left");this._yaxis.name==="yMidAxis"&&this.side==="right"&&(this._xnudge=this._xaxis.max/2e3,g=!0);for(h=0;h<f;h++)a[h][0]!=null&&a[h][1]!=null?e.push([c(a[h][1]),d(a[h][0])]):a[h][0]==null?e.push([c(a[h][1]),null]):a[h][1]==null&&e.push([null,d(a[h][0])]),a[h][1]===0&&g&&(e[h][0]=c(this._xnudge));return e},a.jqplot.PyramidRenderer.prototype.setBarWidth=function(){var a,b=0,c=0,d=this[this._primaryAxis],e,f,g;b=d.max-d.min;var h=d.numberTicks,i=(h-1)/2,j=this.barPadding===0?1:0;d.name=="xaxis"||d.name=="x2axis"?this.barWidth=(d._offsets.max-d._offsets.min)/b-this.barPadding+j:this.fill?this.barWidth=(d._offsets.min-d._offsets.max)/b-this.barPadding+j:this.barWidth=(d._offsets.min-d._offsets.max)/b},a.jqplot.PyramidRenderer.prototype.draw=function(b,c,d){var e,f=a.extend({},d),g=f.shadow!=undefined?f.shadow:this.shadow,h=f.showLine!=undefined?f.showLine:this.showLine,i=f.fill!=undefined?f.fill:this.fill,j=this._xaxis.series_u2p,k=this._yaxis.series_u2p,l,m;this._dataColors=[],this._barPoints=[],this.renderer.options.barWidth==null&&this.renderer.setBarWidth.call(this);var n=[],o,p;if(h){var q=new a.jqplot.ColorGenerator(this.negativeSeriesColors),r=new a.jqplot.ColorGenerator(this.seriesColors),s=q.get(this.index);this.useNegativeColors||(s=f.fillStyle);var t=f.fillStyle,u,v=this._xaxis.series_u2p(this._xnudge),w=this._yaxis.series_u2p(this._yaxis.min),x=this._yaxis.series_u2p(this._yaxis.max),y=this.barWidth,z=y/2,n=[],A=this.offsetBars?z:0;for(var e=0,B=c.length;e<B;e++){if(this.data[e][0]==null)continue;u=c[e][1],this._plotData[e][1]<0?this.varyBarColor&&!this._stack&&(this.useNegativeColors?f.fillStyle=q.next():f.fillStyle=r.next()):this.varyBarColor&&!this._stack?f.fillStyle=r.next():f.fillStyle=t;if(this.fill){this._plotData[e][1]>=0?(o=c[e][0]-v,p=this.barWidth,n=[v,u-z-A,o,p]):(o=v-c[e][0],p=this.barWidth,n=[c[e][0],u-z-A,o,p]),this._barPoints.push([[n[0],n[1]+p],[n[0],n[1]],[n[0]+o,n[1]],[n[0]+o,n[1]+p]]),g&&this.renderer.shadowRenderer.draw(b,n);var C=f.fillStyle||this.color;this._dataColors.push(C),this.renderer.shapeRenderer.draw(b,n,f)}else if(e===0)n=[[v,w],[c[e][0],w],[c[e][0],c[e][1]-z-A]];else if(e<B-1)n=n.concat([[c[e-1][0],c[e-1][1]-z-A],[c[e][0],c[e][1]+z-A],[c[e][0],c[e][1]-z-A]]);else{n=n.concat([[c[e-1][0],c[e-1][1]-z-A],[c[e][0],c[e][1]+z-A],[c[e][0],x],[v,x]]),g&&this.renderer.shadowRenderer.draw(b,n);var C=f.fillStyle||this.color;this._dataColors.push(C),this.renderer.shapeRenderer.draw(b,n,f)}}}if(this.highlightColors.length==0)this.highlightColors=a.jqplot.computeHighlightColors(this._dataColors);else if(typeof this.highlightColors=="string"){this.highlightColors=[];for(var e=0;e<this._dataColors.length;e++)this.highlightColors.push(this.highlightColors)}},a.jqplot.preInitHooks.push(b)})(jQuery)