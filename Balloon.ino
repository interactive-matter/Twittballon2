#include <TMC262Stepper.h>
#include <Servo.h>

#define MICRO_STEPS 8
#define STEPS 200
#define MAX_LEVEL (STEPS*MICRO_STEPS*MAX_TURNS)

#define TMC_CS_PIN 2
#define TMC_DIR_PIN 6
#define TMC_STEP_PIN 7
#define TMC_ENABLE_PIN 8

//every second we reduce the value
Metro reduceMetro = Metro(1000);

TMC262Stepper tmc262Stepper = TMC262Stepper(STEPS,TMC_CS_PIN,TMC_DIR_PIN,TMC_STEP_PIN,1300);

void setupBalloon() {
  //set the pins as outputs
  pinMode(TMC_CS_PIN,OUTPUT);
  digitalWrite(TMC_CS_PIN,HIGH);
  pinMode(TMC_DIR_PIN,OUTPUT);
  pinMode(TMC_STEP_PIN,OUTPUT);
  pinMode(TMC_ENABLE_PIN,OUTPUT);

  //enable the driver
  digitalWrite(TMC_ENABLE_PIN, LOW);

  //set this according to you stepper
  tmc262Stepper.setSpreadCycleChopper(2,24,8,6,0);
  tmc262Stepper.setRandomOffTime(1);
  tmc262Stepper.setMicrosteps(MICRO_STEPS);
  tmc262Stepper.setSpeed(150);
  tmc262Stepper.start();
}

//the current level
long level=0;
//in scaled
long current_level = 0;
void addAnswerToBalloon(char newAnswers) {
  level+=newAnswers*TWEET_WEIGHT;
}

void loopBalloon() {
  
  if (reduceMetro.check()) {
    level--;
    if (level<=0) {
      level=0;
    }
//    Serial.print(F("level "));
//    Serial.print(level);
//    Serial.print(F(" / "));
//    Serial.println(current_level);
  }
  long scaled_level = scale(level);
  long difference = scaled_level-current_level;
  if (difference!=0) {

    Serial.print(F("Level: "));
    Serial.print(scaled_level);
    Serial.print(F(" Diff: "));
    Serial.println(difference);

    long way = abs(difference);
    int steps = (int) min(way,100l);
    if (difference<0) {
      tmc262Stepper.step(-steps);
      current_level-=steps;
    } 
    else {
      tmc262Stepper.step(steps);
      current_level+=steps;
    }
  }

  if (!tmc262Stepper.isMoving()) {
    tmc262Stepper.step(level);
    level=0;
  }
  tmc262Stepper.move();
}

long max_level = 1;
long scale(long scaling_level) {
  if (scaling_level>max_level) {
    max_level = scaling_level;
  }
  float max_float = max_level;
  float target_float = scaling_level;
  float result = (float)MAX_LEVEL*(target_float/max_float);
  /*
  Serial.print(max_float);
   Serial.print(" - ");
   Serial.print(result);
   Serial.print(" - ");
   Serial.println((long)result);
   */
  return result;
}


