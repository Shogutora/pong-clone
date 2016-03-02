
// Määritellään muuttujat
PVector speed, direction, comp, player, ball, acceleration,velocity,target,playerEnd;
float maxSpeed = 10;
int cpuScore,cycle,playerScore;
boolean playerHitLast = false;
// Alustetaan "kangas"
void setup () {
  // Koon määrittely
  size(640, 480, P2D);
  // Luodaan fonttimuuttuja ohjelman käyttöön
  PFont font;
  // Ladataan se tiedostosta
  font = loadFont("SansSerif-48.vlw");
  textSize(48);
  // Alustetaan osa vektorimuuttujista
  direction = new PVector(3, random(0, 2));
  comp = new PVector (30, 30);
  ball = new PVector (40, 40);
  player = new PVector (width-30, 160);
  playerEnd = new PVector (player.x-20,player.y);
  acceleration = new PVector(0,0);
  velocity = new PVector(0,0);
  target = new PVector(comp.x,0);
  // Asetetaan anti-aliasing
  smooth(2);
  
}
// Tämä on piirto-looppi
void draw() {
  // Määritetään että kursoria ei näytetä
  noCursor();
  // Määritetään musta tausta
  background(0);
  // Asetetaan tekstin väriksi keskiharmaa
  fill(128);
  text(cpuScore+" | "+playerScore, 280, 100);
  // Vaihdetaan takaisin muille elementeille
  fill(255);
  // Määritellään viivan tyyppi
  stroke(255, 255, 255);
  strokeWeight(5);
  strokeCap(SQUARE);
  // Mailan liikutus ihmispelaajalle
  movePad();
  // Pallon liikuttamismetodi
  moveBall();
  // Tietokoneen liikutusmetodi
  moveComputer();
  // Lopuksi piirretään elementit taustaa vasten
  line(comp.x, comp.y-20, comp.x, comp.y+20);  
  ellipse(ball.x, ball.y, 10, 10); 
  line(player.x, player.y-20, player.x, player.y+20);
}

void moveBall () {
  // Pallon vektoriin lisätään suuntavektori
  ball.add(direction);
  // Lasketaan pallon etäisyyttä mailoista
  float dp = PVector.dist(ball, player);
  float dc = PVector.dist(ball, comp);
  float totalX = ball.x+direction.x;
  float dirY = ball.y+direction.y;
  // Jos pallo osuu pelaajan mailaan
  println(direction.x);
  println(direction.y);
  if (dp <= 20 && (ball.x >= player.x-5 && totalX >= player.x-5)) {
    // Konsoliin tulostus
    println("Player hit");
    // Suuntaan tehdään muutoksia, lisätään nopeutta ja vaihdetaan suunta kertomalla -1:llä
    direction.x+=0.3;
    direction.y+=random(-2,2);
    direction.x = direction.x*-1;
    // Asetetaan boolean joka sanoo että pelaaja löi viimeksi, pisteiden laskua varten
    playerHitLast = true;
    //updateTarget();
  }
  // Tämä ehtohaara on lähes identtinen
  else if ( dc <= 20 && ball.x <= comp.x+5 && totalX <= comp.x+5) {
    println("Computer hit");
    direction.x+=0.3;
    direction.y+=random(-2,2);
    direction.x = direction.x*-1;
    playerHitLast = false;
  }
  // Tutkitaan menikö pallo yli laidan
  else if (ball.x >= width-5 || ball.x <= 5) {
    println("Ball over board");
    // Jos pelaaja löi viimeksi, annetaan hänelle piste, muuten tietokoneelle
    if (playerHitLast) {
      cpuScore+=1;
    }
    else {
      playerScore+=1;
    }
    // Lopuksi uudelleenalustetaan pallo
     direction.x = 3;
     direction.y = random(0, 3);
     ball.x = 100;
     ball.y = 160;
  }

  // Tässä on vain kimpoamislogiikka ja suunnan vaihto
  else if ((ball.y >= height-5 && dirY >= height-5) || (ball.y <= 5 && dirY <= 5)) {
    println("Ball hit ceiling/floor");
    direction.y = direction.y*-1;
  }
}
// Hiiri ohjaa suoraan mailaa
void movePad() {
  player.y = mouseY;
} 
void moveComputer() {
  // Kutsuu pallon paikan päivitystä
  updateTarget();
  // Laskee mailan ja pallon erotuksen
  PVector desired = PVector.sub(target,comp);
  // Ja niiden absoluuttisen etäisyyden
  float d = desired.mag();
   if (d < 50) {
      float m = map(d,0,50,0,maxSpeed);
      desired.setMag(m);
    } else {
      desired.setMag(maxSpeed);
    }
  
  PVector steer = PVector.sub(desired,velocity);
  acceleration.add(steer);
  acceleration.add(desired);
  velocity.add(acceleration);
  velocity.limit(maxSpeed);
  comp.add(velocity);
  acceleration.mult(0);
  
}
void updateTarget(){
  PVector estimate = direction.get();
  estimate.mult(50);
  cycle += 1;
  if (cycle == 1){
    cycle = 0;
    target = new PVector(comp.x,ball.y);
  }
  else {
    target = target;
  } 
}

/*void keyPressed() {
 if (key == CODED){
 if (keyCode == UP) {
 player.y +=-4;
 }
 if (keyCode == DOWN) {
 player.y+=4;
 }
 }
 }*/

