import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class RegressionModel{
    static const platform =  MethodChannel('com.model.prediction/predict');

    Future<List<double>> runModel(String imgPath) async {
        try{
            final List<Object?> result = await platform.invokeMethod("runModel", {"imagePath": imgPath});
            if(result != null)
                return result.cast<double>();
            else
                throw Exception('Unexpected result type: ${result.runtimeType}');
        } on PlatformException catch(e){
            print("Failed to run Model: '${e.message}'.");
            return [];
        }
    }
}