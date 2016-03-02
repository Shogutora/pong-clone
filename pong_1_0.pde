 //<>//
// Määritellään muuttujat
PVector speed, direction, comp, player, ball, acceleration, velocity, target, playerEnd, estimate;
float difficulty = 1;
float maxSpeed = 3*difficulty;
float increase = difficulty/10;
float estimation = 60;
float padmove = 0;
float padSpeed = 7;

int cpuScore, cycle, playerScore, ballSize = 5;
boolean playerHitLast = false;
boolean moving = false;
boolean pause = true;
boolean reset = true;

// Alustetaan "kangas"
void setup () {
  // Koon määrittely
  size(640, 480, P2D);
  // Luodaan fonttimuuttuja ohjelman käyttöön
  PFont font;
  // Ladataan se tiedostosta
  //font = createFont("Consolas.ttf", 32);
  textSize(32);
  //textFont(font);
  // Alustetaan osa vektorimuuttujista
  direction = new PVector(3, random(0, 2));
  comp = new PVector (20, 30);
  ball = new PVector (40, 40);
  player = new PVector (width-20, 160);
  playerEnd = new PVector (player.x-20, player.y);
  acceleration = new PVector(0, 0);
  velocity = new PVector(0, 0);
  target = new PVector(comp.x, 0);
  // Määritetään että kursoria ei näytetä
  noCursor();
}
// Tämä on piirto-looppi
void draw() {
  // Määritetään musta tausta
  background(0);
  // Asetetaan tekstin väriksi keskiharmaa
  fill(128);

  if (!pause) {
    text("CPU:"+cpuScore+" | P1:"+playerScore, 210, 100);
    // Mailan liikutus ihmispelaajalle
    movePad();
    // Pallon liikuttamismetodi
    moveBall();
    // Tietokoneen liikutusmetodi
    moveComputer();
    //println(direction.y);
    //    line(estimate.x, estimate.y, ball.x, ball.y);
    //    stroke(0, 255, 0);
    //    line(ball.x, ball.y, target.x, target.y);
    //    stroke(0, 0, 255);
    //    line(target.x, target.y, comp.x, comp.y);
  } else {
    text("MENU:", 180, 100);
    text("p:    pause", 180, 200);
    text("1-5:  difficulty", 180, 250);
    text("r:    reset", 180, 300);
    text("esc:  exit", 180, 350);
    if (reset) {
      text("press p to begin", 180, 400);
    }
  }

  // Vaihdetaan takaisin muille elementeille


  fill(255);
  // Määritellään viivan tyyppi
  strokeCap(SQUARE);
  // Lopuksi piirretään elementit taustaa vasten
  stroke(255, 255, 255);
  strokeWeight(5);
  line(comp.x, comp.y-20, comp.x, comp.y+20);  
  ellipse(ball.x, ball.y, ballSize, ballSize); 
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
  //println("dirX: "+direction.x);
  //println("dirY: "+direction.y);
  if (dp <= 20 && (ball.x >= player.x-ballSize && totalX >= player.x-ballSize)) {
    // Konsoliin tulostus
    println("Player hit");
    // Suuntaan tehdään muutoksia, lisätään nopeutta ja vaihdetaan suunta kertomalla -1:llä
    direction.x+=increase;
    if (ball.y < player.y) {
      direction.y-=map(abs(player.y-ball.y), 0, 20, 0, 2);
    } else if (ball.y > player.y) {
      direction.y+=map(abs(ball.y-player.y), 0, 20, 0, 2);
    }
    direction.x = direction.x*-1;
    // Asetetaan boolean joka sanoo että pelaaja löi viimeksi, pisteiden laskua varten
    playerHitLast = true;
    //updateTarget();
    moving = false;
  }
  // Tämä ehtohaara on lähes identtinen
  else if ( dc <= 20 && ball.x <= comp.x+5 && totalX <= comp.x+5) {
    println("Computer hit");
    if (ball.y < comp.y) {
      direction.y-=map(abs(comp.y-ball.y), 0, 20, 0, 2);
    } else if (ball.y > comp.y) {
      direction.y+=map(abs(ball.y-comp.y), 0, 20, 0, 2);
    }
    direction.x = direction.x*-1;
    direction.x+=increase;
    playerHitLast = false;
    moving = false;
  }
  // Tutkitaan menikö pallo yli laidan
  else if (ball.x >= width-5 || ball.x <= 5) {
    println("Ball over board");
    // Jos pelaaja löi viimeksi, annetaan hänelle piste, muuten tietokoneelle
    if (playerHitLast) {
      playerScore+=1;
    } else {
      cpuScore+=1;
    }
    // Lopuksi uudelleenalustetaan pallo
    resetBall();
    moving = false;
  }

  // Tässä on vain kimpoamislogiikka ja suunnan vaihto
  else if ((ball.y >= height-5 && dirY >= height-5) || (ball.y <= 5 && dirY <= 5)) {
    println("Ball hit ceiling/floor");
    direction.y = direction.y*-1;
    moving = false;
  }
}

