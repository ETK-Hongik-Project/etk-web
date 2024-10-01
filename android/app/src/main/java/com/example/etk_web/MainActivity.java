package com.example.etk_web;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.GenericArrayType;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity{
    // Flutter에서 열어야 하는 채널 이름
    private static final String CHANNEL = "com.model.prediction/predict";
    private RegressionActivity regressionActivity = null;
    private MethodChannel.MethodCallHandler handler = (call, result) -> {
        if(regressionActivity == null){
            regressionActivity = new RegressionActivity(this);
        }
        if(call.method.equals("runModel")){
            String imagePath = call.argument("imagePath");
            float[] scores = regressionActivity.runModel(imagePath);
            if(scores != null){
                List<Double> resultList = new ArrayList<>();
                for(float score : scores){
                    resultList.add((double) score);
                }
                result.success(resultList);
            } else {
                result.error("UNAVAILABLE", "Model Execution Failed.", null);
            }
        } else if(call.method.equals("updateModel")){
            String modelPath = call.argument("modelPath");
            regressionActivity.updateModel(modelPath);
        } else if(call.method.equals("predict")) {
            byte[] imgBytes = call.argument("imgBytes");
            Map<String, Integer> originSize = call.argument("originSize");
            Map<String, Integer> boundingBox = call.argument("boundingBox");

            int pred = regressionActivity.predict(imgBytes, originSize, boundingBox);
            if(pred != -1){
                result.success(pred);
            } else {
                result.error("UNAVAILABLE", "Model Execution Failed.", null);
            }
        } else {
            result.notImplemented();
        }
    };
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        final MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(handler);
    }

    public static String assetFilePath(FlutterActivity context, String assetName) throws IOException {
        File file = new File(context.getFilesDir(), assetName);
        if (file.exists() && file.length() > 0) {
            return file.getAbsolutePath();
        }

        try (InputStream is = context.getAssets().open(assetName)) {
            try (OutputStream os = new FileOutputStream(file)) {
                byte[] buffer = new byte[4 * 1024];
                int read;
                while ((read = is.read(buffer)) != -1) {
                    os.write(buffer, 0, read);
                }
                os.flush();
            }
            return file.getAbsolutePath();
        }
    }
}