package com.example.custom;

import android.app.Presentation;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;

public class PresentationDisplay extends Presentation {
    private static final String TAG = "PresentationDisplay";

    private String tag;

    public PresentationDisplay(Context context, String tag, Display display) {
        super(context, display);
        this.tag = tag;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FrameLayout flContainer = new FrameLayout(getContext());
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        );
        flContainer.setLayoutParams(params);

        setContentView(flContainer);

        FlutterView flutterView = new FlutterView(getContext());
        flContainer.addView(flutterView, params);
        FlutterEngine flutterEngine = FlutterEngineCache.getInstance().get(tag);
        if (flutterEngine != null) {
            flutterView.attachToFlutterEngine(flutterEngine);
        } else {
            Log.e(TAG, "Can't find the FlutterEngine with cache name " + tag);
        }
    }
}
