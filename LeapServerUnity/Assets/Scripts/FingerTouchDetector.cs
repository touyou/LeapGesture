using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using System.Linq;

public class FingerTouchDetector : MonoBehaviour {
  public const float TRIGGER_DISTANCE_RATIO = 0.7f;

  private Controller controller;
  private Finger[] leftFingers;
  private Finger[] rightFingers;

  // Use this for initialization
  void Start() {
    controller = new Controller();
    leftFingers = new Finger[5];
    rightFingers = new Finger[5];
  }

  // Update is called once per frame
  void Update() {
    Frame frame = controller.Frame();
    foreach (Hand hand in frame.Hands) {
      if (hand.IsRight) {
        rightFingers = hand.Fingers.ToArray();
      } else if (hand.IsLeft) {
        leftFingers = hand.Fingers.ToArray();
      }
    }

    Vector leapThumbTip = leftFingers[0].TipPosition;
    float proximalLength = leftFingers[0].Bone(Bone.BoneType.TYPE_PROXIMAL).Length;
    float triggerDistance = proximalLength * TRIGGER_DISTANCE_RATIO;

    bool[] isLeftPinch = new bool[4];
    for (int i = 1; i < HandModel.NUM_FINGERS; i++) {
      Finger finger = leftFingers[i];
      isLeftPinch[i - 1] = false;
      for (int j = 0; j < FingerModel.NUM_BONES && !isLeftPinch[i - 1]; j++) {
        Vector leapJointPosition = finger.Bone((Bone.BoneType)j).NextJoint;
        if (leapJointPosition.DistanceTo(leapThumbTip) < triggerDistance) {
          isLeftPinch[i - 1] = true;
        }
      }
    }
    Debug.Log(isLeftPinch[0] + "," + isLeftPinch[1] + "," + isLeftPinch[2] + "," + isLeftPinch[3]);
  }
}
