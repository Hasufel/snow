package snow.types;

import snow.Snow;
import snow.utils.ByteArray;
import snow.utils.UInt8Array;

import snow.assets.AssetImage;
import snow.assets.AssetText;
import snow.assets.AssetBytes;
import snow.assets.AssetAudio;

typedef Key = snow.input.Keycodes.Keycodes;
typedef Scan = snow.input.Keycodes.Scancodes;


/** Information for a single asset */
typedef AssetInfo = {

        /** the asset id */
    var id : String;
        /** the location of the asset */
    var path : String;
        /** the asset extension, if any */
    var ext : String;
        /** a convenience type indicator */
    var type : String;

} //AssetInfo

/** A type to identify assets when stored as an Asset */
enum AssetType {

    bytes;
    text;
    image;
    audio;

} //AssetType


/** The options for an `AssetBytes` asset.
    Get assets from the `Assets` class, via `app.assets` */
typedef AssetBytesOptions = {
    ? strict : Bool,
    ? async : Bool,
    ? onload : AssetBytes -> Void
} //AssetBytesOptions

/** The options for an `AssetText` asset.
    Get assets from the `Assets` class, via `app.assets` */
typedef AssetTextOptions = {
    ? strict : Bool,
    ? async : Bool,
    ? onload : AssetText -> Void
} //AssetTextOptions

/** The options for an `AssetImage` asset.
    Get assets from the `Assets` class, via `app.assets` */
typedef AssetImageOptions = {
    ? strict : Bool,
    ? components : Int,
    ? onload : AssetImage -> Void,
    ? bytes : ByteArray
} //AssetImageOptions

/** The options for an `AssetAudio` asset */
typedef AssetAudioOptions = {
    ? strict : Bool,
    ? type : String,
    ? load : Bool,
    ? onload : AssetAudio -> Void
} //AssetAudioOptions


/** Snow specific configurations, set from build config */
typedef SnowConfig = {

        /** whether or not the core should run a loop at all, default: true */
    @:optional var has_loop : Bool;
        /** The default place to find the asset manifest file, default: `manifest` */
    @:optional var config_assets_path : String;
        /** The default place to find the runtime config file, default: `config.json` */
    @:optional var config_runtime_path : String;
        /** If set, no default runtime config will be loaded (use `App.config` to load a config manually). default: false */
    @:optional var config_custom_runtime : Bool;
        /** If set, no default asset list will be loaded (use `App.config` to load a config manually). default: false */
    @:optional var config_custom_assets : Bool;

} //SnowConfig

/** The runtime application config info */
typedef AppConfig = {

        /** whether or not to create and run a default window, default: true */
    @:optional var has_window   : Bool;

        /** the window config for the default window, if `has_window` is true. default: see `WindowConfig` docs*/
    @:optional var window       : WindowConfig;
        /** the user specific config, by default, read from a json file at runtime */
    @:optional var runtime      : Dynamic;
        /** the raw list of assets. use the app.assets from Snow for access to these. read from a manifest file by default */
    @:optional var assets       : Array<AssetInfo>;
        /** config specific to the web target */
    @:optional var web          : AppConfigWeb;
        /** config specific to the web target */
    @:optional var native       : AppConfigNative;

} //AppConfig

typedef AppConfigWeb = {

        /** If true, right clicking will consume the event on the canvas. `event.preventDefault` is used. default: true*/
    @:optional var no_context_menu : Bool;

} //AppConfigWeb

typedef AppConfigNative = {

        /** The default length of a single stream buffer in bytes. default:176400, This is ~1 sec in 16 bit mono. */
    @:optional var audio_buffer_length : Int;

        /** The default number of audio buffers to use for a single stream. Set no less than 2, as it's a queue. See `Audio` docs. default:4 */
    @:optional var audio_buffer_count : Int;

} //AppConfigWeb

