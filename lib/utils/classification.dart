import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ClassificationModel{
    static const platform =  MethodChannel('com.model.prediction/predict');

    int argmax(List<double> values){
        if(values.isEmpty){
            throw Exception("List is Empty");
        }
        double maxValue = values[0];
        int maxIdx = 0;

        for(int i = 1; i < values.length; ++i){
            if(values[i] > maxValue){
                maxValue = values[i];
                maxIdx = i;
            }
        }

        return maxIdx;
    }

    Future<int> runModel(String imgPath) async {
        try{
            final List<Object?> result = await platform.invokeMethod("runModel", {"imagePath": imgPath});
            if(result != null)
                return argmax(result.cast<double>());
            else
                throw Exception('Unexpected result type: ${result.runtimeType}');
        } on PlatformException catch(e){
            print("Failed to run Model: '${e.message}'.");
            return -1;
        }
    }
}