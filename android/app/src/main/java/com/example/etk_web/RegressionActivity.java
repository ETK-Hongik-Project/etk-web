package com.example.etk_web;

import androidx.annotation.NonNull;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import java.io.IOException;
import java.io.File;
import org.pytorch.executorch.EValue;
import org.pytorch.executorch.Module;
import org.pytorch.executorch.Tensor;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class RegressionActivity {
    private FlutterActivity flutterActivity;
    private Module module = null;

    public RegressionActivity(FlutterActivity flutterActivity){
        this.flutterActivity = flutterActivity;
    }

    public void updateModel(String modelPath){
        try {
            Log.d("Model Update", "Model Update With "+modelPath);
            module = Module.load(modelPath);
        } catch (Exception e) {
            Log.e("PytorchHelloWorld", "Error Update Model", e);
            flutterActivity.finish();
        }
    }

    public float[] runModel(String imgPath) {
        Bitmap bitmap = null;
        try {
            // TODO: 이미지 가져오고 오픈하고 방법 설정?
            File imgFile = new File(imgPath);
            bitmap = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
            bitmap = Bitmap.createScaledBitmap(bitmap, 112, 112, true);
            if(module == null) {
                module = Module.load(MainActivity.assetFilePath(this.flutterActivity, "xnnpack_classification_model.pte"));
            }
        } catch (IOException e) {
            Log.e("PytorchHelloWorld", "Error reading assets", e);
            flutterActivity.finish();
        }

        // preparing input tensor
        final Tensor inputTensor =
                TensorImageUtils.bitmapToFloat32Tensor(
                        bitmap,
                        TensorImageUtils.TORCHVISION_NORM_MEAN_RGB,
                        TensorImageUtils.TORCHVISION_NORM_STD_RGB);

        // running the model(회귀 결과)
        final Tensor outputTensor = module.forward(EValue.from(inputTensor))[0].toTensor();

        final float[] scores = outputTensor.getDataAsFloatArray();

        return scores;
    }
}