typedef FileFilter = {

        /** An extension for the filter. i.e `md`, `txt`, `png` or a special `*` for any file type.  */
    var extension:String;
        /** An optional description for this filter i.e `markdown files`, `text files`, `all files` */
    @:optional var desc:String;

} //FileFilter


/** Information about an image file/data */
typedef ImageInfo = {

        /** source asset id */
    var id : String;
        /** image width from source image */
    var width : Int;
        /** image height from source image */
    var height : Int;
        /** The actual width, used when image is automatically padded to POT */
    var width_actual : Int;
        /** The actual height, used when image is automatically padded to POT */
    var height_actual : Int;
        /** used bits per pixel */
    var bpp : Int;
        /** source bits per pixel */
    var bpp_source : Int;
        /** image data */
    var data : UInt8Array;

} //ImageInfo

/** The type of audio format */
enum AudioFormatType {

    unknown;
    ogg;
    wav;
    pcm;

} //AudioFormatType

#if snow_audio_howlerjs

        /** The platform specific implementation detail about the audio data */
    typedef AudioDataInfo = {
            /** */
        var _unused : Bool;
    } //AudioDataInfo

#else

        /** The platform specific implementation detail about the audio data */
    typedef AudioDataInfo = {

            /** the file length in bytes */
        var length : Int;
            /** the pcm uncompressed raw length in bytes */
        var length_pcm : Int;
            /** number of channels */
        var channels : Int;
            /** hz rate */
        var rate : Int;
            /** sound bitrate */
        var bitrate : Int;
            /** bits per sample, 8 / 16 */
        var bits_per_sample : Int;
            /** sound raw data */
        var bytes : ByteArray;

    } //AudioDataInfo

#end //

/** Information about an audio file/data */
typedef AudioInfo = {

        /** file source id */
    var id : String;
        /** format */
    var format : AudioFormatType;
        /** the platform audio data info */
    var data : AudioDataInfo;
        /** the platform audio handle for later manipulation */
    var handle : AudioHandle;

} //AudioInfo

/** Information about an audio portion requested via assets */
typedef AudioDataBlob = {

        /** True if the file has reached the end of the data in this blob */
    var bytes : ByteArray;
        /** The data stored in this blob */
    var complete : Bool;

} //AudioDataBlob


/** Window configuration information for creating windows */
typedef WindowConfig = {

        /** create in fullscreen, default: false, `mobile` true */
    @:optional var fullscreen   : Bool;
        /** allow the window to be resized, default: true */
    @:optional var resizable    : Bool;
        /** create as a borderless window, default: false */
    @:optional var borderless   : Bool;
        /** a value of `0`, `2`, `4`, `8` or other valid antialiasing flags. default: 0 */
    @:optional var antialiasing : Int;
        /** set the number of red bits for the rendering to use. Unless you need to change this, don't. default: 8 */
    @:optional var red_bits   : Int;
        /** set the number of green bits for the rendering to use. Unless you need to change this, don't. default: 8 */
    @:optional var green_bits   : Int;
        /** set the number of blue bits for the rendering to use. Unless you need to change this, don't. default: 8 */
    @:optional var blue_bits   : Int;
        /** set the number of alpha bits for the rendering to use. Unless you need to change this, don't. default: 8 */
    @:optional var alpha_bits   : Int;
        /** create a depth buffer at the specified bit depth (i.e `0` or `16` bit depth buffer) default: 0 */
    @:optional var depth_bits   : Int;
        /** create a stencil buffer at the specified bit depth (i.e `8` or `16` bit stencil buffer). default: 0 */
    @:optional var stencil_bits : Int;
        /** window y at creation. Leave this alone to use the OS default. */
    @:optional var x            : Int;
        /** window x at creation. Leave this alone to use the OS default. */
    @:optional var y            : Int;
        /** window height at creation, default: 960 */
    @:optional var width        : Int;
        /** window width at creation, default: 640 */
    @:optional var height       : Int;
        /** window title, default: 'snow app' */
    @:optional var title        : String;
        /** disables input arriving at/from this window. default: false */
    @:optional var no_input     : Bool;

} //WindowConfig

