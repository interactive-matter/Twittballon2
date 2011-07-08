#include <TMC262Stepper.h>
#include <Servo.h>

p_message target_message1[] = "Target: ";
p_message target_message2[] = ", Current: ";
p_message control_message[] ="Control :";

#define MICRO_STEPS 4.0
#define STEPS 200.0
#define MAX_LEVEL (STEPS*MICRO_STEPS*35.0)
#define TWEET_WEIGHT 30

#define CS_PIN 5
#define DIR_PIN 6
#define STEP_PIN 7
#define ENABLE_PIN 8

//every second we reduce the value
Metro reduceMetro = Metro(1000);

TMC262Stepper tmc262Stepper = TMC262Stepper(STEPS,CS_PIN,DIR_PIN,STEP_PIN,400);

void setupBalloon() {
  //set the pins as outputs
  pinMode(CS_PIN,OUTPUT);
  pinMode(DIR_PIN,OUTPUT);
  pinMode(STEP_PIN,OUTPUT);
  pinMode(ENABLE_PIN,OUTPUT);

  //enable the driver
  digitalWrite(ENABLE_PIN, LOW);

  //set this according to you stepper
  tmc262Stepper.setSpreadCycleChopper(2,24,6,0,1);
  tmc262Stepper.setRandomOffTime(1);
  tmc262Stepper.setMicrosteps(MICRO_STEPS);
  tmc262Stepper.setSpeed(300);

  tmc262Stepper.start();

}

//the current level
long level=0;
//in scaled
long current_level = 0;
void loopBalloon(char newAnswers) {
  level+=newAnswers*TWEET_WEIGHT;
  if (reduceMetro.check()) {
    level--;
    if (level<=0) {
      level=0;
    }
    Serial.print("level ");
    Serial.print(level);
    Serial.print(" / ");
    Serial.println(current_level);
  }
  long scaled_level = scale(level);
  long difference = scaled_level-current_level;
  if (difference!=0) {
    /*
    Serial.print("Level: ");
     Serial.print(scaled_level);
     Serial.print(" Diff: ");
     Serial.println(difference);
     */
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




