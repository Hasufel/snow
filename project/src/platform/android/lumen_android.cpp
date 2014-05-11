#ifdef ANDROID


#include <jni.h>
#include <android/log.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>

#include <map>
#include <string>

#include "lumen_core.h"
#include "common/ByteArray.h"
#include "platform/android/lumen_android.h"
#include "lumen_io.h"
#include "libs/sdl/SDL.h"

#define LOG(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "/ lumen /", __VA_ARGS__))


static JavaVM* java_vm;

#ifdef LUMEN_LIB_OPENAL
    void alcandroid_OnLoad( JavaVM *vm );
    void alcandroid_OnUnload( JavaVM *vm );
#endif //LUMEN_LIB_OPENAL

  //This is called after SDL gets inited and passes
#ifdef LUMEN_USE_SDL

    int SDL_main(int argc, char *argv[]) {
        LOG("/ lumen / android post init SDL_main");
        return 0;
    }

#endif //LUMEN_USE_SDL

namespace lumen {

    std::map<std::string, jclass> jClassCache;

    AAssetManager* androidAssetManager = 0;
    jclass androidAssetManagerRef = 0;

    void init_core_platform() {

        lumen::log("/ lumen / android core platform init");
        jClassCache = std::map<std::string, jclass>();

        JNIEnv *env = GetEnv();
        env->GetJavaVM( &java_vm );

        #ifdef LUMEN_LIB_OPENAL
            alcandroid_OnLoad( java_vm );
        #endif

    } //init_core_platform

    void shutdown_core_platform() {

        #ifdef LUMEN_LIB_OPENAL
            alcandroid_OnLoad( java_vm );
        #endif

    } //shutdown_core_platform

    void update_core_platform() {

    } //update_core_platform

    AAsset *AndroidGetAsset(const char *inResource) {

        if (!androidAssetManager) {

            JNIEnv *env = GetEnv();

            jclass cls = FindClass("org/libsdl/app/SDLActivity");

            jmethodID mid = env->GetStaticMethodID(cls, "getAssetManager", "()Landroid/content/res/AssetManager;");

            if (mid == 0) {
                return 0;
            }

            jobject assetManager = (jobject)env->CallStaticObjectMethod(cls, mid);

            if (assetManager==0) {
                LOG("Could not find assetManager for asset %s", inResource);
                return 0;
            }

            androidAssetManager = AAssetManager_fromJava(env, assetManager);
            if (androidAssetManager==0) {
                LOG("Could not create assetManager for asset %s", inResource);
                return 0;
            }

            androidAssetManagerRef = (jclass)env->NewGlobalRef(assetManager);
            env->DeleteLocalRef(assetManager);
        }

        return AAssetManager_open(androidAssetManager, inResource, AASSET_MODE_UNKNOWN);

    } //AndroidGetAsset

    ByteArray AndroidGetAssetBytes(const char *inResource) {

       AAsset *asset = AndroidGetAsset(inResource);

        if (asset) {

            long size = AAsset_getLength(asset);
            ByteArray result(size);
            AAsset_read(asset, result.Bytes(), size);
            AAsset_close(asset);

            return result;
        }

        return 0;
    }

    AndroidFileInfo AndroidGetAssetFD(const char *inResource) {

        AndroidFileInfo info;
        info.fd = 0;
        info.offset = 0;
        info.length = 0;

        AAsset *asset = AndroidGetAsset(inResource);

        if( asset ) {
            info.fd = AAsset_openFileDescriptor(asset, &info.offset, &info.length);
            if (info.fd <= 0) {
                LOG("Bad asset : %s", inResource);
            }
            AAsset_close(asset);
        } //if(asset)

       return info;
    }


    JNIEnv *GetEnv() {

        return (JNIEnv*)SDL_AndroidGetJNIEnv();

    } //JNIEnv

    jclass FindClass(const char *className,bool inQuiet) {

        std::string cppClassName(className);
        jclass ret;

        if(jClassCache[cppClassName]!=NULL) {

            ret = jClassCache[cppClassName];

        } else {

            JNIEnv *env = GetEnv();
            jclass tmp = env->FindClass(className);

            if (!tmp) {
                if (inQuiet) {
                    jthrowable exc = env->ExceptionOccurred();
                    if (exc) {
                        env->ExceptionClear();
                    }
                } else {
                    CheckException(env);
                }

                return 0;
            }

            ret = (jclass)env->NewGlobalRef(tmp);
            jClassCache[cppClassName] = ret;
            env->DeleteLocalRef(tmp);
        }

        return ret;

    } //findClass

    void CheckException(JNIEnv *env, bool inThrow) {

        jthrowable exc = env->ExceptionOccurred();
        if (exc) {
            env->ExceptionDescribe();
            env->ExceptionClear();

            if (inThrow) {
                val_throw(alloc_string("JNI Exception"));
            }
        }

    } //CheckException

} //namespace lumen

#endif
