/**
 * @author Niklas Krauth, Telota, BBAW
 */
(function($) 
{		
	prototypeAdds = 
	{
		_init: function()
		{
			$.ui.dialog.prototype._init.call(this);
			var self = this,
				window = (this.window = this.element)
					.addClass('ui-window'),
				
				uiDialogTitlebarClose = self.element.parent('.ui-dialog').find('.ui-dialog-titlebar-close'),
			
				uiDialogTitlebarMinimize = (self.uiDialogTitlebarMinimize)= $('<a href="#"/>')
				.addClass(
					'ui-dialog-titlebar-minimize ' +
					'ui-corner-all'
				)
				.attr('role', 'button')
				.hover(
					function() {
						uiDialogTitlebarMinimize.addClass('ui-state-hover');
					},
					function() {
						uiDialogTitlebarMinimize.removeClass('ui-state-hover');
					}
				)
				.focus(function() {
					uiDialogTitlebarMinimize.addClass('ui-state-focus');
				})
				.blur(function() {
					uiDialogTitlebarMinimize.removeClass('ui-state-focus');
				})
				.mousedown(function(event){
					event.stopPropagation();
					return false;
				})
				.click(function(event) {
					event.stopPropagation();
					self.minimize(event);
					return false;
				})
				.insertBefore(uiDialogTitlebarClose), 
				
				uiDialogTitlebarMinimizeText = (this.uiDialogTitlebarMinimizeText = $('<span/>'))
				.addClass(
					'ui-icon ' +
					'ui-icon-newwin'
				)
				.text('minimize')
				.appendTo(uiDialogTitlebarMinimize),
				
				uiDialogTitlebarDock = $('<a href="#"/>')
				.addClass(
					'ui-dialog-titlebar-dock ' +
					'ui-corner-all'
				)
				.attr('role', 'button')
				.hover(
					function() {
						uiDialogTitlebarDock.addClass('ui-state-hover');
					},
					function() {
						uiDialogTitlebarDock.removeClass('ui-state-hover');
					}
				)
				.focus(function() {
					uiDialogTitlebarDock.addClass('ui-state-focus');
				})
				.blur(function() {
					uiDialogTitlebarDock.removeClass('ui-state-focus');
				})
				.mousedown(function(event){
					event.stopPropagation();
					return false;
				})
				.click(function(event) {
					event.stopPropagation();
					self.dock(event);
					return false;
				})
				.insertBefore(uiDialogTitlebarMinimize), 
				
				uiDialogTitlebarDockText = (this.uiDialogTitlebarDockText = $('<span/>'))
				.addClass(
					'ui-icon ' +
					'ui-icon-minusthick'
				)
				.text('minimize')
				.appendTo(uiDialogTitlebarDock);
				
				self.uiDialogTitlebar.dblclick(function(event){
					event.stopPropagation();
					self.minimize(event);
					return false;
					});
				
				this._isMinimized = false;
				this._isDocked = false;
		},
		
		isMinimized: function() {
		return this._isMinimized;
		},
		
		isDocked: function() {
		return this._isDocked;
		},
		
		minimize: function(event)
		{
			var self = this;
			
			if (false === self._trigger('beforeminimize', event)) {
				return;
			}
	
			(self.overlay && self.overlay.destroy());
	
			self.element.hide();
			self._size();
			$.ui.dialog.overlay.resize();
			self.uiDialog.resizable('destroy');
			self.options.resizable = false;
			self.options._isMinimized = true;
			self.uiDialogTitlebarMinimize.unbind('click').click(function(event) 
				{
					event.stopPropagation();
					self.maximize(event);
					return false;
				});
			self.uiDialogTitlebar.unbind('dblclick').dblclick(function(event) 
				{
					event.stopPropagation();
					self.maximize(event);
					return false;
				});
			
			self.options.modal = false;
		},
		
		maximize: function(event)
		{
			var self = this;
			
			if (false === self._trigger('beforemaximize', event)) {
				return;
			}
	
			(self.overlay && self.overlay.destroy());
			
			self.element.show();
			self._size();
			$.ui.dialog.overlay.resize();
			self._makeResizable();
			self.options.resizable = true;
			self.options._isMinimized = false;
			self.uiDialogTitlebarMinimize.unbind('click').click(function(event) 
				{
					event.stopPropagation();
					self.minimize(event);
					return false;
				});
			self.uiDialogTitlebar.unbind('dblclick').dblclick(function(event) 
				{
					event.stopPropagation();
					self.minimize(event);
					return false;
				});
			
			self.options.modal = false;
		},
		
		dock: function(event)
		{
			if(this.options.dock == null)
			{
				alert('Es ist kein Dock definiert.')
				return;
			}
			var self = this;
			
			if (false === self._trigger('beforedock', event)) {
				return;
			}
	
			(self.overlay && self.overlay.destroy());
			self.uiDialog.unbind('keypress.ui-dialog');
	
			(self.options.dockEffect
				? self.uiDialog.hide(self.options.dockEffect, function() {
					self._trigger('dock', event);
				})
				: self.uiDialog.hide());
				
			var	titleId = $.ui.dialog.getTitleId(this.element);
			var dockElement = (self.dockElement) = $('<button></button>')
				.attr({id: titleId, href: '#'})
				.addClass('dockElement ui-corner-all')
				.text(this.options.title)
				.click(function(event)
				{
					event.stopPropagation();
					self.undock();
					return false;
				})
				.appendTo('#' + self.options.dock);
			$.ui.dialog.overlay.resize();
	
			self.options._isDocked = true;
			self.options.modal = false;
		},
		
		undock: function(event)
		{
			var self = this;
			
			if (false === self._trigger('beforeundock', event)) {
				return;
			}
			
			(self.overlay && self.overlay.destroy());
			self.uiDialog.unbind('keypress.ui-dialog');
			
			self.moveToTop(false, event);
			
			(self.options.undockEffect
				? self.uiDialog.show(self.options.undockEffect, function() {
					self._trigger('dock', event);
				})
				: self.uiDialog.show());
			
			(self.options.afterUndock && self.options.afterUndock.apply(this, [self]));
			
			self.options._isDocked = false;
			self.options.modal = false;
			self.dockElement.remove();
			self.dockElement = null;
		}
		
	};
	
	prototype = $.extend({}, $.ui.dialog.prototype, prototypeAdds);
	 
	$.widget("ui.window", prototype);
	
	$.ui.window.defaults = 
	{
		dock: null,
		dockEffect: null,
		undockEffect: null,
		afterUndock: null
	};
	$.extend($.ui.window.defaults, $.ui.dialog.defaults);
	
}
)(jQuery);