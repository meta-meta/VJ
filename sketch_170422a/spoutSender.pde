public class SpoutSender {
  Spout sender;
  public SpoutSender(String name, PApplet sketch) {
    sender = new Spout(sketch);
    sender.createSender(name);
    sketch.registerMethod("draw", this);
  }
  public void draw() {
    sender.sendTexture();
  }
  public void dispose() {
    sender.dispose();
  }
}