void movePad() {
  if ((player.y + padmove) < height-10 && (player.y+padmove) > 0+10) {
    player.y += padmove;
  }
  //player.y = mouseY;
} 
void moveComputer() {
  // Kutsuu pallon paikan päivitystä
  updateTarget();
  // Laskee mailan ja pallon erotuksen
  PVector desired = PVector.sub(target, comp);
  // Ja niiden absoluuttisen etäisyyden
  float d = desired.mag();
  //println("Distance to target: "+d);
  if (d < 100) {
    float m = map(d, 0, 50, 0, maxSpeed);
    desired.setMag(m);
  } else {
    desired.setMag(maxSpeed);
  }

  float r = random(0, 10);
  //  float limiter = map(r,0,100,0.5,2);
  //  if(r > 30){
  //    desired.setMag(0.2);
  //  }
  PVector steer = PVector.sub(desired, velocity);
  acceleration.add(steer);
  acceleration.add(desired);
  acceleration.limit(r);
  velocity.add(acceleration);
  velocity.limit(maxSpeed);
  if (comp.y + velocity.y <= height-10 && comp.y + velocity.y >=0+10) {
    comp.add(velocity);
  }
  acceleration.mult(0);
}
void updateTarget() {
  println(estimation);
  estimate = direction.copy().mult(estimation).limit(width/2);
  estimate.add(ball);
  float distCompEstX = abs(estimate.x-comp.x);
  float distBallEstX = abs(estimate.x)+abs(ball.x);
  float distBallEstY = abs(ball.y-estimate.y);
  float offset = (distCompEstX/distBallEstX)*distBallEstY;
  if (estimate.x <= comp.x && !moving && playerHitLast) {
    if (ball.y < comp.y) {
      println("target above");
      target = new PVector(comp.x, estimate.y-offset);
    } else if (ball.y > comp.y) {
      println("target below");
      target = new PVector(comp.x, estimate.y+offset);
    }
    moving = true;
    //pause = true;
    cycle = 0;
  } else if (cycle > 30 && !moving) {
    println("following");
    if (ball.y > comp.y) {
      target = new PVector(comp.x, comp.y+200);
    } else {
      target = new PVector(comp.x, comp.y-200);
    }
    cycle = 0;
  }
  cycle++;
  //println("--------------");
  //println("distCompEstX: "+distCompEstX);
  //println("distBallEstX: "+distBallEstX);
  //println("distBallEstY: "+distBallEstY);
  //println("offset: "+offset);
  //println("target: "+target);
  //println("ball: "+ball);
  //println("estimate: "+estimate);
  //println("comp: " +comp);
  stroke(255, 0, 0);
  strokeWeight(1);
  line(estimate.x, estimate.y, ball.x, ball.y);
  stroke(200, 200, 0);
  line(target.x, target.y, comp.x, comp.y);
}

void keyPressed() {
  println(keyCode);
  if (keyCode == 'P') {
    pause = !pause;
    reset = false;
  }
  if (keyCode == 'R') {
    reset = true;
    resetBall();
    playerScore = 0;
    cpuScore = 0;
  } else {
    switch (keyCode) {
    case 49: 
      difficulty = 1;
      maxSpeed = 3*difficulty;
      increase = difficulty/10;
      estimation = 60;
      break;
    case 50: 
      difficulty = 2;
      maxSpeed = 2*difficulty;
      increase = difficulty/10;
      estimation = 70;
      break;
    case 51: 
      difficulty = 3;
      maxSpeed = 2*difficulty;
      increase = difficulty/10;
      estimation = 80;
      break;
    case 52: 
      difficulty = 4;
      maxSpeed = 1.5*difficulty;
      increase = difficulty/10;
      estimation = 90;
      break;
    case 53: 
      difficulty = 5;
      maxSpeed = 1.5*difficulty;
      increase = difficulty/10;
      estimation = 100;
      break;
    }
  }

  if (key == CODED) {
    if (keyCode == UP) {
      padmove = -padSpeed;
    } else if (keyCode == DOWN) {
      println("pressed down");
      padmove = padSpeed;
    }
  }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      padmove = 0;
    } else if (keyCode == DOWN) {
      println("pressed down");
      padmove = 0;
    }
  } else {
    if (keyCode == 'p') {
      pause = !pause;
    }
  }
}

void resetBall() {
  if (playerHitLast) {
    direction.x = -3;
  } else {
    direction.x = 3;
  }
  direction.y = random(0, 3);
  ball.x = width/2;
  ball.y = height/2;
}