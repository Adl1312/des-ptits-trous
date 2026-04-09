import java.io.File;
import java.util.ArrayList;
import processing.svg.*;   // Librairie SVG (Processing)

PImage img;
ArrayList<File> images = new ArrayList<File>();
int imgIndex = 0;
String imgBase = "input";

// --- Paramètres globaux ---
int   cellSize = 10;
float dotScale = 1.0f;
float aspect   = 0.70f;
float angleDeg = 0;
boolean invert = false;
boolean discreteMode = true;

// 0 = ellipse, 1 = carré
int shapeMode = 0;

// 4 niveaux (relatifs à cellSize)
float tinyRel   = 0.25f;
float smallRel  = 0.50f;
float mediumRel = 0.75f;
float largeRel  = 1.00f;

final float REL_MIN  = 0.00f;
final float REL_MAX  = 1.50f;
final float REL_STEP = 0.05f;
final float EPS      = 0.00f;

// fenêtre fixe pour l'affichage (exports à taille native)
final int VIEW_W = 1100;
final int VIEW_H = 800;

// compteur de série pour les exports PNG "s"
int compteur = 0;

void settings() {
  // Lister images du dossier /data
  File dataDir = new File(dataPath(""));
  if (dataDir.exists()) {
    File[] files = dataDir.listFiles();
    if (files != null) {
      for (File f : files) {
        String name = f.getName().toLowerCase();
        if (name.endsWith(".png") || name.endsWith(".jpg") || name.endsWith(".jpeg")) {
          images.add(f);
        }
      }
    }
  }

  if (images.isEmpty()) {
    // Démo si pas d'images
    img = createImage(900, 600, RGB);
    img.loadPixels();
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        float g = map(x, 0, img.width - 1, 0, 255);
        img.pixels[y * img.width + x] = color(g);
      }
    }
    img.updatePixels();
    imgBase = "demo";
  } else {
    loadImageAt(0);
  }

  size(VIEW_W, VIEW_H, P2D);
}

void setup() {
  noStroke();
  imageMode(CORNER);
  surface.setTitle("Trame — PNG transparent + SVG");
}

void draw() {
  background(255);

  float fit = 1.0f;
  if (img != null) {
    float sx = (float) width / img.width;
    float sy = (float) height / img.height;
    fit = min(sx, sy);
  }

  pushMatrix();
  translate((width - img.width * fit) * 0.5f, (height - img.height * fit) * 0.5f);
  renderTo(g, fit);
  popMatrix();

  // HUD écran uniquement
  drawHUD();
}

// ----------- Chargement image -----------
void loadImageAt(int idx) {
  imgIndex = ((idx % images.size()) + images.size()) % images.size();
  File f = images.get(imgIndex);

  img = loadImage(f.getName());  // depuis /data
  if (img == null) {
    img = createImage(800, 600, RGB);
    img.loadPixels();
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        float g = map((x + y) % img.width, 0, img.width - 1, 0, 255);
        img.pixels[y * img.width + x] = color(g);
      }
    }
    img.updatePixels();
    imgBase = "invalid";
  } else {
    imgBase = baseName(f.getName());
  }
}

String baseName(String fileName) {
  int dot = fileName.lastIndexOf('.');
  if (dot <= 0) return fileName;
  return fileName.substring(0, dot);
}

// ----------- Rendu factorisé -----------
void renderTo(PGraphics pg, float scale) {
  // Pixels gris -> tailles ; rendu = formes (ellipse/rect) => SVG ok
  PImage gcopy = img.copy();
  gcopy.filter(GRAY);
  gcopy.loadPixels();

  float angle = radians(angleDeg);
  int w = gcopy.width, h = gcopy.height;

  pg.pushMatrix();
  pg.scale(scale);

  for (int y = 0; y < h; y += cellSize) {
    for (int x = 0; x < w; x += cellSize) {
      int idx = min(y * w + x, gcopy.pixels.length - 1);
      float b = brightness(gcopy.pixels[idx]); // 0..100
      float t = invert ? (b / 100.0f) : (1.0f - b / 100.0f);

      float d;
      if (discreteMode) {
        float rel;
        if      (t < 0.25f) rel = tinyRel;
        else if (t < 0.50f) rel = smallRel;
        else if (t < 0.75f) rel = mediumRel;
        else                rel = largeRel;

        d = rel * cellSize * dotScale;
        d = constrain(d, 0, cellSize);

        if (d < cellSize * 0.3f) {
          continue; // trop petit -> saute
        }
      } else {
        d = t * cellSize * dotScale;
      }

      d = constrain(d, 0, cellSize);

      float ew = max(0.2f, d);
      float eh = max(0.2f, d * aspect);

      pg.pushMatrix();
      pg.translate(x + cellSize * 0.5f, y + cellSize * 0.5f);
      pg.rotate(angle);
      pg.fill(0);
      pg.noStroke();

      if (shapeMode == 0) {
        pg.ellipse(0, 0, ew, eh);
      } else {
        pg.rectMode(CENTER);
        pg.rect(0, 0, ew, eh);
      }

      pg.popMatrix();
    }
  }

  pg.popMatrix();
}

// ---------- Exports PNG ----------
void saveTransparent() {
  // PNG transparent, taille native
  PGraphics off = createGraphics(img.width, img.height, P2D);
  off.beginDraw();
  off.clear();                // transparence totale
  renderTo(off, 1.0f);
  off.endDraw();

  String name = imgBase + "-" + nf(compteur, 3) + ".png";
  off.save(name);
  off.dispose();

  compteur++;
  println("Saved: " + name);
}

