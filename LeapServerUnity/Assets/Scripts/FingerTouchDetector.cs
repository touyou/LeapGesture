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

  private UdpServer server;

  // Use this for initialization
  void Start() {
    controller = new Controller();
    leftFingers = new Finger[5];
    rightFingers = new Finger[5];
    server = new UdpServer();
    server.init(5432, 1234);
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

    bool[] isLeftPinch = PinchDetect(leftFingers);
    bool[] isRightPinch = PinchDetect(rightFingers);
    string data = "";
    for (int i = 0; i < isLeftPinch.Length; i++) {
      if (isLeftPinch[i]) data += i.ToString();
    }
    for (int i = 0; i < isRightPinch.Length; i++) {
      if (isRightPinch[i]) data += (i + 5).ToString();
    }

    Debug.Log(data);
    server.send(data);
  }

  bool[] PinchDetect(Finger[] fingers) {
    if (fingers == null || fingers.Length == 0) return new bool[0];
    if (fingers[0] == null) return new bool[0];
    Vector thumbTip = fingers[0].TipPosition;
    float proximalLength = fingers[0].Bone(Bone.BoneType.TYPE_PROXIMAL).Length;
    float triggerDistance = proximalLength * TRIGGER_DISTANCE_RATIO;

    bool[] isPinch = new bool[4];
    for (int i = 1; i < HandModel.NUM_FINGERS; i++) {
      Finger finger = fingers[i];
      isPinch[i - 1] = false;
      for (int j = 0; j < FingerModel.NUM_BONES && !isPinch[i - 1]; j++) {
        Vector jointPosition = finger.Bone((Bone.BoneType)j).NextJoint;
        if (jointPosition.DistanceTo(thumbTip) < triggerDistance) {
          isPinch[i - 1] = true;
        }
      }
    }
    return isPinch;
  }
}
