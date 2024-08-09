class Korean {
  List<String> chosung = [
    "ㄱ",
    "ㄲ",
    "ㄴ",
    "ㄷ",
    "ㄸ",
    "ㄹ",
    "ㅁ",
    "ㅂ",
    "ㅃ",
    "ㅅ",
    "ㅆ",
    "ㅇ",
    "ㅈ",
    "ㅉ",
    "ㅊ",
    "ㅋ",
    "ㅌ",
    "ㅍ",
    "ㅎ"
  ];
  List<String> jungsung = [
    "ㅏ",
    "ㅐ",
    "ㅑ",
    "ㅒ",
    "ㅓ",
    "ㅔ",
    "ㅕ",
    "ㅖ",
    "ㅗ",
    "ㅘ",
    "ㅙ",
    "ㅚ",
    "ㅛ",
    "ㅜ",
    "ㅝ",
    "ㅞ",
    "ㅟ",
    "ㅠ",
    "ㅡ",
    "ㅢ",
    "ㅣ"
  ];
  List<String> jongsung = [
    "",
    "ㄱ",
    "ㄲ",
    "ㄳ",
    "ㄴ",
    "ㄵ",
    "ㄶ",
    "ㄷ",
    "ㄹ",
    "ㄺ",
    "ㄻ",
    "ㄼ",
    "ㄽ",
    "ㄾ",
    "ㄿ",
    "ㅀ",
    "ㅁ",
    "ㅂ",
    "ㅄ",
    "ㅅ",
    "ㅆ",
    "ㅇ",
    "ㅈ",
    "ㅊ",
    "ㅋ",
    "ㅌ",
    "ㅍ",
    "ㅎ"
  ];
  List<String> firstJungsung = ['ㅗ', 'ㅜ', 'ㅡ'];
  List<List<String>> secondJungsung = [
    ['ㅏ', 'ㅐ', 'ㅣ'],
    ['ㅓ', 'ㅔ', 'ㅣ'],
    ['ㅣ']
  ];
  List<String> firstJongsung = ["ㄱ", "ㄴ", 'ㄹ', 'ㅂ'];
  List<List<String>> secondJongsung = [
    ["ㅅ"],
    ["ㅈ", "ㅎ"],
    ["ㄱ", "ㅁ", 'ㅂ', 'ㅅ', 'ㅌ', 'ㅍ', 'ㅎ'],
    ['ㅅ']
  ];

  bool jungsungTest(String a, String b) {
    if (firstJungsung.contains(a)) {
      return secondJungsung[firstJungsung.indexOf(a)].contains(b);
    } else {
      return jungsung.contains(b);
    }
  }

  String hangeulJoin(List<String> inputList) {
    String result = "";
    int cho = 0, jung = 0, jong = 0;
    inputList.insert(0, "");

    while (inputList.length > 1) {
      if (jongsung.contains(inputList.last)) {
        if (firstJongsung.contains(inputList[inputList.length - 2])) {
          if (secondJongsung[
                      firstJongsung.indexOf(inputList[inputList.length - 2])]
                  .contains(inputList.last) &&
              jungsungTest(inputList[inputList.length - 4],
                  inputList[inputList.length - 3])) {
            jong = secondJongsung[firstJongsung.indexOf(inputList.removeLast())]
                    .indexOf(inputList.removeLast()) +
                jongsung.indexOf(inputList.removeLast()) +
                1;
          } else {
            result += inputList.removeLast();
          }
        } else if (jongsung.contains(inputList[inputList.length - 2])) {
          result += inputList.removeLast();
        } else {
          jong = jongsung.indexOf(inputList.removeLast());
        }
      } else if (jungsung.contains(inputList.last)) {
        if (firstJungsung.contains(inputList[inputList.length - 2])) {
          if (secondJungsung[
                  firstJungsung.indexOf(inputList[inputList.length - 2])]
              .contains(inputList.last)) {
                int testValue = firstJungsung.indexOf(inputList.removeLast());
            jung = secondJungsung[firstJungsung.indexOf(inputList.removeLast())]
                    .indexOf(inputList.removeLast()) +
                jungsung.indexOf(inputList.removeLast()) +
                1;
          } else {
            result += inputList.removeLast();
          }
        }
        if (chosung.contains(inputList[inputList.length - 2])) {
          if (jung == 0) {
            jung = jungsung.indexOf(inputList.removeLast());
          }
          cho = chosung.indexOf(inputList.removeLast());
          result +=
              String.fromCharCode(0xAC00 + ((cho * 21) + jung) * 28 + jong);
          cho = 0;
          jung = 0;
          jong = 0;
        } else {
          result += inputList.removeLast();
        }
      } else {
        result += inputList.removeLast();
      }
    }

    return result.split('').reversed.join('');
  }

  // String moasseugi(List<String> inputText) {
  //   List<String> t1 = [];
  //   for (var i in inputText) {
  //     t1.add(i);
  //   }
  //   return hangeulJoin(t1);
  // }

  String moasseugi(String input) {
    List<String> inputText = input.split('');

    List<String> t1 = [];
    for (var i in inputText) {
      t1.add(i);
    }
    return hangeulJoin(t1);
  }
}