/** A system event */
typedef SystemEvent = {

        /** The type of system event this event is. */
    @:optional var type : SystemEventType;
        /** If type is `window` this will be populated, otherwise null */
    @:optional var window : WindowEvent;
        /** If type is `input` this will be populated, otherwise null */
    @:optional var input : InputEvent;
        /** If type is `file` this will be populated, otherwise null */
    @:optional var file : FileEvent;

} //SystemEvent

/** A system window event */
typedef WindowEvent = {

        /** The type of window event this was */
    @:optional var type : WindowEventType;
        /** The time in seconds that this event occured, useful for deltas */
    @:optional var timestamp : Float;
        /** The window id from which this event originated */
    @:optional var window_id : Int;
        /** The raw platform event data, only useful if you are implementing
            a new platform or lack access to data from the system that snow does not expose */
    @:optional var event : Dynamic;

} //WindowEvent

/** A system file watch event */
typedef FileEvent = {

        /** The type of file watch event, modify/create/delete */
    @:optional var type : FileEventType;
        /** The time in seconds when this event was fired */
    @:optional var timestamp : Float;
        /** The absolute path that was notifying */
    @:optional var path : String;

} //FileEvent

/** A system input event */
typedef InputEvent = {

        /** The type of input event this was */
    @:optional var type : InputEventType;
        /** The time in seconds that this event occured, useful for deltas */
    @:optional var timestamp : Float;
        /** The window id from which this event originated */
    @:optional var window_id : Int;
        /** The raw platform event data, only useful if you are implementing
            a new platform or lack access to data from the system that snow does not expose */
    @:optional var event : Dynamic;

} //InputEvent

/** Information about a display mode */
typedef DisplayMode = {
    format : Int,
    refresh_rate : Int,
    width : Int,
    height : Int
}

    /** A platform window handle */
#if snow_web
    typedef WindowHandle = js.html.CanvasElement;
#else
    typedef WindowHandle = Null<Float>;
#end //snow_web

    /** A platform window handle */
#if snow_audio_howlerjs
    typedef AudioHandle = snow.platform.web.audio.howlerjs.Howl;
#else
    typedef AudioHandle = Null<Float>;
#end //snow_web


/** A typed system event */
enum SystemEventType {

/** An unknown system event */
    unknown;
/** An internal system init event */
    init;
/** An internal system ready event */
    ready;
/** An internal system update event */
    update;
/** An system shutdown event */
    shutdown;
/** An system window event */
    window;
/** An system input event */
    input;
/** An system quit event. Initiated by user, can be cancelled/ignored */
    quit;
/** An system terminating event, called by the OS (mobile specific) */
    app_terminating;
/** An system low memory event, clear memory if you can. Called by the OS (mobile specific) */
    app_lowmemory;
/** An event for just before the app enters the background, called by the OS (mobile specific) */
    app_willenterbackground;
/** An event for when the app enters the background, called by the OS (mobile specific) */
    app_didenterbackground;
/** An event for just before the app enters the foreground, called by the OS (mobile specific) */
    app_willenterforeground;
/** An event for when the app enters the foreground, called by the OS (mobile specific) */
    app_didenterforeground;
/** An event for when the a file watch notification occurs */
    file;


} //SystemEventType

enum FileEventType {

/** An unknown watch event */
    unknown;
/** An event for when the a file is modified */
    modify;
/** An event for when the a file is removed */
    remove;
/** An event for when the a file is created */
    create;
/** An event for when the a file is dropped on a window */
    drop;

} //FileEventType

//Window stuff

