/* @pjs preload="/LD34/assets/enemy7.png, /LD34/assets/mirror.png, /LD34/assets/tutorial_boss.png, /LD34/assets/tutorial_text.png, /LD34/assets/poof_strip.png, /LD34/assets/enemy0.png, /LD34/assets/enemy1.png, /LD34/assets/enemy2.png, /LD34/assets/enemy3.png, /LD34/assets/enemy4.png, /LD34/assets/enemy5.png, /LD34/assets/enemy6.png, /LD34/assets/menu_background.png, /LD34/assets/character_spritesheet.png, /LD34/assets/ui.png, /LD34/assets/reflector.png, /LD34/assets/lose_text.png, /LD34/assets/win_text.png, /LD34/assets/p1wins_text.png, /LD34/assets/p2wins_text.png, /LD34/assets/background0.png, /LD34/assets/background1.png, /LD34/assets/background2.png, /LD34/assets/mana_suck.png, /LD34/assets/mana_steal.png, /LD34/assets/zapper.png, /LD34/assets/zap.png, /LD34/assets/shield.png, /LD34/assets/desert_background.png, /LD34/assets/blueFireball.png, /LD34/assets/meteor.png, /LD34/assets/gravityWell.png, /LD34/assets/healthOrb.png, /LD34/assets/manaOrb.png, /LD34/assets/spinningFireball.png, /LD34/assets/piercer.png, /LD34/assets/wind.png, /LD34/assets/spellOrb.png, /LD34/assets/123go.png; */

class Entity {
  // Called when the entity is added to the game
  void create() {}
  // Called when the entity is removed from the game
  void destroy() {}
  // Called whenever the entity is to be rendered
  void render() {}
  // Called when the entity is to be updated
  void update(int phase, float delta) {}
  // The order in the render and update list of the entity
  int depth() {
    return 0;
  }
  boolean exists = false;
}

PImage userInterface;
PImage loseText;
PImage winText;
PImage p1WinsText;
PImage p2WinsText;
PImage menuBackground;
PImage[] backgrounds;

ArrayList<InputProcessor> inputProcessors = new ArrayList<InputProcessor>();

int MENU_STATE = 0, GAME_START_STATE = 1, IN_GAME_STATE = 2, GAME_OVER_STATE = 3;
int state = 0;

ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeAdded = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeRemoved = new ArrayList<Entity>();
ArrayList<Collider> colliders = new ArrayList<Collider>();

int firstUpdatePhase = 0;
int lastUpdatePhase = 0;

int lastUpdate = millis();
float timeDelta;

SpriteSheet spellOrbSpritesheet;
SpriteSheet readySetGoSpritesheet;

Animation dotOrbAnimation;
Animation dashOrbAnimation;

void addEntity(Entity entity) {
  entitiesToBeAdded.add(entity);
}

void removeEntity(Entity entity) {
  entitiesToBeRemoved.add(entity);
}

void sortEntities() {
  for (int i = 1; i < entities.size(); ++i) {
    Entity x = entities.get(i);
    int j = i;
    while (j > 0 && entities.get(j - 1).depth() < x.depth()) {
      entities.set(j, entities.get(j - 1));
      j -= 1;
    }
    entities.set(j, x);
  }
}

Wizard player1;
Wizard player2;

float player1HealthGradual;
float player2HealthGradual;
float player1ManaGradual;
float player2ManaGradual;

int state = STATE_MAIN_MENU;

int STATE_PRE_DUEL = -1, STATE_DUEL = 0, STATE_POST_DUEL = 1, STATE_MAIN_MENU = 2, STATE_PRE_FIGHT = 3, STATE_FIGHT = 4, STATE_POST_FIGHT_LOSE = 5, STATE_POST_FIGHT_WIN = 6;

void cleanState() {
  entities.clear();
  entitiesToBeAdded.clear();
  entitiesToBeRemoved.clear();
  colliders.clear();
  inputProcessors.clear();
}

Wizard getFight(int n) {
  if (n == 0) {
    return new EnemyTutorial(width - 100, 500, true, new InputProcessor('.'));
  }
  n -= 1;
  switch(n % 9) {
    case 0:
    return new EnemyAlien(width - 100, 500, true, new InputProcessor('.'));
    case 1:
    return new EnemyTree(width -100, 500, true, new InputProcessor('.'));
    case 2:
    return new EnemyBlob(width - 100, 500, true, new InputProcessor('.'));
    case 3:
    return new EnemyEgg(width - 100, 500, true, new InputProcessor('.'));
    case 4:
    return new EnemyEyeball(width - 100, 500, true, new InputProcessor('.'));
    case 5:
    return new EnemyMirror(width - 100, 500, true, new InputProcessor('.'));
    case 6:
    return new EnemySquid(width - 100, 500, true, new InputProcessor('.'));
    case 7:
    return new EnemyWizard(width - 100, 500, true, new InputProcessor('.'));
    case 8:
    return new EnemyFly(width - 100, 500, true, new InputProcessor('.'));
  }
}

int currentFight = 0;

float timer = 10.0f;

void gotoMainMenuState() {
  state = STATE_MAIN_MENU;
  lastBackground = backgroundImage;
  while (backgroundImage == lastBackground) {
    backgroundImage = backgrounds[int(random(backgrounds.length))];
  }
}

void gotoPreDuelState() {
  
  readyStage = 0;
  
  state = STATE_PRE_DUEL;
  
  lastBackground = backgroundImage;
  while (backgroundImage == lastBackground) {
    backgroundImage = backgrounds[int(random(backgrounds.length))];
  }
  
  InputProcessor input1 = new InputProcessor('z');
  InputProcessor input2 = new InputProcessor('m');
  
  inputProcessors.add(input1);
  inputProcessors.add(input2);
  
  player1 = new Wizard(100, 500, 50, 100, false, inputProcessors.get(0));
  player2 = new Wizard(width - 100, 500, 50, 100, true, inputProcessors.get(1));
  
  player1HealthGradual = player1._maxHealth;
  player2HealthGradual = player2._maxHealth;
  player1ManaGradual = player1._maxMana;
  player2ManaGradual = player2._maxMana;
  
  addEntity(player1);
  addEntity(player2);
  
  timer = 3.0f;
}

void gotoDuelState() {
  state = STATE_DUEL;
  
  player1._inputProcessor.reset();
  player2._inputProcessor.reset();
  
  player1.preFight = false;
  player2.preFight = false;
}

void gotoPostDuelState() {
  state = STATE_POST_DUEL;
  
  player1.loser = player1._health < 0;
  player1.winner = !player1.loser;
  
  player2.loser = player2._health < 0;
  player2.winner = !player2.loser;
  
  timer = 3.0f;
}

void gotoPreFightState() {
  
  readyStage = 0;
  
  state = STATE_PRE_FIGHT;
  
  lastBackground = backgroundImage;
  while (backgroundImage == lastBackground) {
    backgroundImage = backgrounds[int(random(backgrounds.length))];
  }
  
  InputProcessor input1 = new InputProcessor('z');
  
  inputProcessors.add(input1);
  
  player1 = new Wizard(100, 500, 50, 100, false, inputProcessors.get(0));
  player2 = getFight(currentFight);
  
  player1HealthGradual = player1._maxHealth;
  player2HealthGradual = player2._maxHealth;
  player1ManaGradual = player1._maxMana;
  player2ManaGradual = player2._maxMana;
  
  addEntity(player1);
  addEntity(player2);
  
  timer = 3.0f;
}

void gotoFightState() {
  state = STATE_FIGHT;
  player1._inputProcessor.reset();
  
  player1.preFight = false;
  player2.preFight = false;
}

void gotoPostFightWinState() {
  state = STATE_POST_FIGHT_WIN;
  player1.winner = true;
  player1.loser = false;
  player2.winner = false;
  player2.loser = true;
  timer = 3.0f;
}

void gotoPostFightLoseState() {
  state = STATE_POST_FIGHT_LOSE;
  player1.winner = false;
  player1.loser = true;
  player2.winner = true;
  player2.loser = false;
  timer = 3.0f;
}

PImage backgroundImage;

void setup () {  
  size(1000, 680);
  
  spellOrbSpritesheet = loadSpriteSheet("/LD34/assets/spellOrb.png", 2, 2, 64, 64);  
  dotOrbAnimation = new Animation(spellOrbSpritesheet, 0.25, 2, 3);
  dashOrbAnimation = new Animation(spellOrbSpritesheet, 0.25, 0, 1);
  
  readySetGoSpritesheet = loadSpriteSheet("/LD34/assets/123go.png", 4, 1, 300, 300);  
  
  userInterface = loadImage("/LD34/assets/ui.png");
  backgrounds = new PImage[] {
    loadImage("/LD34/assets/background0.png"),
    loadImage("/LD34/assets/background1.png"),
    loadImage("/LD34/assets/background2.png") };
    
  backgroundImage = backgrounds[int(random(backgrounds.length))];
  menuBackground = loadImage("/LD34/assets/menu_background.png");
  
  loseText = loadImage("/LD34/assets/lose_text.png");
  winText = loadImage("/LD34/assets/win_text.png");
  p1WinsText = loadImage("/LD34/assets/p1wins_text.png");
  p2WinsText = loadImage("/LD34/assets/p2wins_text.png");
  
  loadAudio("fireball", "/LD34/assets/music/fireball2.wav");
  loadAudio("gravityWell", "/LD34/assets/music/gravityWellSFX.ogg");
  loadAudio("meteor", "/LD34/assets/music/meteorSFX.ogg");
  loadAudio("miniFireball", "/LD34/assets/music/miniFireballSFX.ogg");
  loadAudio("reflector", "/LD34/assets/music/reflectorSFX.ogg");
  loadAudio("shieldBreaker", "/LD34/assets/music/shieldBreakerSFX.ogg");
  loadAudio("shieldDeactivate", "/LD34/assets/music/shieldBreakerSFX.ogg");
  loadAudio("shield", "/LD34/assets/music/shieldSFX.ogg");
  loadAudio("hit", "/LD34/assets/music/hit.ogg");
  loadAudio("orb", "/LD34/assets/music/orb.ogg");
  loadAudio("stun", "/LD34/assets/music/stun.ogg");
  loadAudio("phase", "/LD34/assets/music/phase.ogg");
  loadAudio("music", "/LD34/assets/music/LD34.ogg");
  loadAudio("invoke", "/LD34/assets/music/invoke.wav");
  loadAudio("dot_orb", "/LD34/assets/music/dot_orb.wav");
  loadAudio("meteor", "/LD34/assets/music/meteor.wav");
  loadAudio("summonBlackHole", "/LD34/assets/music/summon_black_hole.wav");
  loadAudio("blackHole", "/LD34/assets/music/black_hole.wav");
  loadAudio("poof", "/LD34/assets/music/poof.wav");
  loadAudio("manaSteal0", "/LD34/assets/music/mana_steal_0.wav");
  loadAudio("manaSteal1", "/LD34/assets/music/mana_steal.wav");
  loadAudio("zappyShoot", "/LD34/assets/music/zappy_shoot.wav");
  loadAudio("piercer", "/LD34/assets/music/piercer.wav");
  loadAudio("rapidFire", "/LD34/assets/music/rapid_fire.wav");
  sounds["music"].loop = true;
  //sounds["music"].play();
  
  gotoMainMenuState();
}

