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
import java.nio.FloatBuffer;
import java.sql.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.ListIterator;
import java.util.Map;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.pytorch.executorch.EValue;
import org.pytorch.executorch.Module;
import org.pytorch.executorch.Tensor;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.google.gson.Gson;


public class RegressionActivity {
    private MainActivity mainActivity;
    private Module module = null;

    int faceWidth = 112;
    int faceHeight = 112;

    Map<String, Objects> jsonMap = new HashMap<>();
    // TODO: FileName도 보내야할텐데.. 파일 이름의 유일성이 보장되나? 우선 파일 이름은 보류
    List<String> fileNames = new ArrayList<>();
    List<List<Integer>> boundingBoxes = new ArrayList<>();
    List<List<Integer>> labelFaceGrids = new ArrayList<>();

    public RegressionActivity(MainActivity mainActivity){
        this.mainActivity = mainActivity;
        try {
            module = Module.load(this.mainActivity.assetFilePath(this.mainActivity, "xnnpack_classification_model.pte"));
        } catch (IOException e) {
            Log.e("PytorchModuleException", "NonExist Module", e);
        }
    }

    public void updateModel(String modelPath){
        try {
            Log.d("Model Update", "Model Update With "+modelPath);
            module = Module.load(modelPath);
        } catch (Exception e) {
            Log.e("PytorchHelloWorld", "Error Update Model", e);
            mainActivity.finish();
        }
    }

