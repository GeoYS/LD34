class Hazard extends Collider {
  
  float damage;
  Wizard owner;
  
  public Hazard(float x_, float y_, float radius_, float friction_, float damage_) {
    super(x_, y_, radius_, friction_);
    this.damage = damage_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Wizard) {
      if ((Wizard) other != owner) {
        ((Wizard) other)._health -= damage;
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
  }
  
  int depth() {
    return 0;
  }
  
}
