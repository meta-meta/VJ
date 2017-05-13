using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Multidisplay : MonoBehaviour {

	// Use this for initialization
	void Start () {
	    if (Display.displays.Length > 1)
	        Display.displays[1].Activate();

	    Screen.fullScreen = true;
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
