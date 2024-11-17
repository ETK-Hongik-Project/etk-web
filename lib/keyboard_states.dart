import 'package:etk_web/main.dart';
import 'package:flutter/cupertino.dart';

import 'widgets/keyboard/keyboard_main_page.dart';

// TODO:
// 1. Handling Undo
// 2. Enum gaze

abstract class KeyboardState {
  String board = "";
  // TODO: 나중에는 int gaze가 아니라, [type] input 으로 변경하는 것이 좋아보임.
  void handleInput(KeyboardMainPageState context, int gaze);
  void undo(KeyboardMainPageState context);
}

// 0 : top, 1 : bottom, 2 : left, 3: right, 4: center
// TODO: Enum타입으로 정의해서, 명확하게 의미 전달할것.
// ex) enum input(top, bottom, left, right, center, undo, enter.....)
// 우선 undo나 기타는 고려하지 않고 구현함. 수정해서 사용.
class S0State implements KeyboardState {
  // NULL
  List<String> prevState = [];

  // Singleton
  static final S0State _instance = S0State._internal();
  S0State._internal();
  factory S0State(String prevState){
    print("State S0: NULL");
    if(prevState != ""){ // for transition
      _instance.prevState.add(prevState);
      return _instance;
    }
    else{ // for undo
      return _instance;
    }
  }

  @override
  String board = "consonant";

  @override
  void handleInput(KeyboardMainPageState context, int gaze) {
    if (gaze == 4) {
      context.incrementIdx();
      context.updateLabels(context.getIdx(), board);
    }  else {
      String text = context.consonantPages[context.getIdx()][gaze];
      context.inputText(text);
      context.changeState(S1State('s0'));
    }
  }

  @override
  void undo(KeyboardMainPageState context) {
    switch (prevState.last) {
      case 's0':
        context.changeState(S0State(""));
        break;
      case 's1':
        context.changeState(S1State(""));
        break;
      case 's2':
        context.changeState(S2State(""));
        break;
      case 's3':
        context.changeState(S3State(""));
        break;
      case 's4':
        context.changeState(S4State(""));
        break;
      case 's5':
        context.changeState(S5State(""));
        break;
      default:
        break;
    }
    prevState.removeLast();
  }

}

// O(초성)
class S1State implements KeyboardState {
  List<String> prevState = [];
  // Singleton
  static final S1State _instance = S1State._internal();
  S1State._internal();
  factory S1State(String prevState){
    print('State: S1(초성)');
    if(prevState != ""){ // for transition
      _instance.prevState.add(prevState);
      return _instance;
    }
    else{ // for undo
      return _instance;
    }
  }

  @override
  String board = "vowel";


  @override
  void handleInput(KeyboardMainPageState context, int gaze) {
    if (gaze == 4) {
      context.incrementIdx();
      context.updateLabels(context.getIdx(), board);
    } else {
      String text = context.vowelPages[context.getIdx()][gaze];
      context.inputText(text);
      context.changeState(S2State('s1'));
    }
  }

  @override
  void undo(KeyboardMainPageState context) {
    switch (prevState.last) {
      case 's0':
        context.changeState(S0State(""));
        break;
      case 's1':
        context.changeState(S1State(""));
        break;
      case 's2':
        context.changeState(S2State(""));
        break;
      case 's3':
        context.changeState(S3State(""));
        break;
      case 's4':
        context.changeState(S4State(""));
        break;
      case 's5':
        context.changeState(S5State(""));
        break;
      default:
        break;
    }
    prevState.removeLast();
  }
}

// *ON(초성 + 중성)
class S2State implements KeyboardState {
  List<String> prevState = [];
  // Singleton
  static final S2State _instance = S2State._internal();
  S2State._internal();
  factory S2State(String prevState){
    print('State: S2(초성+중성)');
    _instance.firstSelect = true;
    _instance.board = 'select';
    if(prevState != ""){ // for transition
      _instance.prevState.add(prevState);
      return _instance;
    }
    else{ // for undo
      return _instance;
    }
  }

  @override
  String board = 'select';

  bool firstSelect = true;
  @override
  void handleInput(KeyboardMainPageState context, int gaze) {
    if (firstSelect) {
      if (gaze == 0) {
        // top(consonant)
        board = 'consonant';
        firstSelect = !firstSelect;
        context.updateLabels(0, board);
      } else if (gaze == 1) {
        // bottom(vowel)
        board = 'vowel';
        firstSelect = !firstSelect;
        context.updateLabels(0, board);
      } // do nothing in center
    } else {
      if (gaze == 4) {
        context.incrementIdx();
        context.updateLabels(context.getIdx(), board);
      } else {
        String text = (board == 'consonant')
            ? context.consonantPages[context.getIdx()][gaze]
            : context.vowelPages[context.getIdx()][gaze];
        context.inputText(text);
        (board == 'consonant')
            ? context.changeState(S4State('s2'))
            : context.changeState(S3State('s2'));
      }
    }
  }

  @override
  void undo(KeyboardMainPageState context) {
    // if(firstSelect == false){
    //   context.changeState(S2State(''));
    //   return;
    // }
    switch (prevState.last) {
      case 's0':
        context.changeState(S0State(""));
        break;
      case 's1':
        context.changeState(S1State(""));
        break;
      case 's2':
        context.changeState(S2State(""));
        break;
      case 's3':
        context.changeState(S3State(""));
        break;
      case 's4':
        context.changeState(S4State(""));
        break;
      case 's5':
        context.changeState(S5State(""));
        break;
      default:
        break;
    }
    prevState.removeLast();
  }
}

// ONN(초성 + 중성 + 중성); 이중모음
class S3State implements KeyboardState {
  List<String> prevState = [];
  // Singleton
  static final S3State _instance = S3State._internal();
  S3State._internal();
  factory S3State(String prevState){
    print('State: S3(초성 + 중성 + 중성)');
    if(prevState != ""){ // for transition
      _instance.prevState.add(prevState);
      return _instance;
    }
    else{ // for undo
      return _instance;
    }
  }

  @override
  String board = 'consonant';

  @override
  void handleInput(KeyboardMainPageState context, int gaze) {
    if (gaze == 4) {
      context.incrementIdx();
      context.updateLabels(context.getIdx(), board);
    } else {
      String text = context.consonantPages[context.getIdx()][gaze];
      context.inputText(text);
      context.changeState(S5State('s3'));
    }
  }

  @override
  void undo(KeyboardMainPageState context) {
    switch (prevState.last) {
      case 's0':
        context.changeState(S0State(""));
        break;
      case 's1':
        context.changeState(S1State(""));
        break;
      case 's2':
        context.changeState(S2State(""));
        break;
      case 's3':
        context.changeState(S3State(""));
        break;
      case 's4':
        context.changeState(S4State(""));
        break;
      case 's5':
        context.changeState(S5State(""));
        break;
      default:
        break;
    }
    prevState.removeLast();
  }
}

// *ONC(초성 + 중성 + 종성)
class S4State implements KeyboardState {
  List<String> prevState = [];
  // Singleton
  static final S4State _instance = S4State._internal();
  S4State._internal();
  factory S4State(String prevState){
    print('State: S4(초성 + 중성 + 종성)');
    _instance.firstSelect = true;
    _instance.board = 'select';
    if(prevState != ""){ // for transition
      _instance.prevState.add(prevState);
      return _instance;
    }
    else{ // for undo
      return _instance;
    }
  }

  @override
  String board = 'select';

  bool firstSelect = true;
  @override
  void handleInput(KeyboardMainPageState context, int gaze) {
    if (firstSelect) {
      if (gaze == 0) {
        // top(consonant)
        board = 'consonant';
        firstSelect = !firstSelect;
      } else if (gaze == 1) {
        // bottom(vowel)
        board = 'vowel';
        firstSelect = !firstSelect;
      } // do nothing in center
      context.updateLabels(0, board);
    } else {
      if (gaze == 4) {
        context.incrementIdx();
        context.updateLabels(context.getIdx(), board);
      } else {
        String text = (board == 'consonant')
            ? context.consonantPages[context.getIdx()][gaze]
            : context.vowelPages[context.getIdx()][gaze];
        context.inputText(text);
        (board == 'consonant')
            ? context.changeState(S1State('s4'))
            : context.changeState(S2State('s4'));
      }
    }
  }

  @override
  void undo(KeyboardMainPageState context) {
    // if(firstSelect == false){
    //   context.changeState(S4State(''));
    //   return;
    // }
    switch (prevState.last) {
      case 's0':
        context.changeState(S0State(""));
        break;
      case 's1':
        context.changeState(S1State(""));
        break;
      case 's2':
        context.changeState(S2State(""));
        break;
      case 's3':
        context.changeState(S3State(""));
        break;
      case 's4':
        context.changeState(S4State(""));
        break;
      case 's5':
        context.changeState(S5State(""));
        break;
      default:
        break;
    }
    prevState.removeLast();
  }
}

// *ONNC(초성 + 중성 + 중성 + 종성); 이중모음
class S5State implements KeyboardState {
  List<String> prevState = [];
  // Singleton
  static final S5State _instance = S5State._internal();
  S5State._internal();
  factory S5State(String prevState){
    print('State: S5(초성 + 중성 + 중성 + 종성)');
    _instance.firstSelect = true;
    _instance.board = 'select';
    if(prevState != ""){ // for transition
      _instance.prevState.add(prevState);
      return _instance;
    }
    else{ // for undo
      return _instance;
    }
  }

  @override
  String board = 'select';

  bool firstSelect = true;
  @override
  void handleInput(KeyboardMainPageState context, int gaze) {
    if (firstSelect) {
      if (gaze == 0) {
        // top(consonant)
        board = 'consonant';
        firstSelect = !firstSelect;
      } else if (gaze == 1) {
        // bottom(vowel)
        board = 'vowel';
        firstSelect = !firstSelect;
      } // do nothing in center
      context.updateLabels(0, board);
    } else {
      if (gaze == 4) {
        context.incrementIdx();
        context.updateLabels(context.getIdx(), board);
      } else {
        String text = (board == 'consonant')
            ? context.consonantPages[context.getIdx()][gaze]
            : context.vowelPages[context.getIdx()][gaze];
        context.inputText(text);
        (board == 'consonant')
            ? context.changeState(S1State('s5'))
            : context.changeState(S2State('s5'));
      }
    }
  }

  @override
  void undo(KeyboardMainPageState context) {
    // if(firstSelect == false){
    //   context.changeState(S5State(''));
    //   return;
    // }
    switch (prevState.last) {
      case 's0':
        context.changeState(S0State(""));
        break;
      case 's1':
        context.changeState(S1State(""));
        break;
      case 's2':
        context.changeState(S2State(""));
        break;
      case 's3':
        context.changeState(S3State(""));
        break;
      case 's4':
        context.changeState(S4State(""));
        break;
      case 's5':
        context.changeState(S5State(""));
        break;
      default:
        break;
    }
    prevState.removeLast();
  }
}
