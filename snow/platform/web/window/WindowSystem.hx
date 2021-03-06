package snow.platform.web.window;

import snow.Snow;
import snow.types.Types;
import snow.window.Window;
import snow.window.Windowing;
import snow.window.WindowSystem;

#if snow_web

        //Internal class handled by Windowing, a less concrete implementation of the window system
    @:noCompletion class WindowSystem extends WindowSystemBinding {

        public var gl_contexts : Map<Int, js.html.webgl.RenderingContext>;
        var seq_window : Int = 1;

        public function new( _manager:Windowing, _lib:Snow ) {

            manager = _manager;
            lib = _lib;
            gl_contexts = new Map();

        } //new

        override public function init() {
        } //init

        override public function process() {
        } //process

        override public function destroy() {
        } //destroy

        override public function create( config:WindowConfig, on_created: WindowHandle->Int->WindowConfig->Void ) {

            var _window_id = seq_window;
            var _handle : js.html.CanvasElement = js.Browser.document.createCanvasElement();

                    //assign the sizes
                _handle.width = config.width;
                _handle.height = config.height;

                    //make sure it displays nicely
                _handle.style.display = 'block';
                _handle.style.position = 'relative';
                _handle.style.margin = '2em auto 0 auto';
                _handle.style.background = '#000';

                    //add it to the document
                js.Browser.document.body.appendChild(_handle);

                //:todo: These options need to be exposed and documented
            var _gl_context = _handle.getContextWebGL({ alpha:false, premultipliedAlpha:false });
                //early out on no possible context
            if(_gl_context == null) {
                var msg =  'WebGL is required to run this!<br/><br/>';
                    msg += 'visit http://get.webgl.org/ for help <br/>';
                    msg += 'and contact the developer of the application';
                internal_fallback(msg);
                throw msg;
            }

                //make sure there is a set up context early
            if(snow.render.opengl.GL.current_context == null) {
                snow.render.opengl.GL.current_context = _gl_context;
            }

                //store it for activating later
            gl_contexts.set(_window_id, _gl_context);

                //get the real canvas position and give it to the config
            var _window_pos = get_real_window_position( _handle );

                config.x = _window_pos.x;
                config.y = _window_pos.y;

                //set the window title to the config title if there is one
            if(config.title != null && config.title != '') {
                js.Browser.document.title = config.title;
            }

                //tell them and give the handle for later.
            on_created(_handle, _window_id, config);
            _handle.setAttribute('id', 'window${_window_id}');

            seq_window++;

        } //window_create

        override public function destroy_window( _window:Window ) {

            js.Browser.document.body.removeChild( _window.handle );

        } //destroy_window

        override public function close( _window:Window ) {

            _window.handle.style.display = 'none';

        } //close

        override public function show( _window:Window ) {

            _window.handle.style.display = null;

        } //show

        override public function update( _window:Window ) {

            var _rect = _window.handle.getBoundingClientRect();

                if(_rect.left != _window.x || _rect.top != _window.y) {
                    lib.dispatch_system_event({
                        type : SystemEventType.window,
                        window : {
                            type : WindowEventType.window_moved,
                            timestamp : lib.time,
                            window_id : _window.id,
                            event : { x:_rect.left, y:_rect.top }
                        }
                    });
                }else if(_rect.width != _window.width || _rect.height != _window.height) {

                    lib.dispatch_system_event({
                        type : SystemEventType.window,
                        window : {
                            type : WindowEventType.window_size_changed,
                            timestamp : lib.time,
                            window_id : _window.id,
                            event : { x:_rect.width, y:_rect.height }
                        }
                    });

                    // _window.handle.width = _rect.width;
                    // _window.handle.height = _rect.height;

                }

            _rect = null;

        } //window_update

        override public function render( _window:Window ) {

            var _window_gl_context = gl_contexts.get(_window.id);
            if(snow.render.opengl.GL.current_context != _window_gl_context) {
                snow.render.opengl.GL.current_context = _window_gl_context;
            }

        } //window_render

        override public function swap( _window:Window ) {

            //:unsupported:
            //this concept is not possible in browser

        } //window_swap

        override public function simple_message( _window:Window, message:String, ?title:String="" ) {

            js.Browser.window.alert( message );

        } //window_simple_message

        override public function set_size( _window:Window, w:Int, h:Int ) {

            _window.handle.style.width = '${w}px';
            _window.handle.style.height = '${h}px';

        } //window_set_size

        override public function set_position( _window:Window, x:Int, y:Int ) {

            _window.handle.style.left = '${x}px';
            _window.handle.style.top = '${y}px';

        } //window_set_position

        public function get_real_window_position( handle:WindowHandle ) : { x:Int, y:Int } {

            // see the following link for this implementation
            // http://www.quirksmode.org/js/findpos.html

            var curleft = 0;
            var curtop = 0;

                //start at the canvas
            var _obj : js.html.Element = cast handle;
            var _has_parent : Bool = true;
            var _max_count = 0;

            while(_has_parent == true) {

                _max_count++;

                if(_max_count > 100) {
                    _has_parent = false;
                    break;
                } //prevent rogue endless loops

                if(_obj.offsetParent != null) {

                        //it still has an offset parent, add it up
                    curleft += _obj.offsetLeft;
                    curtop += _obj.offsetTop;

                        //then move onto the parent
                    _obj = _obj.offsetParent;

                } else {
                        //we are done
                    _has_parent = false;

                }
            } //while

            return { x:curleft, y:curtop };

        } //get_real_window_position

        override public function set_title( _window:Window, title:String ) {

            js.Browser.document.title = title;

        } //window_set_title

        override public function set_max_size( _window:Window, w:Int, h:Int ) {

            _window.handle.style.maxWidth = '${w}px';
            _window.handle.style.maxHeight = '${h}px';

        } //window_set_max_size

        override public function set_min_size( _window:Window, w:Int, h:Int ) {

            _window.handle.style.minWidth = '${w}px';
            _window.handle.style.minHeight = '${h}px';

        } //window_set_min_size



        var _pre_fs_padding : String = '0';
        var _pre_fs_margin : String = '0';
        var _pre_fs_s_width : String = '';
        var _pre_fs_s_height : String = '';
        var _pre_fs_width : Int = 0;
        var _pre_fs_height : Int = 0;

        override public function fullscreen( _window:Window, fullscreen:Bool, fullscreen_desktop:Bool = true ) {

                //as always browser support for newer features will be
                //sporadic. Tested fullscreen against firefox/chrome/opera/safari latest
                //all appear to work as expected, but have no cancel (user must press escape)
            if(fullscreen) {

                if(!fullscreen_desktop) {

                        //official api's first
                    if(_window.handle.requestFullscreen == null) {
                        if(_window.handle.requestFullScreen == null) {
                            if(untyped _window.handle.webkitRequestFullscreen == null) {
                                if(untyped _window.handle.mozRequestFullScreen == null) {

                                } else { untyped _window.handle.mozRequestFullScreen(); }
                            } else { untyped _window.handle.webkitRequestFullscreen(); }
                        } else { _window.handle.requestFullScreen(0); }
                    } else { _window.handle.requestFullscreen(); }

                } else {

                    _pre_fs_padding = _window.handle.style.padding;
                    _pre_fs_margin = _window.handle.style.margin;
                    _pre_fs_s_width = _window.handle.style.width;
                    _pre_fs_s_height = _window.handle.style.height;
                    _pre_fs_width = _window.handle.width;
                    _pre_fs_height = _window.handle.height;

                    _window.handle.style.margin = '0';
                    _window.handle.style.padding = '0';
                    _window.handle.style.width = js.Browser.window.innerWidth + 'px';
                    _window.handle.style.height = js.Browser.window.innerHeight + 'px';
                    _window.handle.width = js.Browser.window.innerWidth;
                    _window.handle.height = js.Browser.window.innerHeight;
                }

            } else {

                if(!fullscreen_desktop) {

                    //:unsupported:
                    //currently no cancel full screen in fullscreen mode

                } else {

                    _window.handle.style.padding = _pre_fs_padding;
                    _window.handle.style.margin = _pre_fs_margin;
                    _window.handle.style.width = _pre_fs_s_width;
                    _window.handle.style.height = _pre_fs_s_height;
                    _window.handle.width = _pre_fs_width;
                    _window.handle.height = _pre_fs_height;

                }

            }

        } //window_fullscreen

        override public function bordered( _window:Window, bordered:Bool ) {

            //:unsupported:
            //no such concept on browser

        } //window_bordered


        override public function grab( _window:Window, grabbed:Bool ) {

            if(grabbed) {
                    //official api's first
                if(_window.handle.requestPointerLock == null) {
                        if(untyped _window.handle.webkitRequestPointerLock == null) {
                            if(untyped _window.handle.mozRequestPointerLock == null) {

                            } else { untyped _window.handle.mozRequestPointerLock(); }
                        } else { untyped _window.handle.webkitRequestPointerLock(); }
                } else { _window.handle.requestPointerLock(); }

            } else {

                //:unsupported:
                //pointer lock cancel api not yet in browsers,
                //user must press escape

            }

        } //window_grab

        override public function set_cursor_position( _window:Window, x:Int, y:Int ) {

            // :unsupported:
            // for good reason.

        } //set_cursor_position

            /** Toggle the OS cursor. This is not window specific but system wide */
        var cursor_style : js.html.Element;
        var _cursor_visible : Bool = true;
        override function system_enable_cursor( enable:Bool ) {

            if(cursor_style == null) {
                cursor_style = js.Browser.document.createStyleElement();
                cursor_style.innerHTML = '* { cursor:none; }';
            }

            if(enable && !_cursor_visible) {
                _cursor_visible = true;
                js.Browser.document.body.removeChild(cursor_style);
            } else if(!enable && _cursor_visible) {
                _cursor_visible = false;
                js.Browser.document.body.appendChild(cursor_style);
            }

        } //system_enable_cursor

            /** Lock the OS cursor to the foreground window. This hides the cursor and prevents it from leaving, reporting relative coordinates. */
        override function system_lock_cursor( enable:Bool ) {

            if(lib.window != null) {
                grab(lib.window, enable);
            }

        } //system_lock_cursor

            /** Toggle vertical refresh. This is not window specific but context wide */
        override function system_enable_vsync( enable:Bool ) : Int {

            // :unsupported:
            //technically RAF is vsync but it's not a toggle,
            //and without it is terrible so, not doing that

            return -1;

        } //system_enable_vsync


        override public function display_count() : Int {

            //:unsupported:
            return 1;

        } //display_count

        override public function display_mode_count( display:Int ) : Int {

            //:unsupported:
            return 1;

        } //display_mode_count

        override public function display_native_mode( display:Int ) : DisplayMode {

            //:unsupported:

            return {
                format : 0,
                refresh_rate : 0,
                width : js.Browser.window.screen.width,
                height : js.Browser.window.screen.height
            };

        } //display_native_mode

        override public function display_current_mode( display:Int ) : DisplayMode {

            //:unsupported:
            //will always return the default display mode

            return display_native_mode(display);

        } //display_current_mode

        override public function display_mode( display:Int, mode_index:Int ) : DisplayMode {

            //:unsupported:
            //will always return the default display mode

            return display_native_mode(display);

        } //display_mode

            //returns the size of the main window
        override public function display_bounds( display:Int ) : { x:Int, y:Int, width:Int, height:Int } {

            return {
                x : 0,
                y : 0,
                width : js.Browser.window.innerWidth,
                height : js.Browser.window.innerHeight
            };

        } //display_bounds

        override public function display_name( display:Int ) : String {

            return js.Browser.navigator.vendor;

        } //display_name

            /** Called to set up any listeners on the given window  */
        override public function listen( _window:Window ) {

            _window.handle.addEventListener('mouseleave', on_internal_leave);
            _window.handle.addEventListener('mouseenter', on_internal_enter);

        } //listen

            /** Called to remove any listeners on the given window  */
        override public function unlisten( _window:Window ) {

            _window.handle.removeEventListener('mouseleave', on_internal_leave);
            _window.handle.removeEventListener('mouseenter', on_internal_enter);

        } //unlisten


        function on_internal_leave( _mouse_event:js.html.MouseEvent ) {

            var _window : Window = lib.windowing.window_from_handle(cast _mouse_event.target);

                //tell the system
            lib.dispatch_system_event({
                type : SystemEventType.window,
                window : {
                    type : WindowEventType.window_leave,
                    timestamp : _mouse_event.timeStamp,
                    window_id : _window.id,
                    event : _mouse_event
                }
            });

        } //on_internal_leave

        function on_internal_enter( _mouse_event:js.html.MouseEvent ) {

            var _window : Window = lib.windowing.window_from_handle(cast _mouse_event.target);

                //tell the system
            lib.dispatch_system_event({
                type : SystemEventType.window,
                window : {
                    type : WindowEventType.window_enter,
                    timestamp : _mouse_event.timeStamp,
                    window_id : _window.id,
                    event : _mouse_event
                }
            });

        } //on_internal_enter

        function internal_fallback( message:String ) {

            var text_el : js.html.Element;
            var overlay_el : js.html.Element;

            text_el = js.Browser.document.createDivElement();
            overlay_el = js.Browser.document.createDivElement();

            text_el.style.marginLeft = 'auto';
            text_el.style.marginRight = 'auto';
            text_el.style.color = '#d3d3d3';
            text_el.style.marginTop = '5em';
            text_el.style.fontSize = '1.4em';
            text_el.style.fontFamily = 'helvetica,sans-serif';
            text_el.innerHTML = message;

            overlay_el.style.top = '0';
            overlay_el.style.left = '0';
            overlay_el.style.width = '100%';
            overlay_el.style.height = '100%';
            overlay_el.style.display = 'block';
            overlay_el.style.minWidth = '100%';
            overlay_el.style.minHeight = '100%';
            overlay_el.style.textAlign = 'center';
            overlay_el.style.position = 'absolute';
            overlay_el.style.background = 'rgba(1,1,1,0.90)';

            overlay_el.appendChild(text_el);
            js.Browser.document.body.appendChild(overlay_el);


        }

    } //WindowSystem

#end //snow_web
