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
(function(a){function b(b,c,d){d=d||{},d.axesDefaults=d.axesDefaults||{},d.legend=d.legend||{},d.seriesDefaults=d.seriesDefaults||{};var e=!1;if(d.seriesDefaults.renderer==a.jqplot.MekkoRenderer)e=!0;else if(d.series)for(var f=0;f<d.series.length;f++)d.series[f].renderer==a.jqplot.MekkoRenderer&&(e=!0);e&&(d.axesDefaults.renderer=a.jqplot.MekkoAxisRenderer,d.legend.renderer=a.jqplot.MekkoLegendRenderer,d.legend.preDraw=!0)}a.jqplot.MekkoRenderer=function(){this.shapeRenderer=new a.jqplot.ShapeRenderer,this.borderColor=null,this.showBorders=!0},a.jqplot.MekkoRenderer.prototype.init=function(b,c){this.fill=!1,this.fillRect=!0,this.strokeRect=!0,this.shadow=!1,this._xwidth=0,this._xstart=0,a.extend(!0,this.renderer,b);var d={lineJoin:"miter",lineCap:"butt",isarc:!1,fillRect:this.fillRect,strokeRect:this.strokeRect};this.renderer.shapeRenderer.init(d),c.axes.x2axis._series.push(this),this._type="mekko"},a.jqplot.MekkoRenderer.prototype.setGridData=function(a){var b=this._xaxis.series_u2p,c=this._yaxis.series_u2p,d=this._plotData;this.gridData=[],this._xwidth=b(this._sumy)-b(0),this.index>0&&(this._xstart=a.series[this.index-1]._xstart+a.series[this.index-1]._xwidth);var e=this.canvas.getHeight(),f=0,g,h;for(var i=0;i<d.length;i++)d[i]!=null&&(f+=d[i][1],g=e-f/this._sumy*e,h=d[i][1]/this._sumy*e,this.gridData.push([this._xstart,g,this._xwidth,h]))},a.jqplot.MekkoRenderer.prototype.makeGridData=function(a,b){var c=this._xaxis.series_u2p,d=this.canvas.getHeight(),e=0,f,g,h=[];for(var i=0;i<a.length;i++)a[i]!=null&&(e+=a[i][1],f=d-e/this._sumy*d,g=a[i][1]/this._sumy*d,h.push([this._xstart,f,this._xwidth,g]));return h},a.jqplot.MekkoRenderer.prototype.draw=function(b,c,d){var e,f=d!=undefined?d:{},g=f.showLine!=undefined?f.showLine:this.showLine,h=new a.jqplot.ColorGenerator(this.seriesColors);b.save();if(c.length&&g)for(e=0;e<c.length;e++)f.fillStyle=h.next(),this.renderer.showBorders?f.strokeStyle=this.renderer.borderColor:f.strokeStyle=f.fillStyle,this.renderer.shapeRenderer.draw(b,c[e],f);b.restore()},a.jqplot.MekkoRenderer.prototype.drawShadow=function(a,b,c){},a.jqplot.MekkoLegendRenderer=function(){},a.jqplot.MekkoLegendRenderer.prototype.init=function(b){this.numberRows=null,this.numberColumns=null,this.placement="outside",a.extend(!0,this,b)},a.jqplot.MekkoLegendRenderer.prototype.draw=function(){var b=this;if(this.show){var c=this._series,d="position:absolute;";d+=this.background?"background:"+this.background+";":"",d+=this.border?"border:"+this.border+";":"",d+=this.fontSize?"font-size:"+this.fontSize+";":"",d+=this.fontFamily?"font-family:"+this.fontFamily+";":"",d+=this.textColor?"color:"+this.textColor+";":"",this._elem=a('<table class="jqplot-table-legend" style="'+d+'"></table>');var e=!1,f=!0,g,h,i=c[0],j=new a.jqplot.ColorGenerator(i.seriesColors);if(i.show){var k=i.data;this.numberRows?(g=this.numberRows,this.numberColumns?h=this.numberColumns:h=Math.ceil(k.length/g)):this.numberColumns?(h=this.numberColumns,g=Math.ceil(k.length/this.numberColumns)):(g=k.length,h=1);var l,m,n,o,p,q,r,s,t=0;for(l=0;l<g;l++){f?n=a('<tr class="jqplot-table-legend"></tr>').prependTo(this._elem):n=a('<tr class="jqplot-table-legend"></tr>').appendTo(this._elem);for(m=0;m<h;m++)t<k.length&&(q=this.labels[t]||k[t][0].toString(),s=j.next(),f?l==g-1?e=!1:e=!0:l>0?e=!0:e=!1,r=e?this.rowSpacing:"0",o=a('<td class="jqplot-table-legend" style="text-align:center;padding-top:'+r+';"><div><div class="jqplot-table-legend-swatch" style="border-color:'+s+';"></div></div></td>'),p=a('<td class="jqplot-table-legend" style="padding-top:'+r+';"></td>'),this.escapeHtml?p.text(q):p.html(q),f?(p.prependTo(n),o.prependTo(n)):(o.appendTo(n),p.appendTo(n)),e=!0),t++}n=null,o=null,p=null}}return this._elem},a.jqplot.MekkoLegendRenderer.prototype.pack=function(a){if(this.show){var b={_top:a.top,_left:a.left,_right:a.right,_bottom:this._plotDimensions.height-a.bottom};if(this.placement=="insideGrid")switch(this.location){case"nw":var c=b._left+this.xoffset,d=b._top+this.yoffset;this._elem.css("left",c),this._elem.css("top",d);break;case"n":var c=(a.left+(this._plotDimensions.width-a.right))/2-this.getWidth()/2,d=b._top+this.yoffset;this._elem.css("left",c),this._elem.css("top",d);break;case"ne":var c=a.right+this.xoffset,d=b._top+this.yoffset;this._elem.css({right:c,top:d});break;case"e":var c=a.right+this.xoffset,d=(a.top+(this._plotDimensions.height-a.bottom))/2-this.getHeight()/2;this._elem.css({right:c,top:d});break;case"se":var c=a.right+this.xoffset,d=a.bottom+this.yoffset;this._elem.css({right:c,bottom:d});break;case"s":var c=(a.left+(this._plotDimensions.width-a.right))/2-this.getWidth()/2,d=a.bottom+this.yoffset;this._elem.css({left:c,bottom:d});break;case"sw":var c=b._left+this.xoffset,d=a.bottom+this.yoffset;this._elem.css({left:c,bottom:d});break;case"w":var c=b._left+this.xoffset,d=(a.top+(this._plotDimensions.height-a.bottom))/2-this.getHeight()/2;this._elem.css({left:c,top:d});break;default:var c=b._right-this.xoffset,d=b._bottom+this.yoffset;this._elem.css({right:c,bottom:d})}else switch(this.location){case"nw":var c=this._plotDimensions.width-b._left+this.xoffset,d=b._top+this.yoffset;this._elem.css("right",c),this._elem.css("top",d);break;case"n":var c=(a.left+(this._plotDimensions.width-a.right))/2-this.getWidth()/2,d=this._plotDimensions.height-b._top+this.yoffset;this._elem.css("left",c),this._elem.css("bottom",d);break;case"ne":var c=this._plotDimensions.width-a.right+this.xoffset,d=b._top+this.yoffset;this._elem.css({left:c,top:d});break;case"e":var c=this._plotDimensions.width-a.right+this.xoffset,d=(a.top+(this._plotDimensions.height-a.bottom))/2-this.getHeight()/2;this._elem.css({left:c,top:d});break;case"se":var c=this._plotDimensions.width-a.right+this.xoffset,d=a.bottom+this.yoffset;this._elem.css({left:c,bottom:d});break;case"s":var c=(a.left+(this._plotDimensions.width-a.right))/2-this.getWidth()/2,d=this._plotDimensions.height-a.bottom+this.yoffset;this._elem.css({left:c,top:d});break;case"sw":var c=this._plotDimensions.width-b._left+this.xoffset,d=a.bottom+this.yoffset;this._elem.css({right:c,bottom:d});break;case"w":var c=this._plotDimensions.width-b._left+this.xoffset,d=(a.top+(this._plotDimensions.height-a.bottom))/2-this.getHeight()/2;this._elem.css({right:c,top:d});break;default:var c=b._right-this.xoffset,d=b._bottom+this.yoffset;this._elem.css({right:c,bottom:d})}}},a.jqplot.preInitHooks.push(b)})(jQuery)