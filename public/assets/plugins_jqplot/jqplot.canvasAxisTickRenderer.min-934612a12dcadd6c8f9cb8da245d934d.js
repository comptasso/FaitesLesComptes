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
(function(a){a.jqplot.CanvasAxisTickRenderer=function(b){this.mark="outside",this.showMark=!0,this.showGridline=!0,this.isMinorTick=!1,this.angle=0,this.markSize=4,this.show=!0,this.showLabel=!0,this.labelPosition="auto",this.label="",this.value=null,this._styles={},this.formatter=a.jqplot.DefaultTickFormatter,this.formatString="",this.prefix="",this.fontFamily='"Trebuchet MS", Arial, Helvetica, sans-serif',this.fontSize="10pt",this.fontWeight="normal",this.fontStretch=1,this.textColor="#666666",this.enableFontSupport=!0,this.pt2px=null,this._elem,this._ctx,this._plotWidth,this._plotHeight,this._plotDimensions={height:null,width:null},a.extend(!0,this,b);var c={fontSize:this.fontSize,fontWeight:this.fontWeight,fontStretch:this.fontStretch,fillStyle:this.textColor,angle:this.getAngleRad(),fontFamily:this.fontFamily};this.pt2px&&(c.pt2px=this.pt2px),this.enableFontSupport?a.jqplot.support_canvas_text()?this._textRenderer=new a.jqplot.CanvasFontRenderer(c):this._textRenderer=new a.jqplot.CanvasTextRenderer(c):this._textRenderer=new a.jqplot.CanvasTextRenderer(c)},a.jqplot.CanvasAxisTickRenderer.prototype.init=function(b){a.extend(!0,this,b),this._textRenderer.init({fontSize:this.fontSize,fontWeight:this.fontWeight,fontStretch:this.fontStretch,fillStyle:this.textColor,angle:this.getAngleRad(),fontFamily:this.fontFamily})},a.jqplot.CanvasAxisTickRenderer.prototype.getWidth=function(a){if(this._elem)return this._elem.outerWidth(!0);var b=this._textRenderer,c=b.getWidth(a),d=b.getHeight(a),e=Math.abs(Math.sin(b.angle)*d)+Math.abs(Math.cos(b.angle)*c);return e},a.jqplot.CanvasAxisTickRenderer.prototype.getHeight=function(a){if(this._elem)return this._elem.outerHeight(!0);var b=this._textRenderer,c=b.getWidth(a),d=b.getHeight(a),e=Math.abs(Math.cos(b.angle)*d)+Math.abs(Math.sin(b.angle)*c);return e},a.jqplot.CanvasAxisTickRenderer.prototype.getAngleRad=function(){var a=this.angle*Math.PI/180;return a},a.jqplot.CanvasAxisTickRenderer.prototype.setTick=function(a,b,c){return this.value=a,c&&(this.isMinorTick=!0),this},a.jqplot.CanvasAxisTickRenderer.prototype.draw=function(b,c){this.label||(this.label=this.prefix+this.formatter(this.formatString,this.value)),this._elem&&(a.jqplot.use_excanvas&&window.G_vmlCanvasManager.uninitElement!==undefined&&window.G_vmlCanvasManager.uninitElement(this._elem.get(0)),this._elem.emptyForce(),this._elem=null);var d=c.canvasManager.getCanvas();this._textRenderer.setText(this.label,b);var e=this.getWidth(b),f=this.getHeight(b);return d.width=e,d.height=f,d.style.width=e,d.style.height=f,d.style.textAlign="left",d.style.position="absolute",d=c.canvasManager.initCanvas(d),this._elem=a(d),this._elem.css(this._styles),this._elem.addClass("jqplot-"+this.axis+"-tick"),d=null,this._elem},a.jqplot.CanvasAxisTickRenderer.prototype.pack=function(){this._textRenderer.draw(this._elem.get(0).getContext("2d"),this.label)}})(jQuery)