float clamp(float min, float value, float max) {
  if (value < min) {
    return min;
  }
  else if (value > max) {
    return max;
  }
  else {
    return value;
  }
}

int readyStage = 0;

void draw () {
  
  if (audioFilesLoaded != nAudioFiles) {
    text("Loading", 64, 64);
  }
  
  if (state != STATE_MAIN_MENU) {
    image(backgroundImage, 0, 0);
  }
  else {
    image(menuBackground, 0, 0);
  }
  
  int now = millis();
  timeDelta = (now - lastUpdate) / 1000.0f;
  lastUpdate = now;

  dotOrbAnimation.update(timeDelta);
  dashOrbAnimation.update(timeDelta);

  for(InputProcessor ip : inputProcessors) {     
    ip.update(timeDelta);
  }
  
  for (Entity entity : entitiesToBeAdded) {
    entities.add(entity);
    if (entity instanceof Collider) {
      colliders.add(entity);
    }
    entity.exists = true;
    entity.create();
  }
  entitiesToBeAdded.clear();
  // Remove entities in the remove queue
  for (Entity entity : entitiesToBeRemoved) {
    entities.remove(entity);
    if (entity instanceof Collider) {
      colliders.remove(entity);
    }
    entity.exists = false;
    entity.destroy();
  }
  entitiesToBeRemoved.clear();
  // Entities are sorted by depth
  sortEntities();
  for (int updatePhase = firstUpdatePhase; updatePhase <= lastUpdatePhase; ++updatePhase) {
    // Update every entity
    for (Entity entity : entities) {
      entity.update(updatePhase, timeDelta);
    }
    // Find and handle collisions
    if (updatePhase == 0) {
      for (int i = 0; i < colliders.size() - 1; ++i) {
        Collider first = colliders.get(i);
        for (int j = i + 1; j < colliders.size(); ++j) {
          Collider second = colliders.get(j);
          if (first.collides(second)) {
            first.onCollision(second, false);
            second.onCollision(first, true);
          }
        }
      }
    }
  }
  // Render every entity
  for (Entity entity : entities) {
    entity.render();
  }
  
  timer -= timeDelta;
  
  if (timer < 0.0f) {
    if (state == STATE_PRE_DUEL) {
      gotoDuelState();
    }
    else if (state == STATE_POST_DUEL) {
      cleanState();
      gotoMainMenuState();
    }
    else if (state == STATE_PRE_FIGHT) {
      gotoFightState();
    }
    else if (state == STATE_POST_FIGHT_WIN) {
      cleanState();
      currentFight += 1;
      gotoPreFightState();
    }
    else if (state == STATE_POST_FIGHT_LOSE) {
      cleanState();
      gotoMainMenuState();
    }
  }
  
  if (state == STATE_MAIN_MENU) {
  }
  else if ((state == STATE_PRE_DUEL || state == STATE_PRE_FIGHT) && !(player2 instanceof EnemyTutorial)) {
    if (timer >= 2.25) {
      //text("3", 50, 50);
      if (readyStage == 0) {
        readyStage = 1;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(0, width / 2 - 150, height / 2 - 150, 300, 300);
    }
    else if (timer >= 1.5) {
      //text("2", 50, 50);
      if (readyStage == 1) {
        readyStage = 2;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(1, width / 2 - 150, height / 2 - 150, 300, 300);
    }
    else if (timer >= 0.75) {
      //text("1", 50, 50);
      if (readyStage == 2) {
        readyStage = 3;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(2, width / 2 - 150, height / 2 - 150, 300, 300);
    }
    else {
      //text("Fight!", 50, 50);
      if (readyStage == 3) {
        readyStage = 4;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(3, width / 2 - 150, height / 2 - 150, 300, 300);
    }
  }
  else if (state == STATE_POST_FIGHT_LOSE) {
    image(loseText, (width - loseText.width) / 2, (height - loseText.height) / 2);
  }
  else if (state == STATE_POST_FIGHT_WIN) {
    image(winText, (width - winText.width) / 2, (height - winText.height) / 2);
  }
  else if (state == STATE_POST_DUEL) {
    if (player1.winner) {
      image(p1WinsText, (width - p1WinsText.width) / 2, (height - p1WinsText.height) / 2);
    }
    else if (player2.winner) {
      image(p2WinsText, (width - p2WinsText.width) / 2, (height - p2WinsText.height) / 2);
    }
    else {
      
    }
  }
  /*
  draw the ui
  */
  if (state == STATE_DUEL || state == STATE_FIGHT || state == STATE_PRE_DUEL || state == STATE_PRE_FIGHT || state == STATE_POST_DUEL || state == STATE_POST_FIGHT_WIN || state == STATE_POST_FIGHT_LOSE) {
    
    noStroke();
    
    float player1HealthPercent;
    float player1ManaPercent;
    float player2HealthPercent;
    float player2ManaPercent;
    
    if (player1HealthGradual > player1._health) {
      player1HealthGradual -= 10 * timeDelta;
    }
    if (player1HealthGradual < player1._health) {
      player1HealthGradual = player1._health;
    }
    
    if (player2HealthGradual > player2._health) {
      player2HealthGradual -= 10 * timeDelta;
    }
    if (player2HealthGradual < player2._health) {
      player2HealthGradual = player2._health;
    }
    
    if (player1ManaGradual > player1._mana) {
      player1ManaGradual -= 10 * timeDelta;
    }
    if (player1ManaGradual < player1._mana) {
      player1ManaGradual = player1._mana;
    }
    
    if (player2ManaGradual > player2._mana) {
      player2ManaGradual -= 10 * timeDelta;
    }
    if (player2ManaGradual < player2._mana) {
      player2ManaGradual = player2._mana;
    }
    
    if ((state == STATE_PRE_FIGHT || state == STATE_PRE_DUEL) && !(player2 instanceof EnemyTutorial)) {
      player1HealthPercent = player1ManaPercent = player2HealthPercent = player2ManaPercent = 1.0f - timer / 3.0f;
      player1HealthGradualPercent = player1ManaGradualPercent = player2HealthGradualPercent = player2ManaGradualPercent = 0.0f;
    }
    else {
      player1HealthPercent = clamp(0.0f, player1._health / player1._maxHealth, 1.0f);
      player1ManaPercent = clamp(0.0f, player1._mana / player1._maxMana, 1.0f);
      player2HealthPercent = clamp(0.0f, player2._health / player2._maxHealth, 1.0f);
      player2ManaPercent = clamp(0.0f, player2._mana / player2._maxMana, 1.0f);
      
      player1HealthGradualPercent = clamp(0.0f, player1HealthGradual / player1._maxHealth, 1.0f);
      player1ManaGradualPercent = clamp(0.0f, player1ManaGradual / player1._maxMana, 1.0f);
      player2HealthGradualPercent = clamp(0.0f, player2HealthGradual / player2._maxHealth, 1.0f);
      player2ManaGradualPercent = clamp(0.0f, player2ManaGradual / player2._maxMana, 1.0f);
    }
    
    fill(100, 100, 100);
    rect(0, 0, width, 4 + 64 + 32 + 4);
    
    fill(220, 120, 40);
    rect(32 + 4, 4, (width / 2 - 32 - 4 - 4) * player1HealthGradualPercent, 64);
    rect(width / 2 + 4, 4, (width / 2 - 32 - 4 - 4) * player2HealthGradualPercent, 64);
    
    fill(40, 160, 220);
    rect(32 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player1ManaGradualPercent, 32);
    rect(width / 2 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player2ManaGradualPercent, 32);
    
    fill(220, 40, 40);
    rect(32 + 4, 4, (width / 2 - 32 - 4 - 4) * player1HealthPercent, 64);
    rect(width / 2 + 4, 4, (width / 2 - 32 - 4 - 4) * player2HealthPercent, 64);
    
    fill(70, 40, 220);
    rect(32 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player1ManaPercent, 32);
    rect(width / 2 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player2ManaPercent, 32);
    
    image(userInterface, 0, 0);
    
    ArrayList<Integer> player1Word = new ArrayList<Integer>(player1._inputProcessor.getCurrentWord());
    ArrayList<Integer> player2Word = new ArrayList<Integer>(player2._inputProcessor.getCurrentWord());
    
    int currentX = 40;
    if (player1._inputProcessor._inputState == player1._inputProcessor.WAITING_FOR_KEY_UP || player1._inputProcessor._inputState == player1._inputProcessor.WAITING_FOR_KEY_DOWN) {
      if (player1._inputProcessor._inputState == player1._inputProcessor.WAITING_FOR_KEY_UP) {
        if (player1._inputProcessor._stateTimer <= player1._inputProcessor.DOT_TIME) {
          player1Word.add(0);
        }
        else if (player1._inputProcessor._stateTimer <= player1._inputProcessor.DASH_TIME) {
          player1Word.add(1);
        }
      }
      for (Integer letter : player1Word) {
        float x = currentX, y = height - 70;
        float size = 64;
        if (letter == 0) {
          fill(0, 255, 0);
          dotOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        else if (letter == 1) {
          fill(255, 0, 0);
          dashOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        currentX += 80;
      }
    }
    
    if (player2._inputProcessor._inputState == player2._inputProcessor.WAITING_FOR_KEY_UP || player2._inputProcessor._inputState == player2._inputProcessor.WAITING_FOR_KEY_DOWN) {
      if (player2._inputProcessor._inputState == player2._inputProcessor.WAITING_FOR_KEY_UP) {
        if (player2._inputProcessor._stateTimer <= player2._inputProcessor.DOT_TIME) {
          player2Word.add(0);
        }
        else if (player2._inputProcessor._stateTimer <= player2._inputProcessor.DASH_TIME) {
          player2Word.add(1);
        }
      }
      currentX = width - 40 - (player2Word.size() - 1) * 80;
      for (Integer letter : player2Word) {
        float x = currentX, y = height - 70;
        float size = 64;
        if (letter == 0) {
          fill(0, 255, 0);
          dotOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        else if (letter == 1) {
          fill(255, 0, 0);
          dashOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        currentX += 80;
      }
      
    }
    
    if (state == STATE_DUEL) {
      if (player1._health < 0 || player2._health < 0) {
        gotoPostDuelState();
      }
    }
    else if (state == STATE_FIGHT) {
      if (player1._health < 0) {
        gotoPostFightLoseState();
      }
      else if (player2._health < 0) {
        gotoPostFightWinState();
      }
    }
  
  }
  
}

void keyPressed() {
  if (state == STATE_DUEL || state == STATE_FIGHT) {
    for(InputProcessor ip : inputProcessors) {     
      ip.keyPressed();
    }
    if (key == 'q' && state == STATE_FIGHT) {
      player2._health = -10;
    }
  }
  if (state == STATE_MAIN_MENU) {
    if (key == 'm') {
      playSound("hit");
      cleanState();
      gotoPreDuelState();
    }
    else if (key == 'z') {
      playSound("hit");
      cleanState();
      gotoPreFightState();
    }
  }
}

void keyReleased() {
  if (state == STATE_DUEL || state == STATE_FIGHT) {
    for(InputProcessor ip : inputProcessors) {     
      ip.keyReleased();
    }
    if (key == 'm') {
      if (player2 instanceof EnemyTutorial) {
        if (player2.phase <= 1 || player2.phase >= 7) {
          playSound("hit");
          player2.phase += 1;
          if (player2.phase > 8) {
            player2.phase = 8;
          }
        }
      }
    }
  }
}

void mousePressed() {
}

void mouseReleased() {
}

void mouseDragged() {
}
// How to load an audio file:
//
//  loadAudio("gameMusic1", "assets/music1.ogg");
//
// When the audio file is loaded, 'audioFilesLoaded' is incremented by 1
//
//  if(audioFilesLoaded == 1) {
//    text("One audio file is loaded!");
//  }
//
// How to play the loaded audio file:
//
//  playSound("gameMusic1");
//
// Powered by javascript!
//

// Number of audio files loaded
var audioFilesLoaded = 0;
var nAudioFiles = 0;

// A map of all the audio files that have been loaded
var sounds = new Object();

// Play an audio file from the key 'name'
function playSound(var name)
{
    sounds[name].play();
}

// Load an audio file
// 'name' is the key to retrieve the audio object from 'sounds'
// 'uri' is the path to the file
function loadAudio(var name, var uri)
{
    var audio = new Audio();
    sounds[name] = audio;
    audio.addEventListener("canplaythrough", audioFileLoaded, false); // It works!!
    audio.src = uri;
    nAudioFiles++;
    return audio;
}

// This function will be called when an audio file is loaded
function audioFileLoaded()
{
    audioFilesLoaded++;
}
class Collider extends Moving {
  
  Collider(float x_, float y_, float radius_, float friction_) {
    super(x_, y_, friction_);
    radius = radius_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {}
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
  }
  
  int depth() {
    return 0;
  }
  
  boolean collides(Collider other) {
    float deltaX = x - other.x;
    float deltaY = y - other.y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    float totalRadius = radius + other.radius;
    return distanceSqr <= totalRadius * totalRadius;
  }
  
  boolean intersects(float pointX, float pointY) {
    float deltaX = pointX - x;
    float deltaY = pointY - y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    return distanceSqr <= radius * radius;
  }
  
  float radius;
}
class EnemyAlien extends Wizard {
  
  EnemyAlien(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyAlienSpritesheet == null) {
      enemyAlienSpritesheet = loadSpriteSheet("/LD34/assets/enemy4.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyAlienSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyAlienSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    fireballSpell = new FireballSpell();
    rapidShotSpell = new RapidShotSpell();
    shieldSpell = new ShieldSpell();
    MANA_REGEN_RATE = 3.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    if (lastSpellTime > 6.5) {
      lastSpellTime = 0;
      int d6 = floor(random(7));
      
      if (d6 == 1 || d6 == 2 || d6 == 3) {
        if (fireballSpell.getManaCost() < this._mana) {
          fireballSpell.invoke(this);
          this._mana -= fireballSpell.getManaCost();
        }
      } else if (d6 == 4) {
        if (rapidShotSpell.getManaCost() < this._mana) {
          rapidShotSpell.invoke(this);
          this._mana -= rapidShotSpell.getManaCost();
        }
      }
    }
    
    if (shieldTimer > 3) {
      shieldTimer = 0;
      for (Entity entity : entities) {
        if (entity instanceof Fireball || entity instanceof RapidShot) {
          if (entity.velocityX > 0) {
            if (random(1) > 0.85 && shieldSpell.getManaCost() < this._mana) {
              shieldSpell.invoke(this);
              this._mana -= shieldSpell.getManaCost();
              break;
            }
          }
        }
      } 
    }
    
    shieldTimer += delta;
    lastSpellTime += delta;
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  
  float shieldTimer = 0;
  float lastSpellTime = 0;
  FireballSpell fireballSpell;
  RapidShotSpell rapidShotSpell;
  ShieldSpell shieldSpell;
}

SpriteSheet enemyAlienSpritesheet;

class EnemyBlob extends Wizard {
  
  EnemyBlob(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
    copiedSpells = new ArrayList<Spell>();
  }
  
  float spellTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyBlobSpritesheet == null) {
      enemyBlobSpritesheet = loadSpriteSheet("/LD34/assets/enemy6.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyBlobSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyBlobSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    MANA_REGEN_RATE = 5.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    if (!copiedSpells.contains(player1.lastSpell) && player1.lastSpell != null) {
      copiedSpells.add(player1.lastSpell);
      if (copiedSpells > 3) {
        copiedSpells.remove(0);
      }
    }
    
    spellTimer += delta;
    if (spellTimer >= 3.0f && copiedSpells.size() > 0) {
      Spell spell = copiedSpells.get(int(random(copiedSpells.size())));
      if (_mana > spell.getManaCost()) {
        spell.invoke(this);
        _mana -= spell.getManaCost();
      }
      spellTimer = 0.0f;
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  ArrayList<Spell> copiedSpells;
  
}

SpriteSheet enemyBlobSpritesheet;
class EnemyEgg extends Wizard {
  
  EnemyEgg(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyEggSpritesheet == null) {
      enemyEggSpritesheet = loadSpriteSheet("/LD34/assets/enemy7.png", 5, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyEggSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyEggSpritesheet, 0.25, 4);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    windSpell = new GustSpell();
    fireballSpell = new FireballSpell();
    rapidShotSpell = new RapidShotSpell();
    shieldSpell = new ShieldSpell();
    zapSpell = new ZappyOrbSpell();
    manaSuckSpell = new ManaSuckerSpell();
    piercerSpell = new PiercerSpell();
    meteorSpell = new MeteorShowerSpell();
    reflectorSpell = new ReflectorSpell();
    MANA_REGEN_RATE = 3.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    
    if (eggMode) {
      //EGG MODE
      if (shieldTimer > 4) {
        shieldTimer = 0;
        boolean hasShield = false;
        for (Entity entity : entities) {
          if (entity.owner == player2 && entity instanceof Shield) {
            hasShield = true;
          }
        }
        if (!hasShield && _mana > shieldSpell.getManaCost()) {
          shieldSpell.invoke(this);
          _mana -= shieldSpell.getManaCost();
        }
      }
      
      if (lastSpellTime > 6) {
        lastSpellTime = 0;
        if (piercerSpell.getManaCost < _mana) {
          piercerSpell.invoke(this);
          _mana -= piercerSpell.getManaCost();
        }
      }
      
      
    } else {
      //DINO MODE
      if (lastSpellTime > 2) {
        lastSpellTime = 0;
        meteorSpell.invoke(this);
        meteorSpell.invoke(this);
      }
    }
    
    
    shieldTimer += delta;
    lastSpellTime += delta;
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
    
    if (eggMode) {
      _health -= damage * 4;
    } else {
      _health -= damage * 2;
    }
    
    if (eggMode && _health < 0) {
      _health = _maxHealth;
      _mana = _maxMana;
      eggMode = false;
      wizardStandingAnimation = new Animation(enemyEggSpritesheet, 0.25, 2, 3);
    }
  }
  
  boolean eggMode = true;
  float shieldTimer = 0;
  float lastSpellTime = 0;
  FireballSpell fireballSpell;
  RapidShotSpell rapidShotSpell;
  ShieldSpell shieldSpell;
  GustSpell windSpell;
  ZappyOrbSpell zapSpell;
  ManaSuckerSpell manaSuckSpell;
  PiercerSpell piercerSpell;
  MeteorShowerSpell meteorSpell;
  ReflectorSpell reflectorSpell;
  
}

SpriteSheet enemyEggSpritesheet;

class EnemyEyeball extends Wizard {
  int timer = 0;
  
  int comboChain;
  int rechargeOrbs;
  
  EnemyEyeball(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 50.0f, 50.0f, leftFacing, inputProcessor);
    comboChain = 0;
    rechargeOrbs = 0;
  }
  
  void create() {
    super.create();
    if (eyeballSpritesheet == null) {
      eyeballSpritesheet = loadSpriteSheet("/LD34/assets/enemy0.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(eyeballSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(eyeballSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    shieldSpell = new ShieldSpell();
    fireballSpell = new FireballSpell();
    manaSpell = new ManaSpell();
    gustSpell = new GustSpell();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    timer += delta;
    if (timer > 1.0) {
      timer = 0;
      if (spellBook.size() > 0) {
        boolean spellInvoked = false;
        if(comboChain == 0) {
          if (_mana > fireballSpell.getManaCost()) {
            fireballSpell.invoke(this);
            _mana -= fireballSpell.getManaCost();
            spellInvoked = true;
            comboChain = 1;
          }
        } else if (comboChain == 1) {
          if (_mana > gustSpell.getManaCost()) {
            gustSpell.invoke(this);
            _mana -= gustSpell.getManaCost();
            spellInvoked = true;
            comboChain = 2;
          }
        } else if (comboChain != -1){
          if (_mana > shieldSpell.getManaCost()) {
            shieldSpell.invoke(this);
            _mana -= shieldSpell.getManaCost();
            spellInvoked = true;
            comboChain = 0;
          }
        }
        if(!spellInvoked) {
          comboChain = -1;
          manaSpell.invoke(this);
          rechargeOrbs++;
          
          if(rechargeOrbs > 6) {
            rechargeOrbs = 0;
            comboChain = 0;
          }
        }
      }
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  ShieldSpell shieldSpell;
  ManaSpell manaSpell;
  GustSpell gustSpell;
  FireballSpell fireballSpell;
  
}

SpriteSheet eyeballSpritesheet;

class EnemyFly extends Wizard {
  
  EnemyFly(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float gustTimer = 0.0f;
  float meteorTimer = 6.7f;
  float manaSuckerTimer = 0.0f;
  float blackHoleTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyFlySpritesheet == null) {
      enemyFlySpritesheet = loadSpriteSheet("/LD34/assets/enemy2.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyFlySpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyFlySpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    gustSpell = new GustSpell();
    meteorSpell = new MeteorShowerSpell();
    manaSuckerSpell = new ManaSuckerSpell();
    manaOrbSpell = new ManaSpell();
    healthOrbSpell = new HealthSpell();
    gravityWellSpell = new GravityWellSpell();
    MANA_REGEN_RATE = 5.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    gustTimer += delta;
    meteorTimer += delta;
    manaSuckerTimer += delta;
    blackHoleTimer += delta;
    
    if (gustTimer >= 4.0f && _mana > gustSpell.getManaCost()) {
      gustSpell.invoke(this);
      _mana -= gustSpell.getManaCost();
      gustTimer = 0.0f;
    }
    if (meteorTimer >= 8.0f && _mana > meteorSpell.getManaCost()) {
      meteorSpell.invoke(this);
      _mana -= meteorSpell.getManaCost();
      meteorTimer = 0.0f;
    }
    if (manaSuckerTimer >= 8.0f && _mana > manaSuckerSpell.getManaCost()) {
      manaSuckerSpell.invoke(this);
      _mana -= manaSuckerSpell.getManaCost();
      manaSuckerTimer = 0.0f;
    }
    if (blackHoleTimer >= 8.0f && _mana > gravityWellSpell.getManaCost()) {
      gravityWellSpell.invoke(this);
      _mana -= gravityWellSpell.getManaCost();
      blackHoleTimer = 0.0f;
    }
    
    if (random(1) > 1 - 0.2 * delta) {
      manaOrbSpell.invoke(this);
    }
    if (_health < _maxHealth && random(1) > 1 - 0.2 * delta && _mana > healthOrbSpell.getManaCost()) {
      healthOrbSpell.invoke(this);
      _mana -= healthOrbSpell.getManaCost();
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  GustSpell gustSpell;
  MeteorShowerSpell meteorSpell;
  ManaSuckerSpell manaSuckerSpell;
  ManaSpell manaOrbSpell;
  HealthSpell healthOrbSpell;
  GravityWellSpell gravityWellSpell;
  
}

SpriteSheet enemyFlySpritesheet;

class EnemyMirror extends Wizard {
  
  EnemyMirror(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float gustTimer = 0.0f;
  float meteorTimer = 6.7f;
  float manaSuckerTimer = 0.0f;
  float blackHoleTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyMirrorSpritesheet == null) {
      enemyMirrorSpritesheet = loadSpriteSheet("/LD34/assets/mirror.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyMirrorSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyMirrorSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    meteorSpell = new MeteorShowerSpell();
    manaSuckerSpell = new ManaSuckerSpell();
    manaOrbSpell = new ManaSpell();
    healthOrbSpell = new HealthSpell();
    MANA_REGEN_RATE = 5.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    meteorTimer += delta;
    manaSuckerTimer += delta;
    
    if (meteorTimer >= 8.0f && _mana > meteorSpell.getManaCost()) {
      meteorSpell.invoke(this);
      _mana -= meteorSpell.getManaCost();
      meteorTimer = 0.0f;
    }
    if (manaSuckerTimer >= 8.0f && _mana > manaSuckerSpell.getManaCost()) {
      manaSuckerSpell.invoke(this);
      _mana -= manaSuckerSpell.getManaCost();
      manaSuckerTimer = 0.0f;
    }
    
    if (random(1) > 1 - 0.2 * delta) {
      manaOrbSpell.invoke(this);
    }
    if (_health < _maxHealth && random(1) > 1 - 0.2 * delta && _mana > healthOrbSpell.getManaCost()) {
      healthOrbSpell.invoke(this);
      _mana -= healthOrbSpell.getManaCost();
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  MeteorShowerSpell meteorSpell;
  ManaSuckerSpell manaSuckerSpell;
  ManaSpell manaOrbSpell;
  HealthSpell healthOrbSpell;
  
}

SpriteSheet enemyMirrorSpritesheet;

class EnemySquid extends Wizard {
  
  EnemySquid(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float goingToPhaseTimer = 0.0f;
  float comboTimer = 0.0f;
  boolean didPhase = false;
  
  void create() {
    super.create();
    if (enemySquidSpriteSheet == null) {
      enemySquidSpriteSheet = loadSpriteSheet("/LD34/assets/enemy3.png", 4, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemySquidSpriteSheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemySquidSpriteSheet, 0.25, 3);
    wizardFadeAnimation = new Animation(enemySquidSpriteSheet, 0.25, 2);
    wizardStunAnimation = wizardStandingAnimation;
    
    rapidShotSpell = new RapidShotSpell();
    phaseSpell = new PhaseSpell();
    piercerSpell = new PiercerSpell();
    highSpell = new HighFireballSpell();
    MANA_REGEN_RATE = 10.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || stunned || winner || loser) {
      return;
    }
    goingToPhaseTimer += delta;
    if (goingToPhaseTimer > 3.0f && _mana > phaseSpell.getManaCost() && !didPhase) {
      phaseSpell.invoke(this);
      _mana -= phaseSpell.getManaCost();
      phaseTimer = 10.0f;
      didPhase = true;
    }
    if (goingToPhaseTimer > 13.0f) {
      goingToPhaseTimer = 0.0f;
      didPhase = false;
    }
    
    comboTimer += delta;
    if (comboTimer > 13.0f && phased) {
      if (_mana > piercerSpell.getManaCost()) {
        piercerSpell.invoke(this);
        _mana -= piercerSpell.getManaCost();
      }
      if (_mana > rapidShotSpell.getManaCost()) {
        rapidShotSpell.invoke(this);
        _mana -= rapidShotSpell.getManaCost();
      }
      if (_mana > highSpell.getManaCost()) {
        highSpell.invoke(this);
        _mana -= highSpell.getManaCost();
      }
      comboTimer = 0.0f;
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  RapidShotSpell rapidShotSpell;
  PiercerSpell piercerSpell;
  PhaseSpell phaseSpell;
  HighFireballSpell highSpell;
  
}

SpriteSheet enemySquidSpriteSheet;

class EnemyTree extends Wizard {
  
  EnemyTree(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyTreeSpritesheet == null) {
      enemyTreeSpritesheet = loadSpriteSheet("/LD34/assets/enemy5.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyTreeSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyTreeSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    windSpell = new GustSpell();
    fireballSpell = new FireballSpell();
    rapidShotSpell = new RapidShotSpell();
    shieldSpell = new ShieldSpell();
    zapSpell = new ZappyOrbSpell();
    manaSuckSpell = new ManaSuckerSpell();
    piercerSpell = new PiercerSpell();
    meteorSpell = new MeteorShowerSpell();
    reflectorSpell = new ReflectorSpell();
    MANA_REGEN_RATE = 3.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    if (lastSpellTime > 7 && _health / _maxHealth >= 0.2) {
      lastSpellTime = 0;
      int d10 = floor(random(10));
      
      if (d10 == 0 || d10 == 1 || d10 == 2 || d10 == 8) {
        boolean hasSuck = false;
        for (Entity entity : entities) {
          if (entity.owner == player2 && entity instanceof ManaSucker) {
            hasSuck = true;
            break;
          }
        }
        if (!hasSuck && manaSuckSpell.getManaCost() < this._mana) {
          manaSuckSpell.invoke(this);
          this._mana -= manaSuckSpell.getManaCost();
        } else if (hasSuck && fireballSpell.getManaCost() < this._mana) {
//          fireballSpell.invoke(this);
//          this._mana -= fireballSpell.getManaCost();
        }
      }else if (d10 == 3 || d10 == 4 || d10 == 5 || d10 == 7) {
        boolean hasZap = false;
        for (Entity entity : entities) {
          if (entity.owner == player2 && entity instanceof ZappyOrb) {
            hasZap = true;
            break;
          }
        }
        if (!hasZap && zapSpell.getManaCost() < this._mana) {
          zapSpell.invoke(this);
          this._mana -= zapSpell.getManaCost();
        } else if (zapSpell && piercerSpell.getManaCost() < this._mana) {
          piercerSpell.invoke(this);
          this._mana -= piercerSpell.getManaCost();
        }
      } 
    }
    
    if (_health / _maxHealth < 0.2 && lastSpellTime > 4) {
      lastSpellTime = 0;
      if (rapidShotSpell.getManaCost() < this._mana) {
        rapidShotSpell.invoke(this);
        this._mana -= rapidShotSpell.getManaCost();
      }
    } 
    
    if (shieldTimer > 5) {
      shieldTimer = 0;
      for (Entity entity : entities) {
        if (entity instanceof Fireball || entity instanceof HighFireball || entity instanceof MeteorShower) {
          if (entity.owner == player1) {
            if (random(1) > 0.6) {
              
              int d3 = floor(random(3));
              
              if (d3 == 0) {
                if (reflectorSpell.getManaCost() < this._mana) {
                  reflectorSpell.invoke(this);
                  this._mana -= reflectorSpell.getManaCost();
                }
              } else if (d3 == 1) {
                if (shieldSpell.getManaCost() < this._mana) {
                  shieldSpell.invoke(this);
                  this.mana -= shieldSpell.getManaCost();
                }
              } else if (d3 == 2) {
                if (windSpell.getManaCost() < this._mana) {
                  windSpell.invoke(this);
                  this.mana -= windSpell.getManaCost();
                }
              }                
              break;
            }
          }
        }
      }
    }
    
    shieldTimer += delta;
    lastSpellTime += delta;
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  
  float shieldTimer = 5;
  float lastSpellTime = 3;
  FireballSpell fireballSpell;
  RapidShotSpell rapidShotSpell;
  ShieldSpell shieldSpell;
  GustSpell windSpell;
  ZappyOrbSpell zapSpell;
  ManaSuckerSpell manaSuckSpell;
  PiercerSpell piercerSpell;
  MeteorShowerSpell meteorSpell;
  ReflectorSpell reflectorSpell;
  
}

SpriteSheet enemyTreeSpritesheet;

class EnemyTutorial extends Wizard {
  
  int phase = 0;
  
  EnemyTutorial(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 10000000.0f, 60.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyScarecrowSheet == null) {
      enemyScarecrowSheet = loadSpriteSheet("/LD34/assets/tutorial_boss.png", 4, 1, 250, 250);
    }
    if (tutorialTextSheet == null) {
      tutorialTextSheet = loadSpriteSheet("/LD34/assets/tutorial_text.png", 9, 1, 500, 250);
    }
    
    player1._mana = 0.0f;
    player1._health = 20.0f;
    
    wizardStandingAnimation = new Animation(enemyScarecrowSheet, 0.25, 0, 0);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyScarecrowSheet, 0.25, 1);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    MANA_REGEN_RATE = 0.0f;
  }
  
  void update(int p, float delta) {
    super.update(p, delta);
    if (preFight || stunned || winner || loser) {
      return;
    }
    if (phase == 1) {
      for (Entity entity : entities) {
        if (entity instanceof ManaOrb) {
          removeEntity(entity);
        }
      }
    }
    if (phase == 2) {
      for (Entity entity : entities) {
        if (entity instanceof ManaOrb) {
          phase += 1;
        }
      }
    }
    if (phase == 3) {
      for (Entity entity : entities) {
        if (entity instanceof HealthOrb) {
          removeEntity(entity);
        }
      }
      if (player1._mana == player1._maxMana) {
        phase += 1;
      }
    }
    if (phase == 4) {
      for (Entity entity : entities) {
        if (entity instanceof HealthOrb) {
          phase += 1;
        }
        if (entity instanceof Fireball) {
          removeEntity(entity);
        }
      }
    }
    if (phase == 5) {
      for (Entity entity : entities) {
        if (entity instanceof Fireball) {
          phase += 1;
        }
        if (entity instanceof Reflector) {
          removeEntity(entity);
        }
      }
    }
    if (phase == 6) {
      for (Entity entity : entities) {
        if (entity instanceof Reflector) {
          phase += 1;
        }
      }
    }
    if (phase == 8) {
      _maxHealth = 100.0f;
      if (_health > _maxHealth) {
        _health = _maxHealth;
        player2HealthGradual = _health;
      }
    }
  }
  
  void render() {
    super.render();
    if (!preFight) {
      tutorialTextSheet.drawSprite(phase, x - 600, y - 300, 500, 250);
    }
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
}

SpriteSheet enemyScarecrowSheet;
SpriteSheet tutorialTextSheet;

class EnemyWizard extends Wizard {
  
  EnemyWizard(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float reflectorTimer = 0.0f;
  float blackHoleTimer = 0.0f;
  boolean hasShield = false;
  float summonTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyWizardSpriteSheet == null) {
      enemyWizardSpriteSheet = loadSpriteSheet("/LD34/assets/enemy1.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyWizardSpriteSheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyWizardSpriteSheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    reflectorSpell = new ReflectorSpell();
    manaOrbSpell = new ManaSpell();
    gravityWellSpell = new GravityWellSpell();
    MANA_REGEN_RATE = 4.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    reflectorTimer += delta;
    blackHoleTimer += delta;
    if (player1._mana / player1._maxMana > 0.25) {
      blackHoleTimer += 6 * delta;
    }
    if (blackHoleTimer > 30.0f && _mana > gravityWellSpell.getManaCost()) {
      gravityWellSpell.invoke(this);
      _mana -= gravityWellSpell.getManaCost();
      blackHoleTimer = 0.0f;
    }
    if (!hasShield && reflectorTimer > 1.0f && _mana > reflectorSpell.getManaCost()) {
      reflectorSpell.invoke(this);
      _mana -= reflectorSpell.getManaCost();
      hasShield = true;
    }
    if (reflectorTimer > 5.0f) {
      reflectorTimer = 0.0f;
      hasShield = false;
    }
    if (random(1) > 1 - 0.2 * delta) {
      manaOrbSpell.invoke(this);
    }
    summonTimer += delta;
    if (summonTimer > 3.0f && _mana > 10.0f) {
      summonTimer = 0.0f;
      _mana -= 10.0f;
      addEntity(new ZappyOrb(800.0f + random(-300.0f, +100.0f), 210.0f + random(100.0f), this));
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
  ReflectorSpell reflectorSpell;
  ManaSpell manaOrbSpell;
  GravityWellSpell gravityWellSpell;
  
}

SpriteSheet enemyWizardSpriteSheet;

class Fireball extends Hazard {
  
  float ACCELX = 50;
  
  public Fireball(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 42.0, 0.0, 1.0, owner);
    this.damage = 9.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    ACCELX = (owner._leftFacing ? -ACCELX : ACCELX);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (fireballSpritesheet == null) {
      fireballSpritesheet = loadSpriteSheet("/LD34/assets/blueFireball.png", 4, 1, 150, 150);
    }
    playSound("fireball");
    fireballAnimation = new Animation(fireballSpritesheet, 0.05, 0, 1, 2, 3);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float xr = x - 75;
    float xy = y - 75;
    float size = 150;
    
    if(velocityX < 0) {
      scale(-1, 1);
      xr = -((x - 75) + 150);
    }
    
    fireballAnimation.drawAnimation(xr, xy, size, size);
     
    if (velocityX < 0) {
      scale(-1, 1);
    }
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    fireballAnimation.update(delta);
    velocityX += delta * ACCELX;
  }
  
  int depth() {
    return 0;
  }
  
  Animation fireballAnimation;
}

class FireballSpell extends Spell {
  
  int[] combination = new int[] { 0, 0, 0 };
  
  public FireballSpell() {
  }
  
  public String name() {
    return "Fireball";
  }
  
  public void invoke(Wizard owner) {
    Fireball fireball = new Fireball(owner.x, owner.y, 100, 0, owner);
    if (owner.x < width / 2) {
      fireball.x += 10;
    }
    else {
      fireball.x -= 10;
      fireball.velocityX *= -1;
    }
    addEntity(fireball);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet fireballSpritesheet;
class GravityWell extends Collider {
  
  float timer = 0.0;
  float lifetime = 5.0;
  
  public GravityWell(float x_, float y_, float velocityX_, float velocityY_) {
    super(x_, y_, 32.0, 20.0);
    velocityX = velocityX_;
    velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    removeEntity(other);
  }
  
  void create() {
    super.create();
    if (gravityWellSpritesheet == null) {
      gravityWellSpritesheet = loadSpriteSheet("/LD34/assets/gravityWell.png", 2, 1, 150, 150);
    }
    gravityWellAnimation = new Animation(gravityWellSpritesheet, 0.25, 0, 1);
    //playSound("summonBlackHole");
    playSound("blackHole");
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();    
    float xr = x - 75;
    float xy = y - 75;
    float size = 150;
    
    gravityWellAnimation.drawAnimation(xr, xy, size, size);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    gravityWellAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    for (Entity entity : entities) {
      if (entity instanceof HealthOrb || entity instanceof ManaOrb) {
        dist = sq(entity.x - x) + sq(entity.y - y);
        mag = pow(dist, 1.5);
        if (dist != 0) {
          entity.velocityX -= delta * 200000000.0 * (entity.x - x) / mag;
          entity.velocityY -= delta * 200000000.0 * (entity.y - y) / mag;
        }
      }
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation gravityWellAnimation;
}

class GravityWellSpell extends Spell {
  
  int[] combination = new int[] { 1, 0, 1 };
  
  public GravityWellSpell() {
  }
  
  public String name() {
    return "Black Hole";
  }
  
  public void invoke(Wizard owner) {
    playSound("gravityWell");
    GravityWell well = new GravityWell(width / 2, height / 2, 0, 0);
    if (owner.x < width / 2) {
      well.x -= 200;
    }
    else {
      well.x += 200;
    }
    addEntity(well);
    addEntity(new Poof(well.x, well.y));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet gravityWellSpritesheet;
class GustSpell extends Spell {
  
  int[] combination = new int[] { 0, 1 };
  
  public GustSpell() {
  }
  
  public String name() {
    return "Gust";
  }
  
  public void invoke(Wizard owner) {    
    addEntity(new Gust(owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

class Gust extends Entity {
    
  float GUST_ACCEL = 3;
  int TOTAL_PARTICLES = 8;
  
  int particleCount;
  float timer;
  Wizard _owner;
  
  public Gust(Wizard owner) {
    particleCount = 0;
    timer = 0;
    _owner = owner;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    
    for(Entity entity : entities) {
      if(entity instanceof GravityWell || entity instanceof Shield || entity instanceof HealthOrb || entity instanceof ManaOrb || entity instanceof Reflector ) {
        continue;
      }
      if(entity instanceof Hazard) {
        Hazard hazard = (Hazard) entity;
        float factor = 0.0f;
        if (_owner.x >= width / 2) {
          factor = 1.0f;
        }
        else {
          factor = -1.0f;
        }
        if (hazard.velocityX > 10.0) {
          hazard.velocityX *= 1.0 - factor * GUST_ACCEL * delta;
        }
        else if (hazard.velocityX < -10.0) {
          hazard.velocityX *= 1.0 + factor * GUST_ACCEL * delta;
        }
        else {
          hazard.velocityX -= 200 * factor * delta;
        }
      }
    }
    
    timer += delta;
    if(timer > 0.25) {
      timer = 0;
      particleCount ++;      
      if(!_owner._leftFacing) {
        addEntity(new GustParticle(_owner.x + ((width - 240) / TOTAL_PARTICLES)*particleCount, height * random(1), _owner._leftFacing)); 
      } else {
        addEntity(new GustParticle(_owner.x - ((width - 240) / TOTAL_PARTICLES)*particleCount, height * random(1), _owner._leftFacing)); 
      }  
    }
    if(particleCount >= TOTAL_PARTICLES) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}

class GustParticle extends Moving {
  
  float LIFETIME = 0.75;
  
  float timer;
  boolean leftFacing;
  
  public GustParticle(float x_, float y_, boolean leftFacing_) {
    super(x_, y_, 0);
    leftFacing = leftFacing_;
    timer = 0;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (windSpritesheet == null) {
      windSpritesheet = loadSpriteSheet("/LD34/assets/wind.png", 4, 1, 240, 240);
    }
    windAnimation = new Animation(windSpritesheet, LIFETIME/4, 0, 1, 2, 3);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    float size = 240;
    
    pushMatrix();
    translate(x, y);
    
    if(leftFacing) {
      scale(-1, 1);
    }
    windAnimation.drawAnimation(-size/2, -size/2, size, size);
     
    popMatrix();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    windAnimation.update(delta);
    timer += delta;
    
    if(timer > LIFETIME) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation windAnimation;
}

SpriteSheet windSpritesheet;
class Hazard extends Collider {
  
  float damage;
  Wizard owner;
  boolean triggered = false;
  
  public Hazard(float x_, float y_, float radius_, float friction_, float damage_, Wizard owner_) {
    super(x_, y_, radius_, friction_);
    this.damage = damage_;
    this.owner = owner_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Wizard) {
      if ((Wizard) other != owner) {
        if(other instanceof EnemyMirror && velocityX > 1.5 * velocityY) {          
          owner = (Wizard) other;
          velocityX *= -1;
        } else {          
          ((Wizard) other).hurt(damage);
          triggered = true;
        }
      }
    }
    if (other instanceof Summon) {
      if (other.owner != owner) {
        other.hurt(damage);
        triggered = true;
      }
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (x < -200 || x > width + 200 || y < -200 || y > height + 200) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}

class HealthOrb extends Collider{
  Wizard owner;
  float distY = 200.0;
  float healthRegen = 0.5; //health regenerated per second
  float timer = 10.0;
  
  public HealthOrb(Wizard owner_) {
    super(owner_.x + 50, owner_.y - distY, 20, 0.0);
    this.velocityX = 25;
    this.velocityY = 15;
    owner = owner_;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    healthOrbAnimation.update(delta);
    accelToPoint(owner.x, owner.y - distY);
    
    if (!owner.phased) {
      owner._health += healthRegen * delta;
    }
    if (owner._health > owner._maxHealth) {
      owner._health = owner._maxHealth;
    }
    timer -= delta;
    if (timer <= 0) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (healthOrbSpritesheet == null) {
      healthOrbSpritesheet = loadSpriteSheet("/LD34/assets/healthOrb.png", 2, 1, 60, 60);
    }
    healthOrbAnimation = new Animation(healthOrbSpritesheet, 0.5, 0, 1);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 64));
  }
  
  void render() {
    super.render();
    float xr = x - 30;
    float xy = y - 30;
    float size = 60;
    
    healthOrbAnimation.drawAnimation(xr, xy, size, size);
  }
  
  void accelToPoint(float px, float py) {
    float mag = sqrt(sq(this.x - px) + sq(this.y - py));
    if (mag == 0) {
      return;
    }
    float dirX = (px - this.x) / mag;
    float dirY = (py - this.y) / mag;
    this.accelX = dirX * 500;
    this.accelY = dirY * 500;
  }
} 

class HealthSpell extends Spell {
  int[] combination = new int[] {0};
 
  public HealthSpell() {
  }
  
  String name() {
    return "Health Orb";
  }
  
  void invoke(Wizard owner) {
    playSound("orb");
    HealthOrb healthOrb = new HealthOrb(owner);
    addEntity(healthOrb);
  }
  
  float getManaCost() {
    return 10.0f;
  }
  
  int[] getCombination() {
    return combination;
  }
  
  Animation healthOrbAnimation;
}

SpriteSheet healthOrbSpritesheet;
class HighFireball extends Hazard {
  
  int GRAV = 220;
  float ACCELX = 50;
  
  boolean _leftFacing;
  
  public HighFireball(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 12.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    ACCELX = (owner._leftFacing ? -ACCELX : ACCELX);
    _leftFacing = owner._leftFacing;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (spinningFireballSpritesheet == null) {
      spinningFireballSpritesheet = loadSpriteSheet("/LD34/assets/spinningFireball.png", 4, 1, 60, 60);
    }
    playSound("fireball");
    spinningFireballAnimation = new Animation(spinningFireballSpritesheet, 0.1, 0, 1, 2, 3);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float xr = x - 60;
    float xy = y - 60;
    float size = 120;
    
    if(_leftFacing) {
      scale(-1, 1);
      xr = -((x - size/2) + size);
    }
    
    spinningFireballAnimation.drawAnimation(xr, xy, size, size);
     
    if (_leftFacing) {
      scale(-1, 1);
    }    
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    spinningFireballAnimation.update(delta);
    velocityY += delta * GRAV;
    velocityX += delta * ACCELX;
  }
  
  int depth() {
    return 0;
  }
  
}

class HighFireballSpell extends Spell {
  
  int[] combination = new int[] { 0, 0, 1 };
  
  public HighFireballSpell() {
  }
  
  public String name() {
    return "Arcane Disk";
  }
  
  public void invoke(Wizard owner) {
    HighFireball fireball = new HighFireball(owner.x, owner.y, 100, -460, owner);
    if (owner.x < width / 2) {
      fireball.x += 10;
    }
    else {
      fireball.x -= 10;
      fireball.velocityX *= -1;
    }
    addEntity(fireball);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet spinningFireballSpritesheet;
class InputProcessor {
  
  float DOT_TIME = 0.25f, DASH_TIME = 1.0f, PAUSE_TIME = 0.25f;

  // input states
  int WAITING_TO_START = 0, WAITING_FOR_KEY_UP = 1, WAITING_FOR_KEY_DOWN = 2, CANCELLING = 3;

  // input types
  int DOT = 0, DASH = 1;
  
  char _keyToProcess;
  ArrayList<Integer> _inputWord;
    
  ArrayList<ArrayList<Integer>> _processedWords;
  
  Integer _inputState;
  float _stateTimer;
  
  boolean _keyDown;
  
  boolean canInput = true;
  
  InputProcessor (char keyToProcess) {
    _keyToProcess = keyToProcess;
    _inputWord = new ArrayList<Integer>();
    _processedWords = new ArrayList<ArrayList<Integer>>();
    _lastDown = _LastUp = 0;
    _inputState = WAITING_TO_START;
    _stateTimer = 0;
    _keyDown = false;
  }
  
  void reset() {
    
  }
  
  void keyPressed() {
    if(key == _keyToProcess && canInput) {
      _keyDown = true;
    }
  }
  
  void keyReleased() {
    if(key == _keyToProcess && canInput) {
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
          _inputState = WAITING_FOR_KEY_DOWN;
          _stateTimer = 0;
          _inputWord.add(DOT);
        } else if (_stateTimer <= DASH_TIME) {
          _inputState = WAITING_FOR_KEY_DOWN;
          _stateTimer = 0;
          _inputWord.add(DASH);
        }
      } else {
        _stateTimer += deltaTime; 
        if (_stateTimer > DASH_TIME){ // if held too long will reset input sequence
          _inputState = CANCELLING;
          _stateTimer = 0;
        }
      }
    } else if (_inputState == WAITING_FOR_KEY_DOWN) {
      if(_keyDown && _inputWord.size() < 3) {        
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
    } else if (_inputState == CANCELLING) {
      if(!_keyDown) {
        _inputState = WAITING_TO_START;
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
class ManaOrb extends Collider{
  Wizard owner;
  float distY = 150.0;
  float manaRegen = 2.0; //mana regenerated per second
  float timer = 8.0;
  
  public ManaOrb(Wizard owner_) {
    super(owner_.x + 50, owner_.y - distY, 20, 0.0);
    this.velocityX = 25;
    this.velocityY = 15;
    owner = owner_;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    manaOrbAnimation.update(delta);
    accelToPoint(owner.x, owner.y - distY);
    
    if (!owner.phased) {
      owner._mana += manaRegen * delta;
    }
    if (owner._mana > owner._maxMana) {
      owner._mana = owner._maxMana;
    }
    timer -= delta;
    if (timer <= 0) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (manaOrbSpritesheet == null) {
      manaOrbSpritesheet = loadSpriteSheet("/LD34/assets/manaOrb.png", 2, 1, 60, 60);
    }
    manaOrbAnimation = new Animation(manaOrbSpritesheet, 0.5, 0, 1);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 64));
  }
  
  void render() {
    super.render();
    float xr = x - 30;
    float xy = y - 30;
    float size = 60;
    
    manaOrbAnimation.drawAnimation(xr, xy, size, size);
  }
  
  void accelToPoint(float px, float py) {
    float mag = sqrt(sq(this.x - px) + sq(this.y - py));
    if (mag == 0) {
      return;
    }
    float dirX = (px - this.x) / mag;
    float dirY = (py - this.y) / mag;
    this.accelX = dirX * 500;
    this.accelY = dirY * 500;
  }
} 

class ManaSpell extends Spell {
  int[] combination = new int[] { 1 };
 
  public ManaSpell() {
    super();
  }
  
  String name() {
    return "Mana Orb";
  }
  
  void invoke(Wizard owner) {
    playSound("orb");
    ManaOrb manaOrb = new ManaOrb(owner);
    addEntity(manaOrb);
  }
  
  float getManaCost() {
    return 0.0f;
  }
  
  int[] getCombination() {
    return combination;
  }
  
  Animation manaOrbAnimation;
}

SpriteSheet manaOrbSpritesheet;
class ManaSucker extends Summon {
  
  float lifetime = 15.0;
  float timer = 0.0;
  int shotsFired = -5;
  float timePerShot = 2.0;
  Wizard target = null;
  Wizard owner;
  
  ManaSucker(float x_, float y_, Wizard owner_) {
    super(x_, y_, 32.0f, 0.0f, 1.0f);
    
    if (suckerShotSpritesheet == null) {
      manaSuckerSpritesheet = loadSpriteSheet("/LD34/assets/mana_suck.png", 3, 1, 200, 200);
    }
    manaSuckerAnimation = new Animation(manaSuckerSpritesheet, 0.15, 0, 1, 2);
    
    if (manaBeamSpritesheet == null) {
      manaBeamSpritesheet = loadSpriteSheet("/LD34/assets/mana_steal.png", 2, 1, 600, 400);
    }
    manaBeamAnimation = new Animation(manaBeamSpritesheet, 0.15, 0, 1);
    
    owner = owner_;
    for (Entity entity : entities) {
      if (entity instanceof Wizard) {
        if (entity != owner_) {
          target = entity;
        }
      }
    }
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof ManaSucker) {
      if (other.timer > this.timer) {
        removeEntity(other);
      }
      else {
        removeEntity(this);
      }
    }
    if (other instanceof ManaSuckerShot) {
      removeEntity(other);
      target._mana -= 11.0f;
      if (target._mana < 0.0) {
        target._mana = 0.0;
      }
      playSound("manaSteal1");
    }
  }
  
  void create() {
    super.create();
    addEntity(new Poof(x, y));
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    if (owner.x < 500) {    
      manaSuckerAnimation.drawAnimation(x - 100, y - 100, 200, 200);
      manaBeamAnimation.drawAnimation(x + 30, y + 5, 600, 400);
    } else {
      scale(-1, 1);
      manaSuckerAnimation.drawAnimation(-(x + 100), y - 100, 200, 200);
      manaBeamAnimation.drawAnimation(-(x - 30), y + 5, 600, 400);
      scale(-1, 1);
    }
//    fill(255, 255, 0);
//    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    manaSuckerAnimation.update(delta);
    manaBeamAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    if (timer > (shotsFired + 1) * timePerShot && target != null) {
      if (shotsFired > 0 && shotsFired < 5) {
        velocityX_ = (x - target.x) / 3;
        velocityY_ = (y - target.y) / 3;
        shot = new ManaSuckerShot(target.x, target.y + 20.0f, velocityX_, velocityY_);
        addEntity(shot);
      }
      shotsFired += 1;
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation manaBeamAnimation;
  Animation manaSuckerAnimation;
}

class ManaSuckerSpell extends Spell {
  
  int[] combination = new int[] { 1, 1, 0 };
  
  public ManaSuckerSpell() {
  }
  
  public String name() {
    return "Summon Mana Leech";
  }
  
  public void invoke(Wizard owner) {
    float _x = 260.0f;
    if (owner.x > width / 2) {
      _x = width - _x;
    }
    addEntity(new ManaSucker(_x, 160.0f, owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
  
}

class ManaSuckerShot extends Collider {
  
  public ManaSuckerShot(float x_, float y_, float velocityX_, float velocityY_) {
    super(x_, y_, 20.0, 0.0);
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (suckerShotSpritesheet == null) {
      suckerShotSpritesheet = loadSpriteSheet("/LD34/assets/manaOrb.png", 2, 1, 60, 60);
    }
    suckerShotAnimation = new Animation(suckerShotSpritesheet, 0.05, 0, 1);
    playSound("manaSteal0");
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    float xr = x - 30;
    float xy = y - 30;
    float size = 60;
    
    if(velocityX < 0) {
      scale(-1, 1);
      xr = -((x - size/2) + size);
    }
    
    suckerShotAnimation.drawAnimation(xr, xy, size, size);
     
    if (velocityX < 0) {
      scale(-1, 1);
    }    
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    suckerShotAnimation.update(delta);
  }
  
  int depth() {
    return 0;
  }
  
  Animation suckerShotAnimation;
  
}

SpriteSheet manaBeamSpritesheet;
SpriteSheet suckerShotSpritesheet;
SpriteSheet manaSuckerSpritesheet;

class MeteorShowerSpell extends Spell {
  
  int[] combination = new int[] { 1, 1, 1 };
  
  public MeteorShowerSpell() {
  }
  
  public String name() {
    return "Meteor Shower";
  }
  
  public void invoke(Wizard owner) {
    addEntity(new MeteorShower(owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}
class MeteorShower extends Entity {
  
  int TOTAL_METEORS = 10;
  
  int meteorCount;
  float timer;
  Wizard _owner;
  
  public MeteorShower(Wizard owner) {
    meteorCount = 0;
    timer = 0;
    _owner = owner;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;
    if(timer > 0.5) {
      timer = 0;
      meteorCount ++;
      //playSound("meteor");
      if(!_owner._leftFacing) {
        addEntity(new Meteor(_owner.x + (width / 12)*meteorCount, 0, 0, 150, _owner));   
      } else {
        addEntity(new Meteor(_owner.x - (width / 12)*meteorCount, 0, 0, 150, _owner));   
      }
    }
    if(meteorCount >= TOTAL_METEORS) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}

class Meteor extends Hazard {
  
  float accelerationY = 400;
  
  public Meteor(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 80.0, 0.0, 0.0, owner);
    this.damage = 5.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (meteorSpritesheet == null) {
      meteorSpritesheet = loadSpriteSheet("/LD34/assets/meteor.png", 2, 1, 250, 250);
    }
    playSound("meteor");
    meteorAnimation = new Animation(meteorSpritesheet, 0.25, 0, 1);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float size = 250;
    
    pushMatrix();
    translate(x, y);
    
    if(velocityX < 0) {
      scale(-1, 1);
    }
    if(velocityY < 0) {
      scale(1, -1);
    }
    meteorAnimation.drawAnimation(-size/2, -size/2, size, size);
     
    popMatrix();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    
    if(velocityY > 0) {
      accelerationY = 400;
    } else {
      accelerationY = -400;      
    }
    
    meteorAnimation.update(delta);
    velocityY += delta*accelerationY;
    
    if(y > height) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation meteorAnimation;
}

SpriteSheet meteorSpritesheet;
class Moving extends Entity {
  
  Moving(float x_, float y_, float friction_) {
    x = x_;
    y = y_;
    friction = friction_;
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (phase == 0) {
      velocityX += accelX * delta;
      velocityY += accelY * delta;
      x += velocityX * delta;
      y += velocityY * delta;
      velocity = sqrt(velocityX * velocityX + velocityY * velocityY);
      if (velocity > friction * delta) {
        velocityX -= velocityX / velocity * friction * delta;
        velocityY -= velocityY / velocity * friction * delta;
      }
      else {
        velocityX = 0;
        velocityY = 0;
      }
    }
  }
  
  float friction;
  float x;
  float y;
  float velocityX;
  float velocityY;
  float accelX = 0;
  float accelY = 0;
  
}
class PhaseSpell extends Spell {
  int[] combination = new int[] { 1, 1 };
  
  public PhaseSpell() {
  }
  
  public String name() {
    return "Phase Shift";
  }
  
  public void invoke(Wizard owner) {
    playSound("phase");
    owner.phased = true;
    owner.phaseTimer = 2.0f;
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

class Piercer extends Hazard {
  
  float ACCELY = 500;
  
  public Piercer(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 1.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    _leftFacing = owner._leftFacing;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Shield) {
      playSound("shieldBreaker");
      removeEntity(other);
      other.owner.stunned = true;
      other.owner.stunTimer = 1.5f;
    }
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (piercerSpritesheet == null) {
      piercerSpritesheet = loadSpriteSheet("/LD34/assets/piercer.png", 4, 1, 120, 120);
    }
    playSound("piercer");
    piercerAnimation = new Animation(piercerSpritesheet, 0.3, 0, 1);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float size = 120;
    
    pushMatrix();
    translate(x, y);
    
    rotate(atan(velocityY/velocityX));
    if(velocityX < 0) {
      scale(-1, 1);
    }
    piercerAnimation.drawAnimation(-size/2, -size/2, size, size);
     
    popMatrix();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    piercerAnimation.update(delta);
    velocityY += delta * ACCELY;
  }
  
  int depth() {
    return 0;
  }
  
  Animation piercerAnimation;
}

SpriteSheet piercerSpritesheet;

class PiercerSpell extends Spell {
  
  int[] combination = new int[] { 1, 0, 0 };
  
  public PiercerSpell() {
  }
  
  public String name() {
    return "Piercing Bolt";
  }
  
  public void invoke(Wizard owner) {
    Piercer piercerA = new Piercer(owner.x, owner.y, 350, -600, owner);
    Piercer piercerB = new Piercer(owner.x, owner.y, 600, -300, owner);
    if (owner.x < width / 2) {
      
    }
    else {
      piercerA.velocityX *= -1;
      piercerB.velocityX *= -1;
    }
    addEntity(piercerA);
    addEntity(piercerB);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

class Poof extends Moving {
  
  float timer = 0.0;
  float lifetime = 0.25f;
  float size;
  
  Poof(float x_, float y_) {
    super(x_, y_, 0.0f);
    size = 128;
  }
  
  Poof(float x_, float y_, float size_) {
    super(x_, y_, 0.0f);
    size = size_;
  }
  
  void create() {
    super.create();
    if (poofSpriteSheet == null) {
      poofSpriteSheet = loadSpriteSheet("/LD34/assets/poof_strip.png", 3, 1, 128, 128);
    }
    animation = new Animation(poofSpriteSheet, 0.05, 0, 1, 2);
    playSound("poof");
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    animation.drawAnimation(x - size / 2, y - size / 2, size, size);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    animation.update(delta);
  }
  
  Animation animation;
  
}

SpriteSheet poofSpriteSheet;

int TOTAL_SHOTS = 10;

class RapidShot extends Hazard {
  
  float ACCELX = 800;
  
  boolean _leftFacing;
  
  public RapidShot(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 12.0f/TOTAL_SHOTS;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    ACCELX = (owner._leftFacing ? -ACCELX : ACCELX);
    _leftFacing = owner._leftFacing;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (rapidShotSpritesheet == null) {
      rapidShotSpritesheet = loadSpriteSheet("/LD34/assets/blueFireball.png", 4, 1, 150, 150);
    }
    rapidShotAnimation = new Animation(rapidShotSpritesheet, 0.05, 0, 1, 2, 3);
    playSound("rapidFire");
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 64, 64));
  }
  
  void render() {
    super.render();
    float xr = x - 25;
    float xy = y - 25;
    float size = 50;
    
    if(_leftFacing) {
      scale(-1, 1);
      xr = -((x - 25) + 50);
    }
    
    rapidShotAnimation.drawAnimation(xr, xy, size, size);
     
    if (_leftFacing) {
      scale(-1, 1);
    }    
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    rapidShotAnimation.update(delta);
    velocityX += delta * ACCELX;
  }
  
  int depth() {
    return 0;
  }
  
  Animation rapidShotAnimation;
}

class RapidShooter extends Entity {
  
  int shotCount;
  float timer;
  Wizard owner;
  
  public RapidShooter(Wizard _owner) {
    shotCount = 0;
    timer = 0;
    owner = _owner;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;
    if(timer > 0.25) {
      //playSound("miniFireball");
      RapidShot rapidShot = new RapidShot(owner.x, owner.y + 50 - 100 * random(1), 500, 0, owner);
      if (owner.x < width / 2) {
        rapidShot.x += 10;
      }
      else {
        rapidShot.x -= 10;
        rapidShot.velocityX *= -1;
      }
      timer = 0;
      shotCount ++;
      addEntity(rapidShot);
    }
    if(shotCount >= TOTAL_SHOTS) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}

class RapidShotSpell extends Spell {
  
  int[] combination = new int[] { 0, 1, 0 };
  
  public RapidShotSpell() {
  }
  
  public String name() {
    return "Rapid Shot";
  }
  
  public void invoke(Wizard owner) {
    addEntity(new RapidShooter(owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet rapidShotSpritesheet;
class Reflector extends Hazard {
  
  float lifetime = 3.0;
  float initialRadius = 132.0;
  float finalRadius = 160.0;
  float timer = 0.0;
  
  public Reflector(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, initialRadius, 20.0, 10.0, owner);
    
    if (reflectorSpritesheet == null) {
      reflectorSpritesheet = loadSpriteSheet("/LD34/assets/reflector.png", 4, 1, 400, 400);
    }
    reflectorAnimation = new Animation(reflectorSpritesheet, 0.3, 0, 1, 2, 3);
    
    velocityX = velocityX_;
    velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    
    if (other instanceof Hazard) {
      if (other.owner != owner) {
        playSound("shieldDeactivate");
        other.owner = owner;
        other.velocityX *= -1;
        other.velocityY *= -1;
        removeEntity(this);
      }
    }
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 192, 192));
  }
  
  void render() {
    super.render();
    if (owner.x < 500) {    
      reflectorAnimation.drawAnimation(x - 200, y - 180 , 400, 400);
    } else {
      scale(-1, 1);
      reflectorAnimation.drawAnimation(- (x + 200), y - 180, 400, 400);
      scale(-1, 1);
    }
    
//    fill(255, 0, 255);
//    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    reflectorAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      playSound("shieldDeactivate");
      removeEntity(this);
    }
    radius = (finalRadius - initialRadius) * timer / lifetime + initialRadius;
  }
  
  int depth() {
    return 0;
  }
  
  Animation reflectorAnimation;
}

class ReflectorSpell extends Spell {
  
  int[] combination = new int[] { 1, 0 };
  
  public ReflectorSpell() {
  }
  
  public String name() {
    return "Reflector Shield";
  }
  
  public void invoke(Wizard owner) {
    for (Entity entity : entities) {
      if (entity instanceof Reflector || entity instanceof Shield) {
        if (entity.owner == owner) {
          removeEntity(entity);
        }
      }
    }
    playSound("reflector");
    Reflector reflector = new Reflector(owner.x, owner.y, 0, 0, owner);
    addEntity(reflector);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

Spritesheet reflectorSpritesheet;
class Shield extends Hazard {
  
  float lifetime = 3.0;
  float initialRadius = 132.0;
  float finalRadius = 160.0;
  float timer = 0.0;
  
  public Shield(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, initialRadius, 20.0, 10.0, owner);
    velocityX = velocityX_;
    velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Hazard) {
      if (other.owner != owner) {
        removeEntity(other);
      }
    }
  }
  
  void create() {
    super.create();
    if (shieldSpritesheet == null) {
      shieldSpritesheet = loadSpriteSheet("/LD34/assets/shield.png", 4, 1, 400, 400);
    }
    shieldAnimation = new Animation(shieldSpritesheet, 0.2, 0, 1, 2, 3);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 192, 192));
  }
  
  void render() {
    super.render();
    if (owner.x < 500) {    
      shieldAnimation.drawAnimation(x - 200, y - 250 , 400, 400);
    } else {
      scale(-1, 1);
      shieldAnimation.drawAnimation(- (x + 200), y - 250, 400, 400);
      scale(-1, 1);
    }
//    fill(255, 255, 0);
//    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    shieldAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      playSound("shieldDeactivate");
      removeEntity(this);
    }
    radius = (finalRadius - initialRadius) * timer / lifetime + initialRadius;
  }
  
  int depth() {
    return 0;
  }
  
}

class ShieldSpell extends Spell {
  
  int[] combination = new int[] { 0, 0 };
  
  public ShieldSpell() {
  }
  
  public String name() {
    return "Bubble Shield";
  }
  
  public void invoke(Wizard owner) {
    for (Entity entity : entities) {
      if (entity instanceof Reflector || entity instanceof Shield) {
        if (entity.owner == owner) {
          removeEntity(entity);
        }
      }
    }
    playSound("shield");
    Shield shield = new Shield(owner.x, owner.y, 0, 0, owner);
    addEntity(shield);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
  
  Animation shieldAnimation;
}
SpriteSheet shieldSpritesheet;
class Spell {
  
  public abstract String name() {
  }
  
  public abstract void invoke(Wizard owner) {
  }
  
  public abstract float getManaCost() {
    return 1.0;
  }
  
  public abstract int[] getCombination() {
    return null;
  }
  
}


class SpriteSheet {
  
  PImage[] sprites;
  
  SpriteSheet (PImage[] _sprites) {
    sprites = _sprites;
  }
  
  void drawSprite (int index, float xPos, float yPos, float xRad, float yRad) {
    image(sprites[index], xPos, yPos, xRad, yRad);
  }
}

// A class for automaticaly animating 
class Animation {
  SpriteSheet sheet;
  int[] sprites;
  float time;
  
  int curr;
  float timeElapsed;
  
  boolean loop = true;
  
  Animation (SpriteSheet _sheet, float _time, int... _sprites) {
    sheet = _sheet;
    time = _time;
    sprites = _sprites;
    timeElapsed = 0;
    curr = 0;
  }
  
  //Draws and updates the animation.
  void drawAnimation (float xPos, float yPos, float xRad, float yRad) {
    sheet.drawSprite(sprites[curr], xPos, yPos, xRad, yRad);
  }
  
  void update(float delta) {
    timeElapsed += delta;
    // Only move to the next frame when enough time has passed
    if (timeElapsed >= time) {
      curr++;
      if (loop) {
        curr %= sprites.length;
      }
      else {
        if (curr >= sprites.length) {
          curr = sprites.length - 1;
        }
      }
      timeElapsed = 0.0f;
    }
  }
  
  void reset () {
    curr = 0;
  }
}

/* Loads a SpriteSheet from image at filename with x columns of sprites and y rows of sprites. */
SpriteSheet loadSpriteSheet (String filename, int x, int y, int w, int h) {
  PImage img = loadImage(filename);
  
  PImage[] sprites = new PImage[x*y];
  
  int xSize = w;
  int ySize = h;
  
  int a = 0;
  for (int j = 0; j < y; j++) {
    for (int i = 0; i < x; i++) {
      sprites[a] = img.get(i*xSize,j*ySize, xSize, ySize);
      a++;
    }
  }
  return new SpriteSheet(sprites);
}






class Summon extends Collider {
  
  float health;
  
  Summon(float x_, float y_, float radius_, float friction_, float health_) {
    super(x_, y_, radius_, friction_);
    health = health_;
  }
  
  public void hurt(float damage) {
    health -= damage;
    if (health < 0) {
      removeEntity(this);
    }
  }
}

class Wizard extends Collider{
  float _maxHealth;
  float _maxMana;
  float _health;
  float _mana;
  float MANA_REGEN_RATE = 0.0;
  boolean phased = false;
  float phaseTimer = 0.0;
  
  float hurtTimer = 0;
  float castTimer = 0;
  
  boolean stunned = false;
  float stunTimer = 0.0f;
  
  boolean winner = false;
  boolean loser = false;
  boolean preFight = true;
  float id;
  boolean _leftFacing;
  ArrayList<Spell> spellBook = new ArrayList<Spell>();
  
  InputProcessor _inputProcessor;
  
  Wizard opponent;
  
  Wizard(float x_, float y_, float maxHealth, float maxMana, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100, 0);
    _maxHealth = maxHealth;
    _maxMana = maxMana;
    _leftFacing = leftFacing;
    _health = _maxHealth;
    _mana = _maxMana;
    _inputProcessor = inputProcessor;
    spellBook.add(new FireballSpell());
    spellBook.add(new HighFireballSpell());
    spellBook.add(new ShieldSpell());
    spellBook.add(new ReflectorSpell());
    spellBook.add(new MeteorShowerSpell());
    spellBook.add(new HealthSpell());
    spellBook.add(new GravityWellSpell());
    spellBook.add(new ManaSpell());
    spellBook.add(new PiercerSpell());
    spellBook.add(new RapidShotSpell());
    spellBook.add(new PhaseSpell());
    spellBook.add(new ZappyOrbSpell());
    spellBook.add(new ManaSuckerSpell());
    spellBook.add(new GustSpell());    
  }
  
  void create() {
    super.create();
    if (characterSpritesheet == null) {
      characterSpritesheet = loadSpriteSheet("/LD34/assets/character_spritesheet.png", 5, 5, 250, 250);
    }
    wizardStandingAnimation = new Animation(characterSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = new Animation(characterSpritesheet, 0.2, 2);
    wizardCastingAnimation = new Animation(characterSpritesheet, 0.2, 3);
    wizardHurtAnimation = new Animation(characterSpritesheet, 0.2, 4);
    wizardWinAnimation = new Animation(characterSpritesheet, 0.2, 5, 6, 7, 8);
    wizardLoseAnimation = new Animation(characterSpritesheet, 0.2, 9, 10);
    wizardFadeAnimation = new Animation(characterSpritesheet, 0.25, 13, 12);
    wizardStunAnimation = new Animation(characterSpritesheet, 0.3, 14, 15);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    
    if (loser) {
      wizardLoseAnimation.update(delta);
      return;
    }
    else if (winner) {
      wizardWinAnimation.update(delta);
      return;
    }
    else if (preFight) {
      return;
    }
    
    hurtTimer -= delta;
    castTimer -= delta;
    if (phased) {
      phaseTimer -= delta;
      if (phaseTimer < 0.0f) {
        phased = false;
      }
    }
    
    if (stunned) {
      stunTimer -= delta;
      if (stunTimer < 0.0f) {
        stunned = false;
        _inputProcessor.canInput = true;
        _inputProcessor.reset();
      }
    }
    
    if (phased) {
      wizardFadeAnimation.update(delta);
    }
    if (stunned) {
      wizardStunAnimation.update(delta);
    }
    if (!stunned && !phased) {
      wizardStandingAnimation.update(delta);
    }
    
    if (!phased) {
      _mana += MANA_REGEN_RATE * delta;
    }
    if (_mana > _maxMana) {
      _mana = _maxMana;
    }
    
    ArrayList<Integer> word = _inputProcessor.getNextWord();  
    if(word != null) {
      for(Spell spell : spellBook) {
        if(checkForMatch(spell.getCombination(), word) && !phased) {
          castTimer = 0.25;
          _mana -= spell.getManaCost();
          spell.invoke(this);
          lastSpell = spell;
          if (_mana < 0.0f) {
            playSound("stun");
            _mana = 0.0f;
            _inputProcessor.canInput = false;
            stunned = true;
            stunTimer = 3.0f;
          }
          else {
            if(!(spell instanceof FireballSpell || spell instanceof HighFireballSpell)) {
              playSound("invoke");
            }
          }
          break;
        }
      }
    } 
  }
  
  void render() {
    super.render();
    
    float xr = x - 128;
    float xy = y - 128;
    float size = 256;
    
    if(_leftFacing) {
      scale(-1, 1);
      xr = -((x - 128) + 256);
    }
    
    if (winner) {
      wizardWinAnimation.drawAnimation(xr, xy, size, size);
    } else if(loser) {
      wizardLoseAnimation.drawAnimation(xr, xy, size, size);
    } else if (phased) {
      wizardFadeAnimation.drawAnimation(xr, xy, size, size);
    } else if (stunned) {
      wizardStunAnimation.drawAnimation(xr, xy, size, size);
    } else if (_inputProcessor._inputState == 1 || _inputProcessor._inputState == 2) {
      wizardCastPrepAnimation.drawAnimation(xr, xy, size, size);
    } else if (hurtTimer > 0) {
     wizardHurtAnimation.drawAnimation(xr, xy, size, size);
    } else if (castTimer > 0) {
     wizardCastingAnimation.drawAnimation(xr, xy, size, size); 
    } else {
      wizardStandingAnimation.drawAnimation(xr, xy, size, size);
    }
    
    if (_leftFacing) {
      scale(-1, 1);
    }    
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    if (!phased && !(loser || winner)) {
      playSound("hit");
      _health -= damage;
      hurtTimer = 0.25;
    }
  }
  
  boolean checkForMatch(int[] spellSeq, ArrayList<Integer> word) {
    if(spellSeq.length != word.size()) {
      return false;
    }
    for(int i = 0; i < spellSeq.length; i ++) {
      if(spellSeq[i] != word.get(i)) {
        return false;
      }
    }
    return true;
  }
  
  Animation wizardStandingAnimation;
  Animation wizardCastingAnimation;
  Animation wizardCastPrepAnimation;
  Animation wizardHurtAnimation;
  Animation wizardWinAnimation;
  Animation wizardLoseAnimation;
  Animation wizardFadeAnimation;
  Animation wizardStunAnimation;
  
  Spell lastSpell;
}

SpriteSheet characterSpritesheet;
class WizardAI extends Wizard {
  int timer = 0;
  
  WizardAI(float x_, float y_, float maxHealth, float maxMana, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, maxHealth, maxMana, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;  
    if (timer > 2.0) {
      timer = 0;
      if (spellBook.size() > 0) {
        Spell spell = spellBook.get(floor(random(0, spellBook.size())));
        if (spell.getManaCost() < _mana) {
          _mana -= spell.getManaCost();
          spell.invoke(this);
        } else {
          for(Spell spell : spellBook) {
            if (spell.name() == "Mana Orb" && spell.getManaCost() < _mana) {
              spell.invoke(this);
            }
          }
        }
      }
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }  
}
class ZappyOrb extends Summon {
  
  float lifetime = 15.0;
  float timer = 0.0;
  int shotsFired = -5;
  float timePerShot = 2.0;
  Wizard target = null;
  Wizard owner;
  
  ZappyOrb(float x_, float y_, Wizard owner_) {
    super(x_, y_, 32.0f, 0.0f, 1.0f);
    
    if (zappySpritesheet == null) {
      zappySpritesheet = loadSpriteSheet("/LD34/assets/zapper.png", 3, 1, 200, 200);
    }
    zappyAnimation = new Animation(zappySpritesheet, 0.2, 0, 1, 2);
    
    owner = owner_;
    for (Entity entity : entities) {
      if (entity instanceof Wizard) {
        if (entity != owner_) {
          target = entity;
        }
      }
    }
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof ZappyOrb) {
      if (other.timer > this.timer) {
        removeEntity(other);
      }
      else {
        removeEntity(this);
      }
    }
  }
  
  void create() {
    super.create();
    addEntity(new Poof(x, y));
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    if (owner.x < 500) {    
      zappyAnimation.drawAnimation(x - 100, y - 100, 200, 200);
    } else {
      scale(-1, 1);
      zappyAnimation.drawAnimation(- (x + 100), y - 100, 200, 200);
      scale(-1, 1);
    }
    
//    fill(255, 255, 0);
//    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    zappyAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    if (timer > (shotsFired + 1) * timePerShot && target != null) {
      if (shotsFired > 0) {
        velocityX_ = -(x - target.x) / 3;
        velocityY_ = -(y - target.y) / 3;
        int xoffset = 40;
        if (owner.x > width/2){
          xoffset *= -1;
        }
        shot = new ZappyShot(x + xoffset, y + 30, velocityX_, velocityY_, owner);
        addEntity(shot);
      }
      shotsFired += 1;
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation zappyAnimation;
}

class ZappyOrbSpell extends Spell {
  
  int[] combination = new int[] { 0, 1, 1 };
  
  public ZappyOrbSpell() {
  }
  
  public String name() {
    return "Summon Electric Orb";
  }
  
  public void invoke(Wizard owner) {
    float _x = 200.0f;
    if (owner.x > width / 2) {
      _x = 800;
    }
    addEntity(new ZappyOrb(_x, 210.0f, owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
  
}

class ZappyShot extends Hazard {
  
  public ZappyShot(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 3.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (zappyShotSpritesheet == null) {
      zappyShotSpritesheet = loadSpriteSheet("/LD34/assets/zap.png", 2, 1, 50, 50);
    }
    zappyShotAnimation = new Animation(zappyShotSpritesheet, 0.02, 0, 1);
    playSound("zappyShoot");
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float xr = x - 25;
    float xy = y - 25;
    float size = 50;
    
    if(velocityX < 0) {
      scale(-1, 1);
      xr = -((x - size/2) + size);
    }
    
    zappyShotAnimation.drawAnimation(xr, xy, size, size);
     
    if (velocityX < 0) {
      scale(-1, 1);
    }    
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    zappyShotAnimation.update(delta);
  }
  
  int depth() {
    return 0;
  }
  
  Animation zappyShotAnimation;
  
}

SpriteSheet zappyShotSpritesheet;
SpriteSheet zappySpritesheet;


