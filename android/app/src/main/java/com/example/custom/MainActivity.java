package com.example.custom;

import android.annotation.SuppressLint;
import android.app.Presentation;
import android.content.Context;
import android.hardware.display.DisplayManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Display;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;

import java.util.ArrayList;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.dart.DartExecutor;

public class MainActivity extends FlutterActivity implements FlutterPlugin, ActivityAware {

    private static final String TAG = "MainActivity";
    private static final String CHANNEL = "presentation_displays_plugin";
    private static final String EVENT_CHANNEL = "com.example.yourapp/event_channel";
    MethodChannel flutterEngineChannel;
    private Context context;
    private DisplayManager displayManager;
    private Presentation presentation;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        this.displayManager = (DisplayManager) getSystemService(Context.DISPLAY_SERVICE);
        this.context = this;
         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        switch (call.method) {
                            case "showPresentation":
                                String displayId = call.argument("displayId");
                                String routerName = call.argument("routerName");
                                result.success(showPresentation(displayId, routerName));
                                break;
                            case "hidePresentation":
                                hidePresentation(call, result);
                                break;
                            case "listDisplay":

                                Gson gson = new Gson();
                                String category = call.argument("category");
                                Display[] displays = displayManager != null ? displayManager.getDisplays(category) : null;
                                List<DisplayJson> listJson = new ArrayList<>();

                                if (displays != null) {
                                    for (Display display : displays) {
                                        DisplayJson d = new DisplayJson(
                                                String.valueOf(display.getDisplayId()),
                                                String.valueOf(display.getFlags()),
                                                String.valueOf(display.getRotation()),
                                                display.getName()
                                        );
                                        listJson.add(d);

                                        // Show toast for each DisplayJson object
                                    }
                                }

                                result.success(gson.toJson(listJson));
                                break;

                            case "transferDataToPresentation":
                                try {
                                      flutterEngineChannel.invokeMethod("DataTransfer", call.arguments);
                                    result.success(true);
                                } catch (Exception e) {
                                      Log.e(TAG, "Error in transferDataToPresentation", e);
                                    result.success(false);
                                }
                                break;
                            default:
                                result.notImplemented();
                                break;
                        }
                    }
                });

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(new DisplayConnectedStreamHandler(displayManager));
    }


    @SuppressLint("LongLogTag")
    private boolean showPresentation(String displayId, String routerName) {
        try {

            int displayIdInt = Integer.parseInt(displayId);
            Display display = displayManager.getDisplay(displayIdInt);
            FlutterEngine flutterEngine = createFlutterEngine(routerName);

            if (display != null && flutterEngine != null) {
                flutterEngineChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL + "_engine");
                 presentation = new PresentationDisplay(context, routerName, display);
                presentation.show();
                return true;
            } else {

                Log.e("MainActivity", display == null ? "Can't find display" : "Can't find FlutterEngine");
                return false;
            }
        } catch (Exception e) {
            Log.e("MainActivity", "Error in showPresentation", e);
            return false;
        }
    }
    private FlutterEngine createFlutterEngine(String tag) {
        if (context == null) {
            return null;
        }

        FlutterEngine engine = FlutterEngineCache.getInstance().get(tag);
        if (engine == null) {
            engine = new FlutterEngine(context);
            engine.getNavigationChannel().setInitialRoute(tag);
            engine.getDartExecutor().executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
            );
            engine.getLifecycleChannel().appIsResumed();
            FlutterEngineCache.getInstance().put(tag, engine);

        } else {
         }
        return engine;
    }


    private void hidePresentation(MethodCall call, Result result) {
        try {
            JSONObject obj = new JSONObject((String) call.arguments);
            Log.i(TAG, "Channel: method: " + call.method + " | displayId: " + obj.getInt("displayId"));

            if (presentation != null) {
                presentation.dismiss();
                presentation = null;
               }
            result.success(true);
        } catch (Exception e) {
            result.error(call.method, e.getMessage(), null);

        }



    }



    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        // Code here if needed
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // Code here if needed
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        this.context = binding.getActivity();
        displayManager = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        // Implement if needed
    }

    @Override
    public void onDetachedFromActivity() {
        // Implement if needed
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        this.context = binding.getActivity();
        displayManager = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    }

    public class DisplayConnectedStreamHandler implements EventChannel.StreamHandler {
        private DisplayManager displayManager;
        private EventChannel.EventSink sink;
        private Handler handler;

        private DisplayManager.DisplayListener displayListener = new DisplayManager.DisplayListener() {
            @Override
            public void onDisplayAdded(int displayId) {
                if (sink != null) {
                    sink.success(1);
                }
            }

            @Override
            public void onDisplayRemoved(int displayId) {
                if (sink != null) {
                    sink.success(0);
                }
            }

            @Override
            public void onDisplayChanged(int displayId) {}
        };

        public DisplayConnectedStreamHandler(DisplayManager displayManager) {
            this.displayManager = displayManager;
        }

        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            this.sink = events;
            this.handler = new Handler(Looper.getMainLooper());
            displayManager.registerDisplayListener(displayListener, handler);
        }

        @Override
        public void onCancel(Object arguments) {
            this.sink = null;
            this.handler = null;
            displayManager.unregisterDisplayListener(displayListener);
        }
    }





}