/** A typed window event */
enum WindowEventType {

/** An unknown window event */
    unknown;
/** A window is created */
    window_created;
/** A window is shown */
    window_shown;
/** A window is hidden */
    window_hidden;
/** A window is exposed */
    window_exposed;
/** A window is moved */
    window_moved;
/** A window is resized, by the user or code. */
    window_resized;
/** A window is resized, by the OS or internals. */
    window_size_changed;
/** A window is minimized */
    window_minimized;
/** A window is maximized */
    window_maximized;
/** A window is restored */
    window_restored;
/** A window is entered by a mouse */
    window_enter;
/** A window is left by a mouse */
    window_leave;
/** A window has gained focus */
    window_focus_gained;
/** A window has lost focus */
    window_focus_lost;
/** A window is being closed/hidden */
    window_close;
/** A window is being destroyed */
    window_destroy;

} //WindowEventType

/** A typed input event */
enum InputEventType {

/** An unknown input event */
    unknown;
/** An keyboard input event */
    key;
/** An mouse input event */
    mouse;
/** An touch input event */
    touch;
/** An joystick input event. On mobile, accellerometer is a joystick (for now) */
    joystick;
/** An controller input event. Use these instead of joystick on desktop. */
    controller;

} //InputEventType

/** A text specific event event type */
enum TextEventType {

/** An edit text typing event */
    edit;
/** An input text typing event */
    input;

} //TextEventType

/** A gamepad device event type */
enum GamepadDeviceEventType {

/** A device added event */
    device_added;
/** A device removed event */
    device_removed;
/** A device was remapped */
    device_remapped;

} //GamepadEventType


/** Input modifier state */
typedef ModState = {

        /** no modifiers are down */
    var none : Bool;
        /** left shift key is down */
    var lshift : Bool;
        /** right shift key is down */
    var rshift : Bool;
        /** left ctrl key is down */
    var lctrl : Bool;
        /** right ctrl key is down */
    var rctrl : Bool;
        /** left alt/option key is down */
    var lalt : Bool;
        /** right alt/option key is down */
    var ralt : Bool;
        /** left windows/command key is down */
    var lmeta : Bool;
        /** right windows/command key is down */
    var rmeta : Bool;
        /** numlock is enabled */
    var num : Bool;
        /** capslock is enabled */
    var caps : Bool;
        /** mode key is down */
    var mode : Bool;
        /** left or right ctrl key is down */
    var ctrl : Bool;
        /** left or right shift key is down */
    var shift : Bool;
        /** left or right alt/option key is down */
    var alt : Bool;
        /** left or right windows/command key is down */
    var meta : Bool;

} //ModState


//Conversion helpers for native <-> snow events

@:noCompletion class SystemEvents {

        //snow core events

    public static var se_unknown                    = 0;
    public static var se_init                       = 1;
    public static var se_ready                      = 2;
    public static var se_update                     = 3;
    public static var se_shutdown                   = 4;
    public static var se_window                     = 5;
    public static var se_input                      = 6;

        //snow application events

    public static var se_quit                       = 7;
    public static var se_app_terminating            = 8;
    public static var se_app_lowmemory              = 9;
    public static var se_app_willenterbackground    = 10;
    public static var se_app_didenterbackground     = 11;
    public static var se_app_willenterforeground    = 12;
    public static var se_app_didenterforeground     = 13;
    public static var se_file                       = 14;

//Helpers

    public static function typed(type:Int) : SystemEventType {

            if(type == se_init)                         return SystemEventType.init;
            if(type == se_ready)                        return SystemEventType.ready;
            if(type == se_update)                       return SystemEventType.update;
            if(type == se_shutdown)                     return SystemEventType.shutdown;
            if(type == se_window)                       return SystemEventType.window;
            if(type == se_input)                        return SystemEventType.input;

            if(type == se_quit)                         return SystemEventType.quit;
            if(type == se_app_terminating)              return SystemEventType.app_terminating;
            if(type == se_app_lowmemory)                return SystemEventType.app_lowmemory;
            if(type == se_app_willenterbackground)      return SystemEventType.app_willenterbackground;
            if(type == se_app_didenterbackground)       return SystemEventType.app_didenterbackground;
            if(type == se_app_willenterforeground)      return SystemEventType.app_willenterforeground;
            if(type == se_app_didenterforeground)       return SystemEventType.app_didenterforeground;
            if(type == se_file)                         return SystemEventType.file;

        return SystemEventType.unknown;

    } //typed

} //SystemEvents

