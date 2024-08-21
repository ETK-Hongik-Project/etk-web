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
import org.pytorch.executorch.EValue;
import org.pytorch.executorch.Module;
import org.pytorch.executorch.Tensor;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class RegressionActivity {
    private FlutterActivity flutterActivity;

    public RegressionActivity(FlutterActivity flutterActivity){
        this.flutterActivity = flutterActivity;
    }

    private void populateBitmap(String file){
        Bitmap bitmap = null;
        try {
            bitmap = BitmapFactory.decodeStream(flutterActivity.getAssets().open(file));
            bitmap = Bitmap.createScaledBitmap(bitmap, 299, 299, true);
        } catch (IOException e) {
            Log.e("Regression", "Error reading assets", e);
            flutterActivity.finish();
        }

        // showing image on UI
//        ImageView imageView = findViewById(R.id.image);
//        imageView.setImageBitmap(bitmap);
    }

    public float[] runModel(String imgPath) {
        Bitmap bitmap = null;
        Module module = null;
        try {
            // TODO: 이미지 가져오고 오픈하고 방법 설정?
            bitmap = BitmapFactory.decodeStream(flutterActivity.getAssets().open("00000.jpg"));
            bitmap = Bitmap.createScaledBitmap(bitmap, 112, 112, true);
            module = Module.load(MainActivity.assetFilePath(this.flutterActivity, "xnnpack_model.pte"));
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

        // getting tensor content as java array of floats
        // coordinate of (x,y)
        // for example if x > 0 && y > 0 --> upleft
        // TODO: 가운데 마진을 정해야겟다
        final float[] scores = outputTensor.getDataAsFloatArray();

        return scores;
    }
}