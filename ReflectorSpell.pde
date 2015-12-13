class Reflector extends Hazard {
  
  float lifetime = 3.0;
  float initialRadius = 132.0;
  float finalRadius = 160.0;
  float timer = 0.0;
  
  public Reflector(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, initialRadius, 20.0, 10.0, owner);
    velocityX = velocityX_;
    velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Hazard) {
      if (other.owner != owner) {
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
  }
  
  void render() {
    super.render();
    fill(255, 0, 255);
    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    radius = (finalRadius - initialRadius) * timer / lifetime + initialRadius;
  }
  
  int depth() {
    return 0;
  }
  
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