@:noCompletion class WindowEvents {

//window events

    public static var we_unknown          = 0;
    public static var we_created          = 1;
    public static var we_shown            = 2;
    public static var we_hidden           = 3;
    public static var we_exposed          = 4;
    public static var we_moved            = 5;
    public static var we_resized          = 6;
    public static var we_size_changed     = 7;
    public static var we_minimized        = 8;
    public static var we_maximized        = 9;
    public static var we_restored         = 10;
    public static var we_enter            = 11;
    public static var we_leave            = 12;
    public static var we_focus_gained     = 13;
    public static var we_focus_lost       = 14;
    public static var we_close            = 15;
    public static var we_destroy          = 16;

//Helpers

        /** returns a typed `WindowEventType` from an integer ID, for communication between internal native + haxe code */
    public static function typed(type:Int) : WindowEventType {

            if(type == we_created)        return WindowEventType.window_created;
            if(type == we_shown)          return WindowEventType.window_shown;
            if(type == we_hidden)         return WindowEventType.window_hidden;
            if(type == we_exposed)        return WindowEventType.window_exposed;
            if(type == we_moved)          return WindowEventType.window_moved;
            if(type == we_resized)        return WindowEventType.window_resized;
            if(type == we_size_changed)   return WindowEventType.window_size_changed;
            if(type == we_minimized)      return WindowEventType.window_minimized;
            if(type == we_maximized)      return WindowEventType.window_maximized;
            if(type == we_restored)       return WindowEventType.window_restored;
            if(type == we_enter)          return WindowEventType.window_enter;
            if(type == we_leave)          return WindowEventType.window_leave;
            if(type == we_focus_gained)   return WindowEventType.window_focus_gained;
            if(type == we_focus_lost)     return WindowEventType.window_focus_lost;
            if(type == we_close)          return WindowEventType.window_close;
            if(type == we_destroy)        return WindowEventType.window_destroy;

        return WindowEventType.unknown;

    } //typed

} //WindowEvents

@:noCompletion class InputEvents {

//Input events

        public static var ie_unknown                    = 0;
        public static var ie_key                        = 1;
        public static var ie_mouse                      = 2;
        public static var ie_touch                      = 3;
        public static var ie_joystick                   = 4;
        public static var ie_controller                 = 5;

//Helpers

        /** returns a typed `InputEventType` from an integer ID, for communication between internal native + haxe code */
    public static function typed(type:Int) : InputEventType {

            if(type == ie_unknown)      return InputEventType.unknown;
            if(type == ie_key)          return InputEventType.key;
            if(type == ie_mouse)        return InputEventType.mouse;
            if(type == ie_touch)        return InputEventType.touch;
            if(type == ie_joystick)     return InputEventType.joystick;
            if(type == ie_controller)   return InputEventType.controller;

        return InputEventType.unknown;

    } //typed

} //InputEvents

@:noCompletion class FileEvents {

//File watch events

        public static var fe_unknown                    = 0;
        public static var fe_modify                     = 1;
        public static var fe_remove                     = 2;
        public static var fe_create                     = 3;
        public static var fe_drop                       = 4;

//Helpers

        /** returns a typed `FileEvent` from an integer ID, for communication between internal native + haxe code */
    public static function typed(type:Int) : FileEventType {

            if(type == fe_unknown)      return FileEventType.unknown;
            if(type == fe_modify)       return FileEventType.modify;
            if(type == fe_remove)       return FileEventType.remove;
            if(type == fe_create)       return FileEventType.create;
            if(type == fe_drop)         return FileEventType.drop;

        return FileEventType.unknown;

    } //typed

} //FileEvents
