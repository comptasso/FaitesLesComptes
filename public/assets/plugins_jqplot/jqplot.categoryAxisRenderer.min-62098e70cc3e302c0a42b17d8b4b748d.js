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
(function(a){a.jqplot.CategoryAxisRenderer=function(b){a.jqplot.LinearAxisRenderer.call(this),this.sortMergedLabels=!1},a.jqplot.CategoryAxisRenderer.prototype=new a.jqplot.LinearAxisRenderer,a.jqplot.CategoryAxisRenderer.prototype.constructor=a.jqplot.CategoryAxisRenderer,a.jqplot.CategoryAxisRenderer.prototype.init=function(b){this.groups=1,this.groupLabels=[],this._groupLabels=[],this._grouped=!1,this._barsPerGroup=null,a.extend(!0,this,{tickOptions:{formatString:"%d"}},b);var c=this._dataBounds;for(var d=0;d<this._series.length;d++){var e=this._series[d];e.groups&&(this.groups=e.groups);var f=e.data;for(var g=0;g<f.length;g++)if(this.name=="xaxis"||this.name=="x2axis"){if(f[g][0]<c.min||c.min==null)c.min=f[g][0];if(f[g][0]>c.max||c.max==null)c.max=f[g][0]}else{if(f[g][1]<c.min||c.min==null)c.min=f[g][1];if(f[g][1]>c.max||c.max==null)c.max=f[g][1]}}this.groupLabels.length&&(this.groups=this.groupLabels.length)},a.jqplot.CategoryAxisRenderer.prototype.createTicks=function(){var b=this._ticks,c=this.ticks,d=this.name,e=this._dataBounds,f,g,h,i,j,k,l,m;if(c.length){if(this.groups>1&&!this._grouped){var n=c.length,o=parseInt(n/this.groups,10),p=0;for(var m=o;m<n;m+=o)c.splice(m+p,0," "),p++;this._grouped=!0}this.min=.5,this.max=c.length+.5;var q=this.max-this.min;this.numberTicks=2*c.length+1;for(m=0;m<c.length;m++){l=this.min+2*m*q/(this.numberTicks-1);var r=new this.tickRenderer(this.tickOptions);r.showLabel=!1,r.setTick(l,this.name),this._ticks.push(r);var r=new this.tickRenderer(this.tickOptions);r.label=c[m],r.showMark=!1,r.showGridline=!1,r.setTick(l+.5,this.name),this._ticks.push(r)}var r=new this.tickRenderer(this.tickOptions);r.showLabel=!1,r.setTick(l+1,this.name),this._ticks.push(r)}else{d=="xaxis"||d=="x2axis"?f=this._plotDimensions.width:f=this._plotDimensions.height,this.min!=null&&this.max!=null&&this.numberTicks!=null&&(this.tickInterval=null),this.min!=null&&this.max!=null&&this.tickInterval!=null&&parseInt((this.max-this.min)/this.tickInterval,10)!=(this.max-this.min)/this.tickInterval&&(this.tickInterval=null);var s=[],t=0,h=.5,i,u,v=!1;for(var m=0;m<this._series.length;m++){var w=this._series[m];for(var x=0;x<w.data.length;x++)this.name=="xaxis"||this.name=="x2axis"?u=w.data[x][0]:u=w.data[x][1],a.inArray(u,s)==-1&&(v=!0,t+=1,s.push(u))}v&&this.sortMergedLabels&&s.sort(function(a,b){return a-b}),this.ticks=s;for(var m=0;m<this._series.length;m++){var w=this._series[m];for(var x=0;x<w.data.length;x++){this.name=="xaxis"||this.name=="x2axis"?u=w.data[x][0]:u=w.data[x][1];var y=a.inArray(u,s)+1;this.name=="xaxis"||this.name=="x2axis"?w.data[x][0]=y:w.data[x][1]=y}}if(this.groups>1&&!this._grouped){var n=s.length,o=parseInt(n/this.groups,10),p=0;for(var m=o;m<n;m+=o+1)s[m]=" ";this._grouped=!0}i=t+.5,this.numberTicks==null&&(this.numberTicks=2*t+1);var q=i-h;this.min=h,this.max=i;var z=0,A=parseInt(3+f/10,10),o=parseInt(t/A,10);this.tickInterval==null&&(this.tickInterval=q/(this.numberTicks-1));for(var m=0;m<this.numberTicks;m++){l=this.min+m*this.tickInterval;var r=new this.tickRenderer(this.tickOptions);m/2==parseInt(m/2,10)?(r.showLabel=!1,r.showMark=!0):(o>0&&z<o?(r.showLabel=!1,z+=1):(r.showLabel=!0,z=0),r.label=r.formatter(r.formatString,s[(m-1)/2]),r.showMark=!1,r.showGridline=!1),r.setTick(l,this.name),this._ticks.push(r)}}},a.jqplot.CategoryAxisRenderer.prototype.draw=function(b,c){if(this.show){this.renderer.createTicks.call(this);var d=0,e;this._elem&&this._elem.emptyForce(),this._elem=this._elem||a('<div class="jqplot-axis jqplot-'+this.name+'" style="position:absolute;"></div>'),this.name=="xaxis"||this.name=="x2axis"?this._elem.width(this._plotDimensions.width):this._elem.height(this._plotDimensions.height),this.labelOptions.axis=this.name,this._label=new this.labelRenderer(this.labelOptions);if(this._label.show){var f=this._label.draw(b,c);f.appendTo(this._elem)}var g=this._ticks;for(var h=0;h<g.length;h++){var i=g[h];if(i.showLabel&&(!i.isMinorTick||this.showMinorTicks)){var f=i.draw(b,c);f.appendTo(this._elem)}}this._groupLabels=[];for(var h=0;h<this.groupLabels.length;h++){var f=a('<div style="position:absolute;" class="jqplot-'+this.name+'-groupLabel"></div>');f.html(this.groupLabels[h]),this._groupLabels.push(f),f.appendTo(this._elem)}}return this._elem},a.jqplot.CategoryAxisRenderer.prototype.set=function(){var b=0,c,d=0,e=0,f=this._label==null?!1:this._label.show;if(this.show){var g=this._ticks;for(var h=0;h<g.length;h++){var i=g[h];i.showLabel&&(!i.isMinorTick||this.showMinorTicks)&&(this.name=="xaxis"||this.name=="x2axis"?c=i._elem.outerHeight(!0):c=i._elem.outerWidth(!0),c>b&&(b=c))}var j=0;for(var h=0;h<this._groupLabels.length;h++){var k=this._groupLabels[h];this.name=="xaxis"||this.name=="x2axis"?c=k.outerHeight(!0):c=k.outerWidth(!0),c>j&&(j=c)}f&&(d=this._label._elem.outerWidth(!0),e=this._label._elem.outerHeight(!0)),this.name=="xaxis"?(b+=j+e,this._elem.css({height:b+"px",left:"0px",bottom:"0px"})):this.name=="x2axis"?(b+=j+e,this._elem.css({height:b+"px",left:"0px",top:"0px"})):this.name=="yaxis"?(b+=j+d,this._elem.css({width:b+"px",left:"0px",top:"0px"}),f&&this._label.constructor==a.jqplot.AxisLabelRenderer&&this._label._elem.css("width",d+"px")):(b+=j+d,this._elem.css({width:b+"px",right:"0px",top:"0px"}),f&&this._label.constructor==a.jqplot.AxisLabelRenderer&&this._label._elem.css("width",d+"px"))}},a.jqplot.CategoryAxisRenderer.prototype.pack=function(b,c){var d=this._ticks,e=this.max,f=this.min,g=c.max,h=c.min,i=this._label==null?!1:this._label.show,j;for(var k in b)this._elem.css(k,b[k]);this._offsets=c;var l=g-h,m=e-f;this.p2u=function(a){return(a-h)*m/l+f},this.u2p=function(a){return(a-f)*l/m+h},this.name=="xaxis"||this.name=="x2axis"?(this.series_u2p=function(a){return(a-f)*l/m},this.series_p2u=function(a){return a*m/l+f}):(this.series_u2p=function(a){return(a-e)*l/m},this.series_p2u=function(a){return a*m/l+e});if(this.show)if(this.name=="xaxis"||this.name=="x2axis"){for(j=0;j<d.length;j++){var n=d[j];if(n.show&&n.showLabel){var o;if(n.constructor==a.jqplot.CanvasAxisTickRenderer&&n.angle){var p=this.name=="xaxis"?1:-1;switch(n.labelPosition){case"auto":p*n.angle<0?o=-n.getWidth()+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2:o=-n._textRenderer.height*Math.sin(n._textRenderer.angle)/2;break;case"end":o=-n.getWidth()+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2;break;case"start":o=-n._textRenderer.height*Math.sin(n._textRenderer.angle)/2;break;case"middle":o=-n.getWidth()/2+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2;break;default:o=-n.getWidth()/2+n._textRenderer.height*Math.sin(-n._textRenderer.angle)/2}}else o=-n.getWidth()/2;var q=this.u2p(n.value)+o+"px";n._elem.css("left",q),n.pack()}}var r=["bottom",0];if(i){var s=this._label._elem.outerWidth(!0);this._label._elem.css("left",h+l/2-s/2+"px"),this.name=="xaxis"?(this._label._elem.css("bottom","0px"),r=["bottom",this._label._elem.outerHeight(!0)]):(this._label._elem.css("top","0px"),r=["top",this._label._elem.outerHeight(!0)]),this._label.pack()}var t=parseInt(this._ticks.length/this.groups,10);for(j=0;j<this._groupLabels.length;j++){var u=0,v=0;for(var w=j*t;w<=(j+1)*t;w++)if(this._ticks[w]._elem&&this._ticks[w].label!=" "){var n=this._ticks[w]._elem,k=n.position();u+=k.left+n.outerWidth(!0)/2,v++}u/=v,this._groupLabels[j].css({left:u-this._groupLabels[j].outerWidth(!0)/2}),this._groupLabels[j].css(r[0],r[1])}}else{for(j=0;j<d.length;j++){var n=d[j];if(n.show&&n.showLabel){var o;if(n.constructor==a.jqplot.CanvasAxisTickRenderer&&n.angle){var p=this.name=="yaxis"?1:-1;switch(n.labelPosition){case"auto":case"end":p*n.angle<0?o=-n._textRenderer.height*Math.cos(-n._textRenderer.angle)/2:o=-n.getHeight()+n._textRenderer.height*Math.cos(n._textRenderer.angle)/2;break;case"start":n.angle>0?o=-n._textRenderer.height*Math.cos(-n._textRenderer.angle)/2:o=-n.getHeight()+n._textRenderer.height*Math.cos(n._textRenderer.angle)/2;break;case"middle":o=-n.getHeight()/2;break;default:o=-n.getHeight()/2}}else o=-n.getHeight()/2;var q=this.u2p(n.value)+o+"px";n._elem.css("top",q),n.pack()}}var r=["left",0];if(i){var x=this._label._elem.outerHeight(!0);this._label._elem.css("top",g-l/2-x/2+"px"),this.name=="yaxis"?(this._label._elem.css("left","0px"),r=["left",this._label._elem.outerWidth(!0)]):(this._label._elem.css("right","0px"),r=["right",this._label._elem.outerWidth(!0)]),this._label.pack()}var t=parseInt(this._ticks.length/this.groups,10);for(j=0;j<this._groupLabels.length;j++){var u=0,v=0;for(var w=j*t;w<=(j+1)*t;w++)if(this._ticks[w]._elem&&this._ticks[w].label!=" "){var n=this._ticks[w]._elem,k=n.position();u+=k.top+n.outerHeight()/2,v++}u/=v,this._groupLabels[j].css({top:u-this._groupLabels[j].outerHeight()/2}),this._groupLabels[j].css(r[0],r[1])}}}})(jQuery)