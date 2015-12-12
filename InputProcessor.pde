class InputProcessor {
  
  float DOT_TIME = 0.25f, DASH_TIME = 0.5f, PAUSE_TIME = 0.5f;

  // input states
  int WAITING_TO_START = 0, WAITING_FOR_KEY_UP = 1, WAITING_FOR_KEY_DOWN = 2;

  // input types
  int DOT = 0, DASH = 1;
  
  char _keyToProcess;
  ArrayList<Integer> _inputWord;
    
  ArrayList<ArrayList<Integer>> _processedWords;
  
  Integer _inputState;
  float _stateTimer;
  
  boolean _keyDown;
  
  InputProcessor (char keyToProcess) {
    _keyToProcess = keyToProcess;
    _inputWord = new ArrayList<Integer>();
    _processedWords = new ArrayList<ArrayList<Integer>>();
    _lastDown = _LastUp = 0;
    _inputState = WAITING_TO_START;
    _stateTimer = 0;
    _keyDown = false;
  }
  
  void keyPressed() {
    if(key == _keyToProcess) {
      _keyDown = true;
    }
  }
  
  void keyReleased() {
    if(key == _keyToProcess) {
      _keyDown = false;
    }
  }
  
  void update (float deltaTime) {
    if (_inputState == WAITING_TO_START) {
      if (_keyDown) {
        _inputState = WAITING_FOR_KEY_UP;
        _stateTimer = 0;
        _inputWord.clear();
      }
    } else if (_inputState == WAITING_FOR_KEY_UP) {
      if (!_keyDown) {
        if (_stateTimer <= DOT_TIME) {
         console.log("state timer " + _stateTimer + " DOT "  + DOT_TIME);
          _inputState = WAITING_FOR_KEY_DOWN;
          _stateTimer = 0;
          _inputWord.add(DOT);
        } else if (_stateTimer <= DASH_TIME) {
         console.log("state timer " + _stateTimer + " DASH "  + DASH_TIME);
          _inputState = WAITING_FOR_KEY_DOWN;
          _stateTimer = 0;
          _inputWord.add(DASH);
        }
      } else {
        _stateTimer += deltaTime; 
        /*if (_stateTimer > DASH_TIME){ // if held too long will reset input sequence
          _inputState = WAITING_TO_START;
          _stateTimer = 0;
        }*/
      }
    } else if (_inputState == WAITING_FOR_KEY_DOWN) {
      if(_keyDown) {        
        _inputState = WAITING_FOR_KEY_UP;
        _stateTimer = 0;
      } else {
        _stateTimer += deltaTime; 
        if (_stateTimer > PAUSE_TIME){ // pausing for long time will end sequence
          _processedWords.add(new ArrayList<Integer>(_inputWord));
          _inputState = WAITING_TO_START;
          _stateTimer = 0;
        }
      }
    } else {
      // INVALID STATE!!!
    }
  }
  
  ArrayList<Integer> getCurrentWord() {
    return _inputWord;
  }
  
  ArrayList<Integer> getNextWord() {
    if(_processedWords.size() > 0) {
      return _processedWords.remove(0);
    } else {
      return null;
    }
  }
}