    public float[] runModel(String imgPath) {
        Bitmap bitmap = null;
        File imgFile = new File(imgPath);
        bitmap = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
        bitmap = Bitmap.createScaledBitmap(bitmap, faceWidth, faceHeight, true);


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

    public int predict(byte[] faceImgBytes, Map<String, Integer> originSize, Map<String, Integer> boundingBox){

        Bitmap bitmap = BitmapFactory.decodeByteArray(faceImgBytes, 0, faceImgBytes.length);
        bitmap = Bitmap.createScaledBitmap(bitmap, faceWidth, faceHeight, true);
        Tensor inputTensor = processImage(bitmap, originSize, boundingBox);
        Tensor outputTensor = module.forward(EValue.from(inputTensor))[0].toTensor();
        final float[] scores = outputTensor.getDataAsFloatArray();
        return argmax(scores);
    }

    private int argmax(float[] array) {
        int maxIndex = 0;
        float maxValue = array[0];

        for (int i = 1; i < array.length; i++) {
            if (array[i] > maxValue) {
                maxValue = array[i];
                maxIndex = i;
            }
        }
        return maxIndex;
    }

    private Tensor processImage(Bitmap bitmapImg, Map<String, Integer> originSize, Map<String, Integer> boundingBox){
        // create labelFaceGrid
        // 원본 이미지 크기와 바운딩 박스 정보 추출
        int frameW = originSize.get("width");
        int frameH = originSize.get("height");
        int labelFaceX = boundingBox.get("x");
        int labelFaceY = boundingBox.get("y");
        int labelFaceW = boundingBox.get("width");
        int labelFaceH = boundingBox.get("height");

        boundingBoxes.add(Arrays.asList(labelFaceX, labelFaceY, labelFaceW, labelFaceH));

        // Label Face Grid 생성
        int gridW = 25; // 예시 그리드 크기 설정
        int gridH = 25; // 예시 그리드 크기 설정
        int[] labelFaceGrid = createLabelFaceGrid(frameW, frameH, gridW, gridH, labelFaceX, labelFaceY, labelFaceW, labelFaceH);
        List<Integer> tmpGrid = new ArrayList<>();
        for(int g: labelFaceGrid){
            tmpGrid.add(g);
        }
        labelFaceGrids.add(tmpGrid);

        // Grid Info 생성 (Row, Column 정보 생성)
        int imgWidth = bitmapImg.getWidth();
        int imgHeight = bitmapImg.getHeight();
        float[][] gridInfo = createGrid(labelFaceGrid, imgWidth, imgHeight);

        // Grayscale 이미지로 변환
        float[] noramlizedGray = toNormalizedGrayscale(bitmapImg);
        float[] gridX = gridInfo[0];
        float[] gridY = gridInfo[1];

        // Grayscale 이미지와 Grid Info 결합하여 최종 Tensor 생성
        Tensor finalTensor = createTensor(noramlizedGray, gridX, gridY, faceWidth*faceHeight, new long[] {1, 3, 112, 112});

        return finalTensor;

    }

    private int[] createLabelFaceGrid(int frameW, int frameH, int gridW, int gridH,
                                        int labelFaceX, int labelFaceY, int labelFaceW, int labelFaceH) {
        float scaleX = (float) gridW / frameW;
        float scaleY = (float) gridH / frameH;

        // Grid 정보를 담을 배열 초기화 (단일 샘플)
        int[] labelFaceGrid = new int[4];

        // 바운딩 박스를 그리드 좌표로 변환
        labelFaceGrid[0] = Math.round(labelFaceX * scaleX);
        labelFaceGrid[1] = Math.round(labelFaceY * scaleY);
        labelFaceGrid[2] = Math.round(labelFaceW * scaleX);
        labelFaceGrid[3] = Math.round(labelFaceH * scaleY);

        return labelFaceGrid;
    }

    // Grid Info 생성 (Python create_grid 함수 변환)
    private float[][] createGrid(int[] labelFaceGrid, int faceImgWidth, int faceImgHeight) {
        float xStart = labelFaceGrid[0] * 2 / 25f - 1;
        float xEnd = (labelFaceGrid[0] + labelFaceGrid[2]) * 2 / 25f - 1;
        float yStart = labelFaceGrid[1] * 2 / 25f - 1;
        float yEnd = (labelFaceGrid[1] + labelFaceGrid[3]) * 2 / 25f - 1;

        float[] linx = linspace(xStart, xEnd, faceImgWidth);
        float[] liny = linspace(yStart, yEnd, faceImgHeight);

        float[][] grid = new float[2][];
        grid[0] = new float[faceImgHeight * faceImgWidth];
        grid[1] = new float[faceImgHeight * faceImgWidth];

        for (int y = 0; y < faceImgHeight; y++) {
            for (int x = 0; x < faceImgWidth; x++) {
                grid[0][y * faceImgWidth + x] = linx[x];
                grid[1][y * faceImgWidth + x] = liny[y];
            }
        }

        return grid;
    }

    private float[] linspace(float start, float end, int num) {
        float[] result = new float[num];
        float step = (end - start) / (num - 1);

        for (int i = 0; i < num; i++) {
            result[i] = start + i * step;
        }

        return result;
    }

    private float[] toNormalizedGrayscale(Bitmap src) {
        Bitmap grayscaleBitmap = Bitmap.createBitmap(src.getWidth(), src.getHeight(), Bitmap.Config.ARGB_8888);
        int imgHeight = src.getHeight();
        int imgWidth = src.getWidth();
        float[] grayscale = new float[imgWidth*imgHeight];

        for (int y = 0; y < imgHeight; y++) {
            for (int x = 0; x < imgWidth; x++) {
                int pixel = src.getPixel(x, y);
                int red = (pixel >> 16) & 0xFF;
                int green = (pixel >> 8) & 0xFF;
                int blue = pixel & 0xFF;
                int gray = (red + green + blue) / 3;

                grayscale[y * imgWidth + x] = gray * 0.08f - 1;
            }
        }

        return grayscale;
    }

    private Tensor createTensor(float[] normalziedGray, float[] gridX, float[] gridY, int numPixels, long[] shape){
        int offsetGridX = numPixels;
        int offsetGridY = 2*numPixels;

        FloatBuffer outBuffer = Tensor.allocateFloatBuffer(3 * numPixels);
        for (int i = 0; i < numPixels; i++) {
            outBuffer.put(i, normalziedGray[i]);
            outBuffer.put(offsetGridX + i, gridX[i]);
            outBuffer.put(offsetGridY + i, gridY[i]);
        }

        return Tensor.fromBlob(outBuffer, shape);
    }

//    public String toJson(){
//        // FIXME: ArrayList<List<Integer>>는 Object가 아닌겨?
//        jsonMap.put("boundingBox", boundingBoxes);
//        jsonMap.put("labelFaceGrid", labelFaceGrids);
//        Gson gson = new Gson();
//        String jsonString = gson.toJson(jsonMap);
//
//        return jsonString;
//    }
}