void saveHiResTransparent(int scale) {
  PGraphics off = createGraphics(img.width * scale, img.height * scale, P2D);
  off.beginDraw();
  off.clear();
  renderTo(off, (float) scale);
  off.endDraw();

  String name = imgBase + "-trame-hd-" + scale + "x.png";
  off.save(name);
  off.dispose();

  println("Saved: " + name);
}

// ---------- Exports SVG ----------
void saveSVG(int scale) {
  // SVG (vectoriel), taille native ou *scale
  String name = imgBase + "-trame-" + scale + "x.svg";
  PGraphics svg = createGraphics(img.width * scale, img.height * scale, SVG, name);

  svg.beginDraw();
  svg.clear(); // SVG: fond "vide" (selon viewer), en général ok
  renderTo(svg, (float) scale);
  svg.endDraw();
  svg.dispose();

  println("Saved: " + name);
}

// ---------- HUD (écran uniquement) ----------
void drawHUD() {
  fill(0, 165);
  noStroke();
  rect(8, 8, 720, 208, 6);
  fill(255);
  textSize(12);

  String mode = discreteMode ? "discret (4 tailles)" : "continu";
  String shape = (shapeMode == 0) ? "Ellipse" : "Carré";
  String imgInfo = images.isEmpty()
    ? "demo"
    : (imgBase + "  [" + (imgIndex + 1) + "/" + images.size() + "]  " + img.width + "×" + img.height);

  text(
    "Image: " + imgInfo +
    "\ncellSize: " + cellSize +
    " | dotScale: " + nf(dotScale, 1, 2) +
    " | aspect: " + nf(aspect, 1, 2) +
    " | angle: " + angleDeg + "°" +
    " | invert: " + invert +
    " | mode: " + mode +
    " | forme: " + shape +
    "\nN=suivante  P=précédente  |  m=forme ellipse/carré" +
    "\n↑/↓=cell  +/-=échelle  ←/→=aspect  r/R=angle  i=invert  c=discret/continu" +
    "\nExports:  s=PNG transparent  H=PNG ×2  |  V=SVG  G=SVG ×2" +
    "\nTailles: tiny=" + nf(tinyRel, 1, 2) +
    "  small=" + nf(smallRel, 1, 2) +
    "  medium=" + nf(mediumRel, 1, 2) +
    "  large=" + nf(largeRel, 1, 2),
    16, 30
  );

  text(
    "Ajuster niveaux (AZERTY/QWERTY) — ↓ diminue / ↑ augmente\n" +
    "Tiny:   [&] / [1 ou !]   | Small:  [é] / [2 ou @]\n" +
    "Medium: [\" ] / [3 ou #] | Large:  ['] / [4 ou $]",
    16, 168
  );
}

// ---------- Contrôles ----------
void keyPressed() {
  // Navigation
  if (key == 'n' || key == 'N') { if (!images.isEmpty()) loadImageAt(imgIndex + 1); }
  if (key == 'p' || key == 'P') { if (!images.isEmpty()) loadImageAt(imgIndex - 1); }

  // Réglages
  if (keyCode == UP)    cellSize = max(2, cellSize - 1);
  if (keyCode == DOWN)  cellSize = min(200, cellSize + 1);
  if (key == '+')       dotScale = min(5.0f, max(0.05f, dotScale + 0.05f));
  if (key == '-')       dotScale = min(5.0f, max(0.05f, dotScale - 0.05f));

  if (keyCode == LEFT)  aspect = max(0.25f, aspect - 0.03f);
  if (keyCode == RIGHT) aspect = min(1.00f, aspect + 0.03f);
  if (key == 'r')       angleDeg = (angleDeg - 5 + 360) % 360;
  if (key == 'R')       angleDeg = (angleDeg + 5) % 360;

  if (key == 'i')       invert = !invert;
  if (key == 'c')       discreteMode = !discreteMode;
  if (key == 'm')       shapeMode = 1 - shapeMode;

  // Exports
  if (key == 's') saveTransparent();
  if (key == 'H') saveHiResTransparent(2);
  if (key == 'V') saveSVG(1);
  if (key == 'G') saveSVG(2);

  // Niveaux
  if (key == '&')               tinyRel   -= REL_STEP;
  if (key == '1' || key == '!') tinyRel   += REL_STEP;

  if (key == 'é')               smallRel  -= REL_STEP;
  if (key == '2' || key == '@') smallRel  += REL_STEP;

  if (key == '"' )              mediumRel -= REL_STEP;
  if (key == '3' || key == '#') mediumRel += REL_STEP;

  if (key == '\'' )             largeRel  -= REL_STEP;
  if (key == '4' || key == '$') largeRel  += REL_STEP;

  normalizeLevels();
}

void normalizeLevels() {
  tinyRel   = constrain(tinyRel,   REL_MIN, REL_MAX);
  smallRel  = max(constrain(smallRel,  REL_MIN, REL_MAX), tinyRel   + EPS);
  mediumRel = max(constrain(mediumRel, REL_MIN, REL_MAX), smallRel  + EPS);
  largeRel  = max(constrain(largeRel,  REL_MIN, REL_MAX), mediumRel + EPS);
}
