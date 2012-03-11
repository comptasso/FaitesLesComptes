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
(function(a){function m(a,b,c){var d=Number.MAX_VALUE,e,f,g;for(var h=0,i=k.length;h<i;h++)e=Math.abs(c-k[h]),e<d&&(d=e,f=k[h],g=j[h]);return[f,g]}a.jqplot.DateAxisRenderer=function(){a.jqplot.LinearAxisRenderer.call(this),this.date=new a.jsDate};var b=1e3,c=60*b,d=60*c,e=24*d,f=7*e,g=30.4368499*e,h=365.242199*e,i=[31,28,31,30,31,30,31,30,31,30,31,30],j=["%M:%S.%#N","%M:%S.%#N","%M:%S.%#N","%M:%S","%M:%S","%M:%S","%M:%S","%H:%M:%S","%H:%M:%S","%H:%M","%H:%M","%H:%M","%H:%M","%H:%M","%H:%M","%a %H:%M","%a %H:%M","%b %e %H:%M","%b %e %H:%M","%b %e %H:%M","%b %e %H:%M","%v","%v","%v","%v","%v","%v","%v"],k=[.1*b,.2*b,.5*b,b,2*b,5*b,10*b,15*b,30*b,c,2*c,5*c,10*c,15*c,30*c,d,2*d,4*d,6*d,8*d,12*d,e,2*e,3*e,4*e,5*e,f,2*f],l=[];a.jqplot.DateAxisRenderer.prototype=new a.jqplot.LinearAxisRenderer,a.jqplot.DateAxisRenderer.prototype.constructor=a.jqplot.DateAxisRenderer,a.jqplot.DateTickFormatter=function(b,c){return b||(b="%Y/%m/%d"),a.jsDate.strftime(c,b)},a.jqplot.DateAxisRenderer.prototype.init=function(b){this.tickOptions.formatter=a.jqplot.DateTickFormatter,this.tickInset=0,this.drawBaseline=!0,this.baselineWidth=null,this.baselineColor=null,this.daTickInterval=null,this._daTickInterval=null,a.extend(!0,this,b);var c=this._dataBounds,d,e,f,g,h,i,j;for(var k=0;k<this._series.length;k++){d={intervals:[],frequencies:{},sortedIntervals:[],min:null,max:null,mean:null},e=0,f=this._series[k],g=f.data,h=f._plotData,i=f._stackData,j=0;for(var l=0;l<g.length;l++){if(this.name=="xaxis"||this.name=="x2axis"){g[l][0]=(new a.jsDate(g[l][0])).getTime(),h[l][0]=(new a.jsDate(g[l][0])).getTime(),i[l][0]=(new a.jsDate(g[l][0])).getTime();if(g[l][0]!=null&&g[l][0]<c.min||c.min==null)c.min=g[l][0];if(g[l][0]!=null&&g[l][0]>c.max||c.max==null)c.max=g[l][0];l>0&&(j=Math.abs(g[l][0]-g[l-1][0]),d.intervals.push(j),d.frequencies.hasOwnProperty(j)?d.frequencies[j]+=1:d.frequencies[j]=1),e+=j}else{g[l][1]=(new a.jsDate(g[l][1])).getTime(),h[l][1]=(new a.jsDate(g[l][1])).getTime(),i[l][1]=(new a.jsDate(g[l][1])).getTime();if(g[l][1]!=null&&g[l][1]<c.min||c.min==null)c.min=g[l][1];if(g[l][1]!=null&&g[l][1]>c.max||c.max==null)c.max=g[l][1];l>0&&(j=Math.abs(g[l][1]-g[l-1][1]),d.intervals.push(j),d.frequencies.hasOwnProperty(j)?d.frequencies[j]+=1:d.frequencies[j]=1)}e+=j}if(f.renderer.bands){if(f.renderer.bands.hiData.length){var m=f.renderer.bands.hiData;for(var l=0,n=m.length;l<n;l++)if(this.name==="xaxis"||this.name==="x2axis"){m[l][0]=(new a.jsDate(m[l][0])).getTime();if(m[l][0]!=null&&m[l][0]>c.max||c.max==null)c.max=m[l][0]}else{m[l][1]=(new a.jsDate(m[l][1])).getTime();if(m[l][1]!=null&&m[l][1]>c.max||c.max==null)c.max=m[l][1]}}if(f.renderer.bands.lowData.length){var m=f.renderer.bands.lowData;for(var l=0,n=m.length;l<n;l++)if(this.name==="xaxis"||this.name==="x2axis"){m[l][0]=(new a.jsDate(m[l][0])).getTime();if(m[l][0]!=null&&m[l][0]<c.min||c.min==null)c.min=m[l][0]}else{m[l][1]=(new a.jsDate(m[l][1])).getTime();if(m[l][1]!=null&&m[l][1]<c.min||c.min==null)c.min=m[l][1]}}}var o=0,p=0;for(var q in d.frequencies)d.sortedIntervals.push({interval:q,frequency:d.frequencies[q]});d.sortedIntervals.sort(function(a,b){return b.frequency-a.frequency}),d.min=a.jqplot.arrayMin(d.intervals),d.max=a.jqplot.arrayMax(d.intervals),d.mean=e/g.length,this._intervalStats.push(d),d=e=f=g=h=i=null}c=null},a.jqplot.DateAxisRenderer.prototype.reset=function(){this.min=this._options.min,this.max=this._options.max,this.tickInterval=this._options.tickInterval,this.numberTicks=this._options.numberTicks,this._autoFormatString="",this._overrideFormatString&&this.tickOptions&&this.tickOptions.formatString&&(this.tickOptions.formatString=""),this.daTickInterval=this._daTickInterval},a.jqplot.DateAxisRenderer.prototype.createTicks=function(b){var c=this._ticks,d=this.ticks,f=this.name,i=this._dataBounds,j=this._intervalStats,k=this.name.charAt(0)==="x"?this._plotDimensions.width:this._plotDimensions.height,l,n,o,p,q,r,s,t=30,u=1,v=this.tickInterval;n=this.min!=null?(new a.jsDate(this.min)).getTime():i.min,o=this.max!=null?(new a.jsDate(this.max)).getTime():i.max;var w=b.plugins.cursor;w&&w._zoom&&w._zoom.zooming&&(this.min=null,this.max=null);var x=o-n;if(this.tickOptions==null||!this.tickOptions.formatString)this._overrideFormatString=!0;if(d.length){for(s=0;s<d.length;s++){var y=d[s],z=new this.tickRenderer(this.tickOptions);y.constructor==Array?(z.value=(new a.jsDate(y[0])).getTime(),z.label=y[1],this.showTicks?this.showTickMarks||(z.showMark=!1):(z.showLabel=!1,z.showMark=!1),z.setTick(z.value,this.name),this._ticks.push(z)):(z.value=(new a.jsDate(y)).getTime(),this.showTicks?this.showTickMarks||(z.showMark=!1):(z.showLabel=!1,z.showMark=!1),z.setTick(z.value,this.name),this._ticks.push(z))}this.numberTicks=d.length,this.min=this._ticks[0].value,this.max=this._ticks[this.numberTicks-1].value,this.daTickInterval=[(this.max-this.min)/(this.numberTicks-1)/1e3,"seconds"]}else if(this.min==null&&this.max==null){var A=a.extend(!0,{},this.tickOptions,{name:this.name,value:null}),B,C;if(!this.tickInterval&&!this.numberTicks){var D=Math.max(k,t+1),E=115;this.tickRenderer===a.jqplot.CanvasAxisTickRenderer&&this.tickOptions.angle&&(E=115-40*Math.abs(Math.sin(this.tickOptions.angle/180*Math.PI))),B=Math.ceil((D-t)/E+1),C=(o-n)/(B-1)}else this.tickInterval?C=this.tickInterval:this.numberTicks&&(B=this.numberTicks,C=(o-n)/(B-1));if(C<=19*e){var F=m(n,o,C),G=F[0];this._autoFormatString=F[1],n=Math.floor(n/G)*G,n=new a.jsDate(n),n=n.getTime()+n.getUtcOffset(),B=Math.ceil((o-n)/G)+1,this.min=n,this.max=n+(B-1)*G,this.max<o&&(this.max+=G,B+=1),this.tickInterval=G,this.numberTicks=B;for(var s=0;s<B;s++)A.value=this.min+s*G,z=new this.tickRenderer(A),this._overrideFormatString&&this._autoFormatString!=""&&(z.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(z.showMark=!1):(z.showLabel=!1,z.showMark=!1),this._ticks.push(z);u=this.tickInterval}else if(C<=9*g){this._autoFormatString="%v";var H=Math.round(C/g);H<1?H=1:H>6&&(H=6);var I=(new a.jsDate(n)).setDate(1).setHours(0,0,0,0),J=new a.jsDate(o),K=(new a.jsDate(o)).setDate(1).setHours(0,0,0,0);J.getTime()!==K.getTime()&&(K=K.add(1,"month"));var L=K.diff(I,"month");B=Math.ceil(L/H)+1,this.min=I.getTime(),this.max=I.clone().add((B-1)*H,"month").getTime(),this.numberTicks=B;for(var s=0;s<B;s++)s===0?A.value=I.getTime():A.value=I.add(H,"month").getTime(),z=new this.tickRenderer(A),this._overrideFormatString&&this._autoFormatString!=""&&(z.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(z.showMark=!1):(z.showLabel=!1,z.showMark=!1),this._ticks.push(z);u=H*g}else{this._autoFormatString="%v";var H=Math.round(C/h);H<1&&(H=1);var I=(new a.jsDate(n)).setMonth(0,1).setHours(0,0,0,0),K=(new a.jsDate(o)).add(1,"year").setMonth(0,1).setHours(0,0,0,0),M=K.diff(I,"year");B=Math.ceil(M/H)+1,this.min=I.getTime(),this.max=I.clone().add((B-1)*H,"year").getTime(),this.numberTicks=B;for(var s=0;s<B;s++)s===0?A.value=I.getTime():A.value=I.add(H,"year").getTime(),z=new this.tickRenderer(A),this._overrideFormatString&&this._autoFormatString!=""&&(z.formatString=this._autoFormatString),this.showTicks?this.showTickMarks||(z.showMark=!1):(z.showLabel=!1,z.showMark=!1),this._ticks.push(z);u=H*h}}else{f=="xaxis"||f=="x2axis"?k=this._plotDimensions.width:k=this._plotDimensions.height,this.min!=null&&this.max!=null&&this.numberTicks!=null&&(this.tickInterval=null);if(this.tickInterval!=null)if(Number(this.tickInterval))this.daTickInterval=[Number(this.tickInterval),"seconds"];else if(typeof this.tickInterval=="string"){var N=this.tickInterval.split(" ");N.length==1?this.daTickInterval=[1,N[0]]:N.length==2&&(this.daTickInterval=[N[0],N[1]])}if(n==o){var O=432e5;n-=O,o+=O}x=o-n;var P=2+parseInt(Math.max(0,k-100)/100,10),Q,R;Q=this.min!=null?(new a.jsDate(this.min)).getTime():n-x/2*(this.padMin-1),R=this.max!=null?(new a.jsDate(this.max)).getTime():o+x/2*(this.padMax-1),this.min=Q,this.max=R,x=this.max-this.min;if(this.numberTicks==null)if(this.daTickInterval!=null){var S=(new a.jsDate(this.max)).diff(this.min,this.daTickInterval[1],!0);this.numberTicks=Math.ceil(S/this.daTickInterval[0])+1,this.max=(new a.jsDate(this.min)).add((this.numberTicks-1)*this.daTickInterval[0],this.daTickInterval[1]).getTime()}else k>200?this.numberTicks=parseInt(3+(k-200)/100,10):this.numberTicks=2;u=x/(this.numberTicks-1)/1e3,this.daTickInterval==null&&(this.daTickInterval=[u,"seconds"]);for(var s=0;s<this.numberTicks;s++){var n=new a.jsDate(this.min);r=n.add(s*this.daTickInterval[0],this.daTickInterval[1]).getTime();var z=new this.tickRenderer(this.tickOptions);this.showTicks?this.showTickMarks||(z.showMark=!1):(z.showLabel=!1,z.showMark=!1),z.setTick(r,this.name),this._ticks.push(z)}}this.tickInset&&(this.min=this.min-this.tickInset*u,this.max=this.max+this.tickInset*u),this._daTickInterval==null&&(this._daTickInterval=this.daTickInterval),c=null}})(jQuery)