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
(function(a){a.jqplot.EnhancedLegendRenderer=function(){a.jqplot.TableLegendRenderer.call(this)},a.jqplot.EnhancedLegendRenderer.prototype=new a.jqplot.TableLegendRenderer,a.jqplot.EnhancedLegendRenderer.prototype.constructor=a.jqplot.EnhancedLegendRenderer,a.jqplot.EnhancedLegendRenderer.prototype.init=function(b){this.numberRows=null,this.numberColumns=null,this.seriesToggle="normal",this.disableIEFading=!0,a.extend(!0,this,b),this.seriesToggle&&a.jqplot.postDrawHooks.push(c)},a.jqplot.EnhancedLegendRenderer.prototype.draw=function(){var c=this;if(this.show){var d=this._series,e,f="position:absolute;";f+=this.background?"background:"+this.background+";":"",f+=this.border?"border:"+this.border+";":"",f+=this.fontSize?"font-size:"+this.fontSize+";":"",f+=this.fontFamily?"font-family:"+this.fontFamily+";":"",f+=this.textColor?"color:"+this.textColor+";":"",f+=this.marginTop!=null?"margin-top:"+this.marginTop+";":"",f+=this.marginBottom!=null?"margin-bottom:"+this.marginBottom+";":"",f+=this.marginLeft!=null?"margin-left:"+this.marginLeft+";":"",f+=this.marginRight!=null?"margin-right:"+this.marginRight+";":"",this._elem=a('<table class="jqplot-table-legend" style="'+f+'"></table>'),this.seriesToggle&&this._elem.css("z-index","3");var g=!1,h=!1,i,j;this.numberRows?(i=this.numberRows,this.numberColumns?j=this.numberColumns:j=Math.ceil(d.length/i)):this.numberColumns?(j=this.numberColumns,i=Math.ceil(d.length/this.numberColumns)):(i=d.length,j=1);var k,l,m,n,o,p,q,r,s,t,u=0;for(k=d.length-1;k>=0;k--)if(j==1&&d[k]._stack||d[k].renderer.constructor==a.jqplot.BezierCurveRenderer)h=!0;for(k=0;k<i;k++){m=a(document.createElement("tr")),m.addClass("jqplot-table-legend"),h?m.prependTo(this._elem):m.appendTo(this._elem);for(l=0;l<j;l++){if(u<d.length&&d[u].show&&d[u].showLabel){e=d[u],p=this.labels[u]||e.label.toString();if(p){var v=e.color;h?k==i-1?g=!1:g=!0:k>0?g=!0:g=!1,q=g?this.rowSpacing:"0",n=a(document.createElement("td")),n.addClass("jqplot-table-legend jqplot-table-legend-swatch"),n.css({textAlign:"center",paddingTop:q}),s=a(document.createElement("div")),s.addClass("jqplot-table-legend-swatch-outline"),t=a(document.createElement("div")),t.addClass("jqplot-table-legend-swatch"),t.css({backgroundColor:v,borderColor:v}),n.append(s.append(t)),o=a(document.createElement("td")),o.addClass("jqplot-table-legend jqplot-table-legend-label"),o.css("paddingTop",q),this.escapeHtml?o.text(p):o.html(p),h?(this.showLabels&&o.prependTo(m),this.showSwatches&&n.prependTo(m)):(this.showSwatches&&n.appendTo(m),this.showLabels&&o.appendTo(m));if(this.seriesToggle){var w;if(typeof this.seriesToggle=="string"||typeof this.seriesToggle=="number")if(!a.jqplot.use_excanvas||!this.disableIEFading)w=this.seriesToggle;this.showSwatches&&(n.bind("click",{series:e,speed:w},b),n.addClass("jqplot-seriesToggle")),this.showLabels&&(o.bind("click",{series:e,speed:w},b),o.addClass("jqplot-seriesToggle"))}g=!0}}u++}n=o=s=t=null}}return this._elem};var b=function(b){b.data.series.toggleDisplay(b),b.data.series.canvas._elem.hasClass("jqplot-series-hidden")?(a(this).addClass("jqplot-series-hidden"),a(this).next(".jqplot-table-legend-label").addClass("jqplot-series-hidden"),a(this).prev(".jqplot-table-legend-swatch").addClass("jqplot-series-hidden")):(a(this).removeClass("jqplot-series-hidden"),a(this).next(".jqplot-table-legend-label").removeClass("jqplot-series-hidden"),a(this).prev(".jqplot-table-legend-swatch").removeClass("jqplot-series-hidden"))},c=function(){if(this.legend.renderer.constructor==a.jqplot.EnhancedLegendRenderer&&this.legend.seriesToggle){var b=this.legend._elem.detach();this.eventCanvas._elem.after(b)}}})(